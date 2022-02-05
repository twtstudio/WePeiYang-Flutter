package com.twt.service.share

import android.app.Activity
import android.os.Bundle
import android.util.Log
import androidx.annotation.Keep
import com.tencent.connect.share.QQShare
import com.tencent.tauth.IUiListener
import com.tencent.tauth.Tencent
import com.tencent.tauth.UiError
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

@Keep
data class QQShareData(
    val targetUrl: String = "",
    val summary: String = "",
    val imageUrl: String = "",
    val title: String = "",
    val appName: String = "",
    val mExtraFlag: Int = 0,
    val type: Int = 0,
    val questionId: Int = 0,
)

class QQFactory(
    private val mTencent: Tencent,
    private val activity: Activity,
    private val listener: IUiListener
) {

    fun share(call: MethodCall) {
        QQShareData(
            targetUrl = call.argument<String>("targetUrl")
                ?: "https://239what475.github.io/index.html",
            summary = call.argument<String>("summary") ?: "测试内容",
            imageUrl = call.argument<String>("imageUrl")
                ?: "http://y.gtimg.cn/music/photo_new/T002R300x300M000003KIU6V02sS7C.jpg?max_age=2592000",
            title = call.argument<String>("title") ?: "测试",
            appName = "微北洋",
            type = QQShare.SHARE_TO_QQ_TYPE_DEFAULT,
            questionId = call.argument<Int>("id") ?: 5528,
        ).let {
            shareToQQ(it)
        }
    }

    fun shareImg(call: MethodCall) {
        call.argument<String>("path")?.let {
            QQShareData(
                imageUrl = it,
                title = call.argument<String>("title") ?: "大图分享",
                appName = "微北洋",
                type = QQShare.SHARE_TO_QQ_TYPE_IMAGE,
            ).let { data ->
                WbySharePlugin.log("share data: $data");
                shareToQQ(data)
            }
        }
    }

    private fun shareToQQ(data: QQShareData) {
        val params = Bundle().apply {
            if (data.type != QQShare.SHARE_TO_QQ_TYPE_IMAGE) {
                putString(
                    QQShare.SHARE_TO_QQ_TARGET_URL,
                    "${data.targetUrl}?questionId=${data.questionId}"
                )
                putString(QQShare.SHARE_TO_QQ_SUMMARY, data.summary)
                putString(QQShare.SHARE_TO_QQ_IMAGE_URL, data.imageUrl)
            } else {
                putString(QQShare.SHARE_TO_QQ_IMAGE_LOCAL_URL, data.imageUrl)
            }
            putString(QQShare.SHARE_TO_QQ_APP_NAME, data.appName)
            putString(QQShare.SHARE_TO_QQ_TITLE, data.title)
            putInt(QQShare.SHARE_TO_QQ_KEY_TYPE, data.type)
            putInt(QQShare.SHARE_TO_QQ_EXT_INT, data.mExtraFlag)
        }
        Log.d("WBY", params.toString())

        // 在这里配置好像是只有错误回调会触发，如果想要完成回调触发那么就选择 activityResult
        mTencent.shareToQQ(activity, params, listener)
    }


}