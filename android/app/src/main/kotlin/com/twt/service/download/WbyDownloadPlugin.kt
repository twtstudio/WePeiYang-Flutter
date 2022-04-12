package com.twt.service.download

import android.app.Activity
import android.app.DownloadManager
import android.net.Uri
import android.os.Environment
import com.google.gson.Gson
import com.twt.service.common.FileUtil
import com.twt.service.common.LogUtil
import com.twt.service.common.WbyPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.io.File

/**
 * 微北洋下载器
 *
 * 注：在flutter端就要对已经下载了的文件进行过滤
 */
class WbyDownloadPlugin : WbyPlugin() {
    override val name: String
        get() = "com.twt.service/download"

    /**
     * [DownloadManager] instance
     */
    val manager: DownloadManager by lazy {
        context.getSystemService(Activity.DOWNLOAD_SERVICE) as DownloadManager
    }

    /**
     * 用于下载进度检查
     */
    private var listenJob: Job? = null

    /**
     * 在主线程中通过协程的方式循环查询下载状态
     */
    private val mainScope = CoroutineScope(Dispatchers.Main)

    /**
     * 获取下载基本目录，如果获取失败则报错
     *
     * @param action 获取到下载目录后的操作
     */
    private fun getDownloadDir(action: (File) -> Unit) {
        val downloadDir = FileUtil.downloadDirectory(context)
        if (downloadDir == null) {
            LogUtil.e(TAG, NullPointerException("downloadDir == null"))
        } else {
            action(downloadDir)
        }
    }

    /**
     * 下载列表，添加到[DownloadManager]中后，以返回的 downloadId 为 key，下载项为 value
     */
    val downloadList = mutableMapOf<Long, DownloadTask>()

