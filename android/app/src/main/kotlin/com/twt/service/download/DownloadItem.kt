package com.twt.service.download

data class DownloadList(
        val list: List<DownloadItem>
)

data class DownloadItem(
        val url: String,
        val fileName: String,
        val title: String,
        val showNotification: Boolean,
        var temporaryName:String?,
)