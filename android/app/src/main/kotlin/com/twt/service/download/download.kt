package com.twt.service.download

import android.app.DownloadManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.database.ContentObserver
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.util.Log
import androidx.core.content.FileProvider
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.twt.service.MainActivity
import com.twt.service.WBYApplication
import io.flutter.embedding.android.FlutterFragmentActivity
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch
import java.io.File


class MyViewModel : ViewModel() {
    private val _downloadProgress = MutableStateFlow(DownloadProgress(true, 0.0))
    private val downloadProgress: StateFlow<DownloadProgress> = _downloadProgress

    lateinit var mDownloadManager: DownloadManager
    lateinit var mDownloadObserver: ContentObserver
    lateinit var mDownloadReceiver: BroadcastReceiver
    var progress = 0.0
    var downLoadId: Long? = null
    private lateinit var mFileName: String
    var flowCoroutine: Job? = null

    fun downloadApk(url: String, version: String, context: MainActivity) {
        kotlin.runCatching {
            flowCoroutine = viewModelScope.launch {
                downloadProgress.collect {
                    if (it.success) {
                        context.updateEventSink?.let { event ->
                            event.success(it.progress)
                            if (it.progress == 1.0) {
                                event.endOfStream()
                            }
                        }
                    } else {
                        endUpdateStreamWithError(
                            -1,
                            "download apk error: ${it.errorDetail}",
                            context
                        )
                    }
                }
            }

            if (checkApkHasDownload(version)) {
                Log.d("WBYDOWNLOAD", "has current apk")
                installAPK(context, version + "wby.apk")
            } else {
                // 清除之前下载的所有apk文件
                FileManager.clearDownloadDirectory(context)
                // 再重新下载最新版apk
                val coroutineExceptionHandler = CoroutineExceptionHandler { _, exception ->
                    Log.d("WBYDOWNLOAD", "Handle $exception in CoroutineExceptionHandler")
                    endUpdateStreamWithError(-1, "start download error", context)
                }
                viewModelScope.launch(coroutineExceptionHandler) {
                    val downloadManager = WBYApplication.activity?.get()
                        ?.getSystemService(FlutterFragmentActivity.DOWNLOAD_SERVICE) as DownloadManager
                    downloadApk(url, version, downloadManager, context)
                }
            }
        }.onFailure {
            Log.d("WBYDOWNLOAD", "Handle $it")
            flowCoroutine?.cancel()
            endUpdateStreamWithError(-1, "start download apk error", context)
        }
    }

    private fun endUpdateStreamWithError(
        errorCode: Int,
        errorMessage: String,
        context: MainActivity,
        errorDetails: String? = null
    ) {
        context.updateEventSink?.let {
            it.error(errorCode.toString(), errorMessage, errorDetails)
            it.endOfStream()
        }
    }

