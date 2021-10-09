package com.twt.service.download

import android.content.Context
import android.os.Environment
import android.util.Log

object FileManager {
    fun clearDownloadDirectory(context: Context) {
        try {
            context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)?.let {
                it.listFiles()?.let { files ->
                    for (file in files) {
                        if (file.path.endsWith("apk")){
                            file.delete()
                        }
                    }
                }
            }
        } catch (e: Exception) {
            Log.d("WBY","delete apk error : $e")
        }
    }
}