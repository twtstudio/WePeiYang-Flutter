package com.twt.service.download

import androidx.annotation.Keep
import java.io.File

@Keep
data class DownloadList(
    val list: List<DownloadItem>
)

@Keep
data class DownloadItem(
    val url: String,
    val fileName: String,
    val showNotification: Boolean,
    val type: String,
    val id: String,
    val listenerId: String,
    val title: String?,
    val description: String?,
)

fun DownloadItem.path(): String {
    return type + File.separator + fileName
}

fun DownloadItem.temporaryPath(): String {
    return path() + ".temporary"
}