package com.twt.service

import android.os.Bundle
import android.util.Log
import com.tencent.connect.common.Constants
import com.tencent.connect.share.QQShare
import com.tencent.tauth.DefaultUiListener
import com.tencent.tauth.IUiListener
import com.tencent.tauth.UiError
import io.flutter.plugin.common.MethodCall

data class QQShareData(
    val targetUrl: String,
    val summary: String,
    val imageUrl: String,
    val title: String,
    val appName: String,
    val mExtraFlag: Int,
    val type: Int,
    val questionId:Int,
)

object QQFactory {
    private const val defaultType = QQShare.SHARE_TO_QQ_TYPE_DEFAULT

    fun share(call: MethodCall) {
        QQShareData(
            targetUrl = call.argument<String>("targetUrl")
                ?: "https://239what475.github.io/index.html",
            summary = call.argument<String>("summary") ?: "测试内容",
            imageUrl = call.argument<String>("imageUrl")
                ?: "http://y.gtimg.cn/music/photo_new/T002R300x300M000003KIU6V02sS7C.jpg?max_age=2592000",
            title = call.argument<String>("title") ?: "测试",
            appName = "微北洋",
            mExtraFlag = call.argument<Int>("mExtraFlag") ?: 0x00,
            type = call.argument<Int>("mExtraFlag") ?: defaultType,
            questionId = call.argument<Int>("id") ?: 5528,
        ).let {
            shareToQQ(it)
        }
    }

    private fun shareToQQ(data: QQShareData) {
        val params = Bundle().apply {
            putString(QQShare.SHARE_TO_QQ_TARGET_URL, "${data.targetUrl}?questionId=${data.questionId}")
            putString(QQShare.SHARE_TO_QQ_SUMMARY, data.summary)
            putString(QQShare.SHARE_TO_QQ_IMAGE_URL, data.imageUrl)
            putString(QQShare.SHARE_TO_QQ_TITLE, data.title)
            putInt(QQShare.SHARE_TO_QQ_KEY_TYPE, data.type)
            putInt(QQShare.SHARE_TO_QQ_EXT_INT, data.mExtraFlag)
        }
        Log.d("WBY", params.toString())

        WBYApplication.activity?.get()?.let {
            it.mTencent.shareToQQ(it, params, qqShareListener)
        }
    }

    private val qqShareListener: IUiListener = object : DefaultUiListener() {
        override fun onCancel() {

        }

        override fun onComplete(response: Any) {
        }

        override fun onError(e: UiError) {

        }

        override fun onWarning(code: Int) {
            if (code == Constants.ERROR_NO_AUTHORITY) {
                WBYApplication.activity?.get()?.alertDialog("onWarning: 请授权手Q访问分享的文件的读取权限!")
            }
        }
    }
}