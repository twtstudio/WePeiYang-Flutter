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
    private val downloadProgress = MutableStateFlow(Progress(0, State.BEGIN, 0.0, ""))
    private lateinit var manager: DownloadManager
    private var flowJob: Job? = null
    private var observer: ContentObserver? = null
    private var receiver: BroadcastReceiver? = null
    private var downloadList = mutableMapOf<Long, DownloadItem>()
    private val downloadDirectory by lazy {
        context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)
    }

    private val handler = CoroutineExceptionHandler { _, throwable ->
        reportError(FLOW_ERROR, throwable.message)
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "com.twt.service/download")
        channel.setMethodCallHandler(this)
        manager = context.getSystemService(Activity.DOWNLOAD_SERVICE) as DownloadManager
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun updateProgress(report: Map<*, *>) {
        Log.d(TAG,report.toString())
        channel.invokeMethod("updateProgress", report)
    }

    private fun reportError(code: String, message: String?) {
        val report = mapOf("state" to "ERROR","code" to code, "message" to message)
        updateProgress(report)
    }

    private fun stopAllDownload() {
        downloadList.forEach {
            manager.remove(it.key)
        }
    }

    private fun removeRegister() {
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
                if (checkRegister(result)){
                    kotlin.runCatching {
                        val data = call.argument<String>("downloadList")
                        Gson().fromJson(data, DownloadList::class.java).apply {
                            list.map { it.temporaryName = it.fileName + ".temporary" }
                        }.list
                    }.onSuccess {
                        addDownloadTask(it.toMutableList(), result)
                    }.onFailure {
                        result.error(PARSE_ARGUMENT_ERROR, "parse argument error", "")
                    }
                }
            }
            "forceDispose" -> {
                kotlin.runCatching {
                    stopAllDownload()
                    removeRegister()
                }.onFailure {
                    result.error("", "", "")
                }.onSuccess {
                    result.success("")
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun addDownloadTask(list: MutableList<DownloadItem>, result: MethodChannel.Result) {
        kotlin.runCatching {
            // 将已经有了的文件过滤
            if (checkAllFilesDownload(list)) {
                val report = mapOf("state" to "ALL_SUCCESS")
                updateProgress(report)
            } else {
                // 清除之前没有下载完的临时文件(下载任务中的)
                kotlin.runCatching {
                    clearTemporaryFiles()
                }.onFailure {
                    Log.d(TAG, "delete apk error when PRE INIT : ${it.message}")
                }
                download(list)
            }
        }.onFailure {
            // checkAllFilesDownload
            result.error(CHECK_FILES_ERROR, "start download apk error", "")
        }.onSuccess {
            result.success("add download tasks success")
        }
    }

    private fun download(list: List<DownloadItem>) {
        val downloads = mutableListOf<Long>()
        kotlin.runCatching {
            for (item in list) {
                val request = DownloadManager.Request(Uri.parse(item.url)).apply {
                    setTitle(item.title)
                    setDescription("File is downloading...")
                    setDestinationInExternalFilesDir(
                            context,
                            Environment.DIRECTORY_DOWNLOADS,
                            item.temporaryName,
                    )
                    if (item.showNotification) {
                        setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
                    } else {
                        setNotificationVisibility(DownloadManager.Request.VISIBILITY_HIDDEN)
                    }
                }
                val downloadId = manager.enqueue(request)
                downloads.add(downloadId)
                Log.d(TAG, "add $item into queue , id : $downloadId")
                downloadList[downloadId] = item
            }
        }.onFailure {
            downloads.forEach {
                manager.remove(it)
            }
        }
    }

    private fun checkRegister(result: MethodChannel.Result): Boolean {
        if (flowJob == null && receiver == null && observer == null) {
            configDownload(result)
            return true
        } else if (flowJob != null && receiver != null && observer != null) {
            return true
        } else {
            return kotlin.runCatching {
                stopAllDownload()
                removeRegister()
            }.onSuccess {
                configDownload(result)
            }.onFailure {
                result.error("", "", "")
            }.isSuccess
        }
    }

    private fun configDownload(result: MethodChannel.Result) {
        kotlin.runCatching {
            flowJob = mainScope.launch(handler) {
                downloadProgress.collect {
                    when (it.state) {
                        // TODO: 这个暂时还没有
                        State.BEGIN -> {
                            val report = mapOf("state" to "BEGIN")
                            updateProgress(report)
                        }
                        State.SUCCESS -> {
                            val report = mapOf("state" to "SUCCESS", "fileName" to it.fileName, "path" to it.path)
                            updateProgress(report)

                            if (downloadList.isEmpty()) {
                                // 所有的都下载完了就清除注册的接收器
                                removeRegister()
                                val allSuccess = mapOf("state" to "ALL_SUCCESS")
                                updateProgress(allSuccess)
                            }
                        }
                        State.RUNNING -> {
                            val report = mapOf("state" to "RUNNING", "fileName" to it.fileName, "progress" to it.progress)
                            updateProgress(report)
                        }
                        State.FAILURE -> {
                            // 清除临时文件，保留下载好的文件
                            kotlin.runCatching {
                                clearTemporaryFiles()
                            }.onFailure { throwable ->
                                Log.d(TAG, "delete apk error when get failure state: ${throwable.message}")
                            }
                            stopAllDownload()
                            reportError(DOWNLOAD_ERROR, "download ${it.fileName} error: ${it.message}")
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
            observer = DownloadChangeObserver(null).also {
                context.contentResolver?.registerContentObserver(
                        Uri.parse("content://downloads/my_downloads"),
                        true,
                        it
                )
            }
        }.onFailure {
            removeRegister()
            result.error(CONFIG_DOWNLOAD_ERROR, "", "")
        }
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
                            when (it.state()) {
                                DownloadManager.STATUS_SUCCESSFUL -> {
                                    downloadDirectory?.let { directory ->
                                        val from = File(directory, item.temporaryName!!)
                                        val to = File(directory, item.fileName)
                                        if (from.renameTo(to)) {
                                            // 文件下载完后发送信息并从下载列表中删除
                                            success(completeId, to.path, item.fileName)
                                        }
                                    }
                                }
                                else -> {
                                    failure(completeId, 1.0, "download apk fail , progress : 1.0 , state : ${it.state()}", item.fileName)
                                }
                            }
                        }
                        it.close()
                    }
                }.onFailure {
                    failure(completeId, 1.0, "handling error on receive broadcast : ${it.message}", item.fileName)
                }
            }
        }
    }

    // TODO : 这里好像有重复onchange的问题
    inner class DownloadChangeObserver(handler: Handler?) : ContentObserver(handler) {
        override fun onChange(selfChange: Boolean) {
            kotlin.runCatching {
                downloadList.keys.forEach { id ->
                    val query = DownloadManager.Query().setFilterById(id)
                    val cursor = manager.query(query)
                    if (cursor.moveToFirst()) {
                        cursor.use {
                            Log.d(TAG, "id : $id state : ${it.state()}")
                            if (it.state() == DownloadManager.STATUS_RUNNING) {
                                Log.d(TAG, "id : $id downloading : ${it.progress()}")
                                running(id, it.progress(), downloadList[id]?.fileName ?: "unknown")
                            }
                        }
                    }
                }
            }.onFailure {
                failure(0, 0.0, "onChange error", "")
            }
        }
    }

    // 下载完成后从下载列表中删除
    private fun success(id: Long, path: String, name: String) {
        downloadList.remove(id)
        mainScope.launch(handler) {
            downloadProgress.emit(Progress(id, State.SUCCESS, 1.0, name, path = path))
        }
    }

    private fun running(id: Long, progress: Double, name: String) {
        mainScope.launch(handler) {
            downloadProgress.emit(Progress(id, State.RUNNING, progress, name))
        }
    }

    private fun failure(id: Long, progress: Double, errorDetail: String, name: String) {
        mainScope.launch(handler) {
            downloadProgress.emit(Progress(id, State.FAILURE, progress, fileName = name, message = errorDetail))
        }
    }

    /// 默认删除临时文件
    private fun clearTemporaryFiles(extension: String = "temporary") {
        downloadDirectory?.listFiles()?.let { files ->
            for (file in files) {
                if (!downloadList.values.map { it.fileName }.find { file.nameWithoutExtension.startsWith(it) }.isNullOrEmpty() && file.extension.endsWith(extension)) {
                    file.delete()
                }
            }
        }
    }

    private fun checkAllFilesDownload(list: MutableList<DownloadItem>): Boolean {
        downloadDirectory?.let { directory ->
            val allDownload = list.map {
                val path = directory.path + File.separator + it.fileName
                val file = File(path)
                val exist = file.exists()
                if (exist) {
                    list.remove(it)
                    Log.d(TAG, "item has download : $it   path : ${file.path}")
                }
                return exist
            }.fold(true) { previous, next ->
                return previous && next
            }

            if (allDownload) {
                Log.d(TAG, "all files download : $list")
            }
            return allDownload
        }
        return false
    }

    companion object {
        const val TAG = "WBY_DOWNLOAD"
        const val PARSE_ARGUMENT_ERROR = "PARSE_ARGUMENT_ERROR"
        const val CHECK_FILES_ERROR = "CHECK_FILES_ERROR"
        const val CONFIG_DOWNLOAD_ERROR = "CONFIG_DOWNLOAD_ERROR"
        const val DOWNLOAD_ERROR = "DOWNLOAD_ERROR"
        const val FLOW_ERROR = "FLOW_ERROR"
    }
}

fun Cursor.state(): Int {
    return getInt(getColumnIndexOrThrow(DownloadManager.COLUMN_STATUS))
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

