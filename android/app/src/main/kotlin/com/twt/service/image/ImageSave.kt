package com.twt.service.image

import android.content.ContentValues
import android.content.Context
import android.media.MediaScannerConnection
import android.os.Build
import android.provider.MediaStore
import java.io.File

object ImageSave {
    fun savePictureToAlbum(context: Context, filePath: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android Q把文件插入到系统图库
            val values = ContentValues()
            val file = File(filePath)
            WbyImageSavePlugin.log("path : $filePath")
            values.put(MediaStore.Images.Media.DESCRIPTION, "This is an qr image")
            values.put(MediaStore.Images.Media.DISPLAY_NAME, file.name)
            values.put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
            values.put(MediaStore.Images.Media.TITLE, "Image.jpg")
            values.put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/微北洋")

            val external = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            val resolver = context.contentResolver
            val uri = resolver.insert(external, values)
            uri?.let {
                file.inputStream().use { input ->
                    resolver.openOutputStream(it).use { output ->
                        output?.let {
                            input.copyTo(it)
                        }
                    }
                }
            }
        } else {
            MediaScannerConnection(context, null).apply {
                connect()
                if (isConnected) {
                    scanFile(filePath, "image/jpeg")
                }
            }
        }
    }
}