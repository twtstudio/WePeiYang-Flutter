package com.twt.service.common

import android.content.Intent
import android.net.Uri
import com.google.gson.Gson
import com.igexin.sdk.message.GTTransmitMessage
import com.twt.service.push.WbyPushPlugin

const val BASEURL = "twtstudio://weipeiyang.app/"

// 这么写的原因是： sendBroadcast 中有 intentFilter.matchData 中要求至少要有 scheme
// 所以在 data 前添加一段url 不然无法识别
object IntentUtil {
    fun messageData(data: GTTransmitMessage): Intent {
        val uri = Uri.parse("${BASEURL}push?")
        val intent = Intent(WbyPushPlugin.DATA, uri)
        intent.putExtra("data", Gson().toJson(data))
        return intent
    }

    fun cid(cid: String): Intent {
        val uri = Uri.parse("${BASEURL}cid?")
        val intent = Intent(WbyPushPlugin.DATA)
        intent.putExtra("cid", cid)
        return Intent(WbyPushPlugin.CID, uri)
    }
}

enum class IntentEvent(val type: Int) {
    FeedbackPostPage(1),
    MailBox(3),
    SchedulePage(4),
    Update(5),
}