package com.twt.service.download

import androidx.annotation.Keep
import java.io.File

/**
 * flutter 端提供的下载列表
 */
@Keep
data class DownloadList(
    val list: List<DownloadTask>
)

/**
 * 下载任务信息
 */
@Keep
data class DownloadTask(
    /**
     * 下载地址
     */
    val url: String,

    /**
     * 文件名
     */
    val fileName: String,

    /**
     * 是否显示 DownloadManager 的下载通知
     */
    val showNotification: Boolean,

    /**
     * 文件路径
     */
    val path: String,

    /**
     * 单个下载任务的id
     */
    val id: String,

    /**
     * flutter端本次全部下载任务的监听器 id
     */
    val listenerId: String,

    /**
     * 下载通知的title
     */
    val title: String?,

    /**
     * 下载通知的描述
     */
    val description: String?,
)

/**
 * 临时文件相对地址
 */
fun DownloadTask.temporaryPath(): String {
    return "$path.temp"
}

private fun String.relativeToDownloadDir(downloadDir: File): String {
    val root = downloadDir.absolutePath.trimEnd(File.separatorChar) + File.separator
    return File(this).absolutePath.removePrefix(root)
}

fun DownloadTask.temporarySubPath(downloadDir: File): String {
    return temporaryPath().relativeToDownloadDir(downloadDir)
}

fun DownloadTask.subPath(downloadDir: File): String {
    return path.relativeToDownloadDir(downloadDir)
}

fun DownloadTask.baseData(): MutableMap<String, Any> {
    return mutableMapOf(
        "id" to id,
        "listenerId" to listenerId,
    )
}
