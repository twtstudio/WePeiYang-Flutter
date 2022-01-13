package com.twt.service.imageSave

import android.content.ContentValues
import android.content.Context
import android.media.MediaScannerConnection
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.StringCodec
import java.io.File

class WbyImageSavePlugin : FlutterPlugin, BasicMessageChannel.MessageHandler<String> {
    private lateinit var context: Context
    private lateinit var imgSaveChannel: BasicMessageChannel<String>

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        imgSaveChannel = BasicMessageChannel(
            binding.binaryMessenger, "com.twt.service/saveBase64Img",
            StringCodec.INSTANCE,
        )
        imgSaveChannel.setMessageHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        imgSaveChannel.setMessageHandler(null)
    }

    override fun onMessage(message: String?, reply: BasicMessageChannel.Reply<String>) {
        message?.let {
            try {
                savePictureToAlbum(it)
                reply.reply("success")
            } catch (e: Exception) {
                reply.reply(null)
            }
        }
    }

    private fun savePictureToAlbum(filePath: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android Q把文件插入到系统图库
            val values = ContentValues()
            val file = File(filePath)
            Log.d(TAG,"path : $filePath")
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

    companion object {
        const val TAG = "WBY_SAVE_IMAGE"
    }
}