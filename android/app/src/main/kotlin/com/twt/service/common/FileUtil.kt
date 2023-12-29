package com.twt.service.common

import android.content.Context
import android.os.Environment
import java.io.File

object FileUtil {
    fun downloadDirectory(context: Context): File {
        return context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)
    }

    fun fixDirectory(context: Context): File {
        return File(context.filesDir, "hotfix").apply {
            if (!exists()) mkdir()
        }
    }
}