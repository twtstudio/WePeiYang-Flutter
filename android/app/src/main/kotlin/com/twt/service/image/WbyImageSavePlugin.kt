package com.twt.service.image

import android.os.Environment
import com.twt.service.common.LogUtil
import com.twt.service.common.WbyPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import okhttp3.*
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

// 1. 通过 url 保存图片
// 2. 通过 path 保存图片
class WbyImageSavePlugin : WbyPlugin() {

    override val name: String
        get() = "com.twt.service/saveImg"

    private val imgDir by lazy { context.getExternalFilesDir(Environment.DIRECTORY_PICTURES) }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "savePictureToAlbum" -> savePictureToAlbum(call, result)
            "savePictureFromUrl" -> savePictureFromUrl(call, result)
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
            // TODO: path如果一样怎么办？
            val saveToAlbum = call.argument<Boolean>("album") ?: false
            if (url == null) {
                result.error("", "url is null", null)
                return
            }
            val fileName = call.argument<String>("fileName") ?: url.split("/").last()

            val path = File(imgDir, fileName).path

            val request = Request.Builder().url(url).build()
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
                    if (saveToAlbum) {
                        ImageSave.savePictureToAlbum(context, path)
                    }
                    CoroutineScope(Dispatchers.Main).launch {
                        result.success(path)
                    }
                }
            })
        }.onFailure {
            result.error("", it.message, "$it")
        }
    }


    companion object {
        const val TAG = "SAVE_IMAGE"
        fun log(message: String) = LogUtil.d(TAG, message)
    }
}