    /**
     * 实现[DownloadListener]，对应每个状态应该上报flutter端什么内容
     *
     * @see DownloadListener
     */
    private val listener = DownloadListener(this)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        runCatching {
            when (call.method) {
                "addDownloadTask" -> {
                    log("addDownloadTask")
                    // 获取下载列表
                    val data = call.argument<String>("downloadList")
                    val list = Gson().fromJson(data, DownloadList::class.java).list
                    log("base list : $list")
                    log("current download list : $downloadList")
                    // 先过滤掉正在下载的内容
                    val unStartList = filterDownloadingFiles(list)
                    // 再下载没有下载的内容
                    download(unStartList, result)
                }
                else -> result.notImplemented()
            }
        }.onFailure {
            result.error("", "${it.message}", "")
        }
    }

    /**
     * 过滤掉正在下载的任务，对于正在下载的任务更新进度
     *
     * @param list 准备进行下载的任务列表
     * @return 未开始下载的任务列表
     */
    private fun filterDownloadingFiles(list: List<DownloadTask>): List<DownloadTask> {
        // 下载列表中有的任务就更新一下进度
        downloadList.filter { downloading ->
            list.map { it.path() }.contains(downloading.value.path())
        }.keys.forEach {
            listener.updateStatus(it)
        }

        // 清除临时文件：没有在下载列表中
        // 只添加下载列表中没有的任务
        return list.filterNot { task ->
            downloadList.values.map {
                it.path()
            }.contains(task.path())
        }.apply(::clearTemporaryFiles)
    }

    /**
     * 添加到 [DownloadManager] 进行下载
     *
     * @param list 将开始下载的任务
     * @return 是否成功全部添加进下载器
     */
    private fun download(list: List<DownloadTask>, result: MethodChannel.Result) {
        // 本次加入到下载中的任务
        val startList = mutableListOf<Long>()
        runCatching {
            list.forEach {
                // 创建请求
                val request = DownloadManager.Request(Uri.parse(it.url)).apply {
                    setDestinationInExternalFilesDir(
                        context,
                        Environment.DIRECTORY_DOWNLOADS,
                        it.temporaryPath(),
                    )
                    if (it.showNotification) {
                        setTitle(it.title)
                        setDescription(it.description)
                        setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
                    } else {
                        setNotificationVisibility(DownloadManager.Request.VISIBILITY_HIDDEN)
                    }
                }
                // 加入到下载并返回 downloadId
                val downloadId = manager.enqueue(request)
                // 临时存一下 id，如果出现错误，根据这个id来取消任务
                startList.add(downloadId)
                // 将任务加入到下载列表
                downloadList[downloadId] = it
                log("add $it into queue , id : $downloadId")
            }
        }.onFailure {
            // 如果创建任务出现错误，就取消本次下载任务
            log("error occur in download method : ${it.message}")
            startList.forEach { id ->
                manager.remove(id)
            }
            result.error("", "", "")
        }.onSuccess {
            configDownload()
            result.success("add download tasks success")
        }
    }

    /**
     * 配置下载监听器，并保存异步任务[listenJob]，防止重复创建
     */
    private fun configDownload() {
        if (listenJob != null) return
        listenJob = mainScope.launch {
            val progressList = mutableMapOf<Long, Pair<Int, Double>>()
            while (true) {
                // 每两秒获取一次状态
                log("circle + $progressList")
                if (getDownloadStatus(progressList)) break
                delay(2000)
            }
            // 下载列表为空后就 cancel 任务，并将 listenJob 设为 null
            cancel()
            listenJob = null
        }
    }

    /**
     * 获取下载列表中的任务的状态
     *
     * @return
     * true [downloadList]为空，结束循环
     *
     * false [downloadList]不为空，继续循环
     */
    private fun getDownloadStatus(progressList: MutableMap<Long, Pair<Int, Double>>): Boolean {
        try {
            val iterator = downloadList.iterator()
            while (iterator.hasNext()) {
                val item = iterator.next()
                val id = item.key
                val task = item.value

                val query = DownloadManager.Query().setFilterById(id)
                val cursor = manager.query(query)
                if (!cursor.moveToFirst()) {
                    // This method will return false if the cursor is empty.
                    // 所以就删除这条任务
                    iterator.remove()
                    progressList.remove(id)
                    // 并上报错误
                    listener.taskDisappear(task)
                    log("path : ${task.fileName} don't find")
                    continue
                }
                // 获取下载进度
                val progress = cursor.progress()
                // 获取下载状态
                val status = cursor.status()
                // 保证不会重复汇报
                if (progressList[id]?.second == progress && progressList[id]?.first == status) continue
                // 将现在的进度和状态记录到列表中，防止重复上报
                progressList[id] = status to progress
                log("id : $id downloading : $progress path : ${task.fileName} state : $status")

                // https://www.cxyzjd.com/article/lonewolf521125/41477023
                // 根据不同的状态进行不同处理
                when (status) {
                    DownloadManager.STATUS_FAILED, DownloadManager.STATUS_SUCCESSFUL -> {
                        iterator.remove()
                        progressList.remove(id)
                    }
                }

                if (status == DownloadManager.STATUS_SUCCESSFUL) {
                    getDownloadDir {
                        val from = File(it, task.temporaryPath())
                        val to = File(it, task.path())
                        if (!from.renameTo(to)) {
                            listener.updateStatus(
                                task,
                                DownloadManager.STATUS_FAILED,
                                progress,
                                "can't rename temporary file"
                            )
                        }
                    }
                }

                // 向消息列表中加入任务
                listener.updateStatus(task, status, progress, "${cursor.reason()}")
            }
        } catch (e: Throwable) {
            LogUtil.e(TAG, e, "throw at getDownloadStatus")
        }
        // 每次循环结束后将任务一起发送到 flutter 端
        listener.apply()
        return downloadList.isEmpty()
    }

    /**
     * 删除下载列表中的临时文件
     *
     * 如果出现错误，则静默处理
     *
     * @param list 任务列表
     */
    private fun clearTemporaryFiles(list: List<DownloadTask>) {
        getDownloadDir {
            runCatching {
                list.forEach { task ->
                    val path = it.path + File.separator + task.temporaryPath()
                    File(path).takeIf { it.exists() }?.delete()
                }
            }.onFailure {
                log("delete apk error when get failure state: ${it.message}")
            }
        }
    }

    companion object {
        const val TAG = "DOWNLOAD"
        fun log(message: String) = LogUtil.d(TAG, message)
    }
}