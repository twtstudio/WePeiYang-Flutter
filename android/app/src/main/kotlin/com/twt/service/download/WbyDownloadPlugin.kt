package com.twt.service.download

import android.app.Activity
import android.app.DownloadManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.database.ContentObserver
import android.database.Cursor
import android.net.Uri
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.collect
import java.io.File

class WbyDownloadPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val mainScope = CoroutineScope(Dispatchers.Main)
    private val downloadProgress = MutableStateFlow(Progress(0, "unknown", Status.BEGIN, 0.0, ""))
    private lateinit var manager: DownloadManager
    private var flowJob: Job? = null
    private var observer: ContentObserver? = null
    private var receiver: BroadcastReceiver? = null
    private var downloadList = mutableMapOf<Long, DownloadItem>()
    private val downloadDirectory by lazy {
        context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)
    }
    private val handler = CoroutineExceptionHandler { _, throwable ->
        reportError(
            DOWNLOAD_ERROR,
            "all",
            "handle error when emit stateFlow : ${throwable.message}"
        )
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "com.twt.service/download")
        channel.setMethodCallHandler(this)
        manager = context.getSystemService(Activity.DOWNLOAD_SERVICE) as DownloadManager
//        clearFontsDownloadFile()
    }

    @Suppress("unused")
    private fun clearFontsDownloadFile() {
        Log.d(TAG, "clearFontsDownloadFile")
        downloadDirectory?.let {
            File(it.path + File.separator + "font").listFiles()?.forEach { file ->
                Log.d(TAG, "clear last time download font file : ${file.path}")
                file.delete()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun updateProgress(report: Map<*, *>) {
        Log.d(TAG, report.toString())
        channel.invokeMethod("updateProgress", report)
    }

    private fun reportError(listenerId: String, code: String, message: String?) {
        val report = mapOf(
            "listenerId" to listenerId,
            "state" to "ERROR",
            "code" to code,
            "message" to message
        )
        updateProgress(report)
    }

    private fun reportSuccess(task:DownloadItem){
        downloadDirectory?.let {
            val report = mapOf(
                "listenerId" to task.listenerId,
                "state" to "SUCCESS",
                "taskId" to task.id,
                "path" to it.path + File.separator + task.path()
            )
            updateProgress(report)
        }
    }

    private fun reportSuccess(task:Progress){
        val report = mapOf(
            "listenerId" to task.listenerId,
            "state" to "SUCCESS",
            "taskId" to task.taskId,
            "path" to task.path,
        )
        updateProgress(report)
    }

    private fun reportAllSuccess(listenerId: String){
        val allSuccess = mapOf(
            "listenerId" to listenerId,
            "state" to "ALL_SUCCESS",
        )
        updateProgress(allSuccess)
    }

    private fun reportRunning(task: Progress){
        val report = mapOf(
            "listenerId" to task.listenerId,
            "state" to "RUNNING",
            "taskId" to task.taskId,
            "progress" to task.progress
        )
        updateProgress(report)
    }

    private fun stopAllAndRemoveRegister() {
        downloadList.forEach {
            manager.remove(it.key)
        }
        downloadList.clear()

        observer?.let {
            context.contentResolver.unregisterContentObserver(it)
            observer = null
        }
        receiver?.let {
            context.unregisterReceiver(it)
            receiver = null
        }
        flowJob?.cancel()
        flowJob = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "addDownloadTask" -> {
                Log.d(TAG, "addDownloadTask")
                if (checkRegister(result)) {
                    kotlin.runCatching {
                        val data = call.argument<String>("downloadList")
                        Gson().fromJson(data, DownloadList::class.java).list
                    }.onSuccess {
                        Log.d(TAG, "base list : $it")
                        filterFiles(it.toMutableList(), result)
                    }.onFailure {
                        result.error(PARSE_ARGUMENT_ERROR, "parse argument error ${it.message}", "")
                    }
                }
            }
            "forceDispose" -> {
                kotlin.runCatching {
                    stopAllAndRemoveRegister()
                }.onFailure {
                    result.error("", "", "")
                }.onSuccess {
                    result.success("")
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun filterFiles(list: List<DownloadItem>, result: MethodChannel.Result) {
        kotlin.runCatching {
            filterDownloadFiles(list).apply {
                if (isEmpty() && list.isNotEmpty()) {
                    reportAllSuccess(list.first().listenerId)
                    return@runCatching
                }
                addDownloadTask(this)
            }
        }.onFailure {
            result.error(ADD_TASKS_ERROR, "add task error ${it.message}", "")
        }.onSuccess {
            result.success("add download tasks success")
        }
    }

    private fun addDownloadTask(list: List<DownloadItem>) {
        val downloads = mutableListOf<Long>()
        kotlin.runCatching {
            // 下载列表中有的任务就更新一下进度
            downloadList.filter { downloading ->
                list.map { it.path() }.contains(downloading.value.path())
            }.forEach {
                Log.d(TAG, "${it.value} has been in the downloadList")
                getProgress(it.key)
            }

            // 清除临时文件：没有在下载列表中
            // 只添加下载列表中没有的任务
            list.filterNot { task ->
                downloadList.values.map {
                    it.path()
                }.contains(task.path())
            }.apply {
                if (isEmpty()) {
                    return@runCatching
                }
                Log.d(TAG, "not in downloadList list : $this")
                clearTemporaryFiles(this)
            }.forEach {
                val request = DownloadManager.Request(Uri.parse(it.url)).apply {
                    setDestinationInExternalFilesDir(
                        context,
                        Environment.DIRECTORY_DOWNLOADS,
                        it.temporaryPath(),
                    )
                    if (it.showNotification) {
                        setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
                    } else {
                        setTitle(it.title)
                        setDescription(it.description)
                        setNotificationVisibility(DownloadManager.Request.VISIBILITY_HIDDEN)
                    }
                }
                val downloadId = manager.enqueue(request)
                downloads.add(downloadId)
                Log.d(TAG, "add $it into queue , id : $downloadId")
                downloadList[downloadId] = it
            }
        }.onFailure {
            Log.d(TAG, "error occur in download method : ${it.message}")
            downloads.forEach { id ->
                manager.remove(id)
            }
            throw it
        }
    }

    private fun getProgress(id: Long) {
        val query = DownloadManager.Query().setFilterById(id)
        val cursor = manager.query(query)
        val task = downloadList[id]!!
        if (cursor.moveToFirst()) {
            cursor.use {
                Log.d(TAG, "id : ${task.fileName} state : ${it.statusString()}")
                if (it.status() == DownloadManager.STATUS_RUNNING) {
                    Log.d(TAG, "id : $id downloading : ${it.progress()}")
                    running(
                        id,
                        task.listenerId,
                        it.progress(),
                        downloadList[id]?.id ?: "unknown"
                    )
                }
            }
        }
    }

    private fun checkRegister(result: MethodChannel.Result): Boolean {
        return if (flowJob == null && receiver == null && observer == null) {
            configDownload(result)
        } else if (flowJob != null && receiver != null && observer != null) {
            true
        } else {
            kotlin.runCatching {
                stopAllAndRemoveRegister()
                if (flowJob == null && receiver == null && observer == null && configDownload(result)) {
                    true
                } else {
                    throw Exception("refresh registers failure")
                }
            }.onFailure {
                result.error(REGISTER_OBSERVER_ERROR, "retry register error : ${it.message}", "")
            }.isSuccess
        }
    }

    private fun configDownload(result: MethodChannel.Result): Boolean {
        return kotlin.runCatching {
            flowJob = mainScope.launch(handler) {
                downloadProgress.collect { task ->
                    when (task.status) {
                        Status.BEGIN -> {
                            takeIf { downloadList.isNotEmpty() }?.let {
                                val report =
                                    mapOf("listenerId" to task.listenerId, "state" to "BEGIN")
                                updateProgress(report)
                            }
                        }
                        Status.SUCCESS -> {
                            reportSuccess(task)
                            downloadList.remove(task.id)
                            if (downloadList.filter { it.value.listenerId == task.listenerId }
                                    .isEmpty()) {
                                // 所有的都下载完了就清除注册的接收器
                                reportAllSuccess(task.listenerId)
                                try {
                                    stopAllAndRemoveRegister()
                                } catch (e: Throwable) {
                                    reportError(
                                        task.listenerId,
                                        REMOVE_REGISTER_ERROR,
                                        "remove register error when complete download :${e.message}"
                                    )
                                }
                            }
                        }
                        Status.RUNNING -> {
                            reportRunning(task)
                        }
                        Status.FAILURE -> {
                            // 清除临时文件，保留下载好的文件
                            kotlin.runCatching {
                                downloadList[task.id]?.let {
                                    clearTemporaryFiles(listOf(it))
                                }
                            }.onFailure { throwable ->
                                Log.d(
                                    TAG,
                                    "delete apk error when get failure state: ${throwable.message}"
                                )
                            }
                            downloadList.remove(task.id)
                            reportError(
                                task.listenerId,
                                DOWNLOAD_ERROR,
                                "download ${task.taskId} error: ${task.message}"
                            )
                        }
                    }
                }
            }
            receiver = CompleteReceiver().also {
                context.registerReceiver(
                    it,
                    IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE)
                )
            }
            observer = DownloadChangeObserver(Handler(Looper.getMainLooper())).also {
                context.contentResolver?.registerContentObserver(
                    Uri.parse("content://downloads/my_downloads"),
                    true,
                    it
                )
            }
        }.onFailure {
            stopAllAndRemoveRegister()
            result.error(CONFIG_DOWNLOAD_ERROR, "config download error : ${it.message}", "")
        }.onSuccess {
            Log.d(TAG, "configDownload success")
        }.isSuccess
    }

    // 下载完成接收器  每次下载完都会接收到一次，所以接收到之后从列表中删除对应项
    inner class CompleteReceiver : BroadcastReceiver() {
        override fun onReceive(
            context: Context,
            intent: Intent
        ) {
            val completeId =
                intent.getLongExtra(DownloadManager.EXTRA_DOWNLOAD_ID, 0)
            if (downloadList.containsKey(completeId)) {
                val item = downloadList[completeId]!!
                kotlin.runCatching {
                    val downloadQuery = DownloadManager.Query()
                    downloadQuery.setFilterById(completeId)
                    manager.query(downloadQuery)?.let {
                        // warning： 万万不能在任务结束后获取任务的大小，会直接崩溃
                        if (it.moveToFirst()) {
                            when (it.status()) {
                                DownloadManager.STATUS_SUCCESSFUL -> {
                                    downloadDirectory?.let { directory ->
                                        val from = File(directory, item.temporaryPath())
                                        val to = File(directory, item.path())
                                        if (from.renameTo(to)) {
                                            // 文件下载完后发送信息并从下载列表中删除
                                            success(
                                                completeId,
                                                item.listenerId,
                                                to.path,
                                                item.id
                                            )
                                        }
                                    }
                                }
                                else -> {
                                    failure(
                                        completeId,
                                        item.listenerId,
                                        1.0,
                                        "download apk fail , progress : 1.0 , state : ${it.status()}",
                                        item.id
                                    )
                                }
                            }
                        }
                        it.close()
                    }
                }.onFailure {
                    failure(
                        completeId,
                        item.listenerId,
                        1.0,
                        "handling error on receive broadcast : ${it.message}",
                        item.id
                    )
                }
            }
        }
    }

    inner class DownloadChangeObserver(handler: Handler?) : ContentObserver(handler) {
        private var onChangeCount = 0

        private val progressList = mutableMapOf<Long, Double>()

        override fun onChange(selfChange: Boolean) {
            kotlin.runCatching {
                downloadList.forEach { task ->
                    manager.query(DownloadManager.Query().setFilterById(task.key))
                        .takeIf { it.moveToFirst() }?.let {
                            if (it.status() == DownloadManager.STATUS_RUNNING && progressList[task.key] != it.progress()) {
                                progressList[task.key] = it.progress()
                                Log.d(
                                    TAG,
                                    "id : ${task.key} downloading : ${it.progress()} onChangeCount : $onChangeCount"
                                )
                                if (it.progress() == 0.0) {
                                    begin(task.key, task.value.listenerId, task.value.id)
                                } else {
                                    running(
                                        task.key,
                                        task.value.listenerId,
                                        it.progress(),
                                        task.value.id
                                    )
                                }
                            }else {
                                Log.d(
                                    TAG,
                                    "id : ${task.value.fileName} downloading : ${it.progress()} state : ${it.statusString()}"
                                )
                            }
                        }
                }
                onChangeCount++
            }.onFailure {
                Log.d(TAG, "DownloadChangeObserver onChange : $it")
                failure(0, "all", 0.0, "onChange error : ${it.message}", "all")
            }
        }
    }

    @Suppress("unused")
    private fun begin(id: Long, listenerId: String, taskId: String) {
        mainScope.launch(handler) {
            downloadProgress.emit(Progress(id = id, listenerId, Status.BEGIN, 0.0, taskId))
        }
    }

    private fun success(id: Long, listenerId: String, path: String, taskId: String) {
        mainScope.launch(handler) {
            downloadProgress.emit(
                Progress(
                    id,
                    listenerId,
                    Status.SUCCESS,
                    1.0,
                    taskId,
                    path = path
                )
            )
        }
    }

    private fun running(id: Long, listenerId: String, progress: Double, taskId: String) {
        mainScope.launch(handler) {
            downloadProgress.emit(Progress(id, listenerId, Status.RUNNING, progress, taskId))
        }
    }

    private fun failure(
        id: Long,
        listenerId: String,
        progress: Double,
        errorDetail: String,
        taskId: String
    ) {
        mainScope.launch(handler) {
            downloadProgress.emit(
                Progress(
                    id,
                    listenerId,
                    Status.FAILURE,
                    progress,
                    taskId = taskId,
                    message = errorDetail
                )
            )
        }
    }

    /// 默认删除下载列表中的临时文件
    private fun clearTemporaryFiles(list: List<DownloadItem>) {
        downloadDirectory?.let { directory ->
            list.forEach { task ->
                val path = directory.path + File.separator + task.temporaryPath()
                File(path).takeIf { it.exists() }?.delete()
            }
        }
    }

    // 只要不存在这个文件，就当成没有下载，然后将剩下的文件加入到下载列表中，在加入下载列表时过滤
    private fun filterDownloadFiles(list: List<DownloadItem>): List<DownloadItem> {
        val finishList = mutableListOf<DownloadItem>()
        val notFinishList = mutableListOf<DownloadItem>()
        downloadDirectory?.let { directory ->
            list.forEach {
                val path = directory.path + File.separator + it.path()
                if (File(path).exists()) {
                    finishList.add(it)
                    Log.d(TAG, "item has download : $it   path : $path")
                } else {
                    notFinishList.add(it)
                }
            }

            for (task in finishList) {
                reportSuccess(task)
            }

            if (notFinishList.isEmpty()) {
                Log.d(TAG, "all files download : $list")
            }
        }
        Log.d(TAG, "finish list : $finishList")
        Log.d(TAG, "not finish list : $notFinishList")
        return notFinishList
    }

    companion object {
        const val TAG = "WBY_DOWNLOAD"

        // 添加下载任务时会出现的错误
        const val PARSE_ARGUMENT_ERROR = "PARSE_ARGUMENT_ERROR"
        const val CONFIG_DOWNLOAD_ERROR = "CONFIG_DOWNLOAD_ERROR"
        const val REGISTER_OBSERVER_ERROR = "REGISTER_OBSERVER_ERROR"
        const val ADD_TASKS_ERROR = "ADD_TASKS_ERROR"

        // 下载过程中可能出现的错误
        const val REMOVE_REGISTER_ERROR = "REMOVE_REGISTER_ERROR"
        const val DOWNLOAD_ERROR = "DOWNLOAD_ERROR"
    }
}

fun Cursor.status(): Int {
    return getInt(getColumnIndexOrThrow(DownloadManager.COLUMN_STATUS))
}

fun Cursor.statusString(): String {
    return when (status()) {
        DownloadManager.STATUS_RUNNING -> "STATUS_RUNNING"
        DownloadManager.STATUS_PAUSED -> "STATUS_PAUSED"
        DownloadManager.STATUS_FAILED -> "STATUS_FAILED"
        DownloadManager.STATUS_SUCCESSFUL -> "STATUS_SUCCESSFUL"
        DownloadManager.STATUS_PENDING -> "STATUS_PENDING"
        else -> "unknown status"
    }
}

fun Cursor.currentSize(): Double {
    return getInt(getColumnIndexOrThrow(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR))
        .toDouble()
}

fun Cursor.totalSize(): Double {
    return getInt(getColumnIndexOrThrow(DownloadManager.COLUMN_TOTAL_SIZE_BYTES))
        .toDouble()
}

fun Cursor.progress(): Double {
    return currentSize() / totalSize()
}