    private fun checkApkHasDownload(version: String): Boolean {
        WBYApplication.activity?.get()?.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)?.let {
            it.listFiles()?.let { files ->
                for (file in files) {
                    Log.d("WBYDOWNLOAD", file.path)
                }
            }
            Log.d("WBYDOWNLOAD", "see files ${it.path}")
            val apkPath = it.path + File.separator + version + "wby.apk"
            val apkFile = File(apkPath)
            return apkFile.exists()
        }
        return false
    }


    private fun downloadApk(
        url: String,
        version: String,
        manager: DownloadManager,
        context: MainActivity
    ) {
        mDownloadManager = manager
        mFileName = version + "wby.apk"
        mDownloadReceiver = CompleteReceiver().also {
            context.registerReceiver(
                it,
                IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE)
            )
        }
        mDownloadObserver = DownloadChangeObserver(null).also {
            context.contentResolver?.registerContentObserver(
                Uri.parse("content://downloads/my_downloads"),
                true,
                it
            )
        }
        Log.d("WBYDOWNLOAD", "start")
        val request = DownloadManager.Request(Uri.parse(url)).apply {
            setTitle("微北洋")
            setDescription("File is downloading...")
            setDestinationInExternalFilesDir(
                context,
                Environment.DIRECTORY_DOWNLOADS,
                mFileName,
            )
            setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
        }
        downLoadId = manager.enqueue(request)
    }

    private fun installAPK(context: Context, fileName: String? = null) {
        try {
            context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)?.let {
                val name = fileName ?: mFileName
                val path = it.path + File.separator + name
                val file = File(path)
                val intent = Intent(Intent.ACTION_VIEW).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    if (Build.VERSION.SDK_INT >= 24) {
                        //参数1 上下文, 参数2 Provider主机地址 和配置文件中保持一致   参数3  共享的文件
                        val apkUri = FileProvider.getUriForFile(
                            context,
                            "com.twt.service.apkprovider",
                            file,
                        )
                        //添加这一句表示对目标应用临时授权该Uri所代表的文件
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        setDataAndType(apkUri, "application/vnd.android.package-archive")
                    } else {
                        setDataAndType(
                            Uri.fromFile(file),
                            "application/vnd.android.package-archive"
                        )
                    }
                }

                context.startActivity(intent)
            }
        } catch (e: Exception) {
            failure("handling error when install apk")
        }
    }

    inner class CompleteReceiver : BroadcastReceiver() {
        override fun onReceive(
            context: Context,
            intent: Intent
        ) {
            try {
                val completeDownloadId =
                    intent.getLongExtra(DownloadManager.EXTRA_DOWNLOAD_ID, -1)
                if (completeDownloadId == downLoadId) {
                    context.contentResolver.unregisterContentObserver(mDownloadObserver)
                    context.unregisterReceiver(mDownloadReceiver)
                    flowCoroutine?.cancel()
                    val myDownloadQuery = DownloadManager.Query()
                    myDownloadQuery.setFilterById(downLoadId!!)
                    getStatus(mDownloadManager.query(myDownloadQuery))
                }
            } catch (e: Exception) {
                flowCoroutine?.cancel()
                failure("handling error on receive broadcast")
            }
        }

        private fun getStatus(cursor: Cursor?){
            cursor?.let {
                if (it.moveToFirst()) {
                    getProgress(it)
                    when (status(it)) {
                        DownloadManager.STATUS_SUCCESSFUL -> {
                            Log.d("WBYDOWNLOAD", "finish")
                            success()
                        }
                        DownloadManager.STATUS_FAILED -> {
                            Log.d("WBYDOWNLOAD", "failed")
                            failure("download apk fail")
                        }
                        DownloadManager.STATUS_PAUSED -> {
                            Log.d("WBYDOWNLOAD", "paused")

                        }
                    }

                }
                it.close()
            }
        }
    }

    inner class DownloadChangeObserver(handler: Handler?) : ContentObserver(handler) {
        override fun onChange(selfChange: Boolean) {
            viewModelScope.launch {
                try {
                    val query = DownloadManager.Query().setFilterById(downLoadId!!)
                    val cursor = mDownloadManager.query(query)
                    if (cursor.moveToFirst()) {
                        cursor.use {
                            getProgress(it)
                            Log.d("WBYDOWNLOAD", "repeat $progress")
                            if (status(it) == DownloadManager.STATUS_RUNNING) {
                                success()
                            }
                        }
                    }
                } catch (e: Exception) {
                    failure("download failed at ${progress * 100}%")
                }
            }
        }
    }

    private fun getProgress(cursor: Cursor) {
        progress = currentSize(cursor) / totalSize(cursor)
    }

    private fun totalSize(cursor: Cursor): Double {
        return cursor.getInt(cursor.getColumnIndex(DownloadManager.COLUMN_TOTAL_SIZE_BYTES))
            .toDouble()
    }

    private fun currentSize(cursor: Cursor): Double {
        return cursor.getInt(cursor.getColumnIndex(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR))
            .toDouble()
    }

    private fun status(cursor: Cursor): Int {
        return cursor.getInt(cursor.getColumnIndex(DownloadManager.COLUMN_STATUS))
    }

    private fun success() {
        viewModelScope.launch {
            _downloadProgress.emit(DownloadProgress(true, progress))
        }
    }

    private fun failure(errorDetail: String) {
        viewModelScope.launch {
            _downloadProgress.emit(
                DownloadProgress(
                    false,
                    progress,
                    errorDetail
                )
            )
        }
    }
}

data class DownloadProgress(
    val success: Boolean,
    val progress: Double,
    val errorDetail: String = "",
)
