package com.twt.service.download

import android.app.DownloadManager
import android.database.Cursor

fun Cursor.status(): Int {
    return try {
        getInt(getColumnIndexOrThrow(DownloadManager.COLUMN_STATUS))
    } catch (_: Throwable) {
        -1
    }
}

fun Cursor.reason(): Int {
    return try {
        getInt(getColumnIndexOrThrow(DownloadManager.COLUMN_REASON))
    } catch (_: Throwable) {
        -1
    }
}

private fun Cursor.currentSize(): Double {
    return getInt(getColumnIndexOrThrow(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR))
        .toDouble()
}

private fun Cursor.totalSize(): Double {
    return getInt(getColumnIndexOrThrow(DownloadManager.COLUMN_TOTAL_SIZE_BYTES))
        .toDouble()
}

fun Cursor.progress(): Double {
    return try {
        currentSize() / totalSize()
    } catch (_: Throwable) {
        0.0
    }
}