package com.twt.service.wechat

import android.app.Activity
import android.net.Uri
import android.util.Log
import com.jarvan.fluwx.handlers.FluwxRequestHandler
import com.jarvan.fluwx.handlers.WXAPiHandler
import com.tencent.mm.opensdk.modelbase.BaseReq
import com.tencent.mm.opensdk.modelmsg.LaunchFromWX
import com.tencent.mm.opensdk.modelmsg.SendMessageToWX
import com.tencent.mm.opensdk.modelmsg.ShowMessageFromWX
import com.tencent.mm.opensdk.modelmsg.WXAppExtendObject
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage
import com.twt.service.common.WbyPlugin
import com.twt.service.message.EventDispatcher
import com.twt.service.push.IntentEvent
import com.twt.service.push.model.Event
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Experimental TYPE_APPDATA sharing; sendReq success is not proof of app launch. */
class WbyWechatTestPlugin : WbyPlugin() {
    override val name = "com.twt.service/wechat_test"

    private val requestHandler: (BaseReq, Activity) -> Unit = { request, _ ->
        handleRequest(request)
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        super.onAttachedToEngine(binding)
        FluwxRequestHandler.customOnReqDelegate = requestHandler
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        if (FluwxRequestHandler.customOnReqDelegate === requestHandler) {
            FluwxRequestHandler.customOnReqDelegate = null
        }
        super.onDetachedFromEngine(binding)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "shareAppMessage") {
            result.notImplemented()
            return
        }
        val postId = call.argument<Number>("postId")?.toLong()
        if (postId == null || postId <= 0 || postId > Int.MAX_VALUE) {
            result.error("invalid_post_id", "Invalid post id", null)
            return
        }
        val api = WXAPiHandler.wxApi
        if (api == null || !WXAPiHandler.wxApiRegistered) {
            result.error("wechat_not_registered", "Register WeChat first", null)
            return
        }
        if (!api.isWXAppInstalled) {
            result.error("wechat_not_installed", "WeChat is not installed", null)
            return
        }
        try {
            val appUrl = "wpy://wpy.app/post?id=$postId"
            val media = WXAppExtendObject().apply {
                extInfo = appUrl
                // Small app payload, not a webpage or a downloadable post archive.
                fileData = "{\"postId\":$postId}".toByteArray(Charsets.UTF_8)
            }
            val thumbnail = call.argument<ByteArray>("thumbnail")
            if (thumbnail != null && thumbnail.size > 32 * 1024) {
                result.error("thumbnail_too_large", "Thumbnail exceeds 32KB", null)
                return
            }
            val message = WXMediaMessage(media).apply {
                title = truncateUtf8(call.argument<String>("title") ?: "微北洋求实论坛", 512)
                description = truncateUtf8(call.argument<String>("description") ?: "", 1024)
                messageExt = appUrl
                thumbData = thumbnail
            }
            val request = SendMessageToWX.Req().apply {
                transaction = "wpy_app_test_${System.currentTimeMillis()}"
                scene = SendMessageToWX.Req.WXSceneSession
                this.message = message
            }
            if (!request.checkArgs()) {
                result.error("invalid_wechat_message", "WeChat SDK rejected message arguments", null)
                return
            }
            val sent = api.sendReq(request)
            diagnostic("TYPE_APPDATA postId=$postId sendReq=$sent; awaiting WeChat response")
            result.success(sent)
        } catch (error: Exception) {
            diagnostic("TYPE_APPDATA failed: ${error.javaClass.simpleName}: ${error.message}")
            result.error("wechat_app_message_failed", error.message, null)
        }
    }

    private fun handleRequest(request: BaseReq) {
        val postId = when (request) {
            is ShowMessageFromWX.Req -> {
                val media = request.message?.mediaObject as? WXAppExtendObject
                postIdFromUrl(media?.extInfo) ?: postIdFromUrl(request.message?.messageExt)
            }
            is LaunchFromWX.Req -> postIdFromUrl(request.messageExt)
            else -> null
        }
        diagnostic("WeChat onReq type=${request.type} postId=$postId")
        if (postId != null) {
            EventDispatcher.enqueueEvent(
                Event(IntentEvent.FeedbackPostPage.type, postId),
                setOf(IntentEvent.FeedbackPostPage.type),
            )
        }
    }

    private fun diagnostic(message: String) {
        Log.i("WBY_WeChatTest", message)
        channel.invokeMethod("diagnostic", message)
    }

    private fun postIdFromUrl(value: String?): Int? = runCatching {
        if (value.isNullOrBlank()) return@runCatching null
        val uri = Uri.parse(value)
        if (uri.scheme != "wpy" || uri.host != "wpy.app" || uri.path != "/post") {
            return@runCatching null
        }
        uri.getQueryParameter("id")?.toIntOrNull()?.takeIf { it > 0 }
    }.getOrNull()

    private fun truncateUtf8(value: String, maxBytes: Int): String {
        val text = StringBuilder()
        var offset = 0
        var bytes = 0
        while (offset < value.length) {
            val codePoint = value.codePointAt(offset)
            val part = String(Character.toChars(codePoint))
            val partBytes = part.toByteArray(Charsets.UTF_8).size
            if (bytes + partBytes > maxBytes) break
            text.append(part)
            bytes += partBytes
            offset += Character.charCount(codePoint)
        }
        return text.toString()
    }
}
