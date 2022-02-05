package com.twt.service.image

import android.content.Context
import android.os.Environment
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.*
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

// 1. 通过 url 保存图片
// 2. 通过 path 保存图片
class WbyImageSavePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var context: Context
    private lateinit var imgSaveChannel: MethodChannel
    private val imgDir by lazy { context.getExternalFilesDir(Environment.DIRECTORY_PICTURES) }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        imgSaveChannel = MethodChannel(
            binding.binaryMessenger, "com.twt.service/saveImg"
        )
        imgSaveChannel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        imgSaveChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "savePictureToAlbum" -> savePictureToAlbum(call,result)
            "savePictureFromUrl" -> savePictureFromUrl(call,result)
        }
    }

    private fun savePictureToAlbum(call: MethodCall, result: MethodChannel.Result) {
        runCatching {
            val path = call.argument<String>("path")
            if (path == null) {
                result.error("", "path is null", null)
                return
            }
            ImageSave.savePictureToAlbum(context, path)
            result.success("success")
        }.onFailure {
            result.error("", it.message, "$it")
        }
    }

    private fun savePictureFromUrl(call: MethodCall, result: MethodChannel.Result) {
        runCatching {
            val url = call.argument<String>("url")
            var path = call.argument<String>("path")
            val saveToAlbum = call.argument<Boolean>("album") ?: false
            if (url == null) {
                result.error("", "url is null", null)
                return
            }

            if (path == null && "[0-9a-zA-Z].jpg$".toRegex().containsMatchIn(url)) {
                path = File(imgDir, url.split("/").last()).path
            }

            if (path == null) {
                result.error("", "path is null", null)
                return
            }

            call.argument<String>("url")?.let {
                val request = Request.Builder().url(it).build()
                OkHttpClient().newCall(request).enqueue(object : Callback {
                    override fun onFailure(call: Call, e: IOException) {
                        result.error("", e.message, "$e")
                    }

                    override fun onResponse(call: Call, response: Response) {
                        response.body?.byteStream()?.let { input ->
                            FileOutputStream(path).use { output ->
                                input.copyTo(output)
                                output.flush()
                            }
                        }
                        if (saveToAlbum){
                            ImageSave.savePictureToAlbum(context,path)
                        }
                        CoroutineScope(Dispatchers.Main).launch {
                            result.success(path)
                        }
                    }
                })
            }
        }.onFailure {
            result.error("", it.message, "$it")
        }
    }


    companion object {
        const val TAG = "WBY_SAVE_IMAGE"
    }
}