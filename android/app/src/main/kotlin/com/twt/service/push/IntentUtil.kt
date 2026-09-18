package com.twt.service.push

import android.content.Context
import android.content.Intent
import android.net.Uri
import com.twt.service.MainActivity

const val BASEURL = "wpy://wpy.app/"

object IntentUtil {

    /**
     * 透传消息通知 broadcast intent
     */
//    fun messageData(data: String): Intent {
//        val uri = Uri.parse("${BASEURL}push?")
//        val intent = Intent(WbyPushPlugin.DATA, uri)
//        intent.putExtra("data", data)
//        return intent
//    }

    fun getQsltQuestionUri(id: Int, context: Context): String {
        return getBaseIntent(context).apply {
            data = Uri.parse("${BASEURL}post?id=$id")
            putExtra("question_id", id)
            putExtra("type", "qslt")
        }.toUri(Intent.URI_INTENT_SCHEME)
    }

    fun getQsltSummaryUri(context: Context): String {
        return getBaseIntent(context).apply {
            data = Uri.parse("${BASEURL}open?page=qslt_summary")
            putExtra("page", "summary")
            putExtra("type", "qslt")
        }.toUri(Intent.URI_INTENT_SCHEME)
    }

    fun getUpdateUri(context: Context): String {
        return getBaseIntent(context).apply {
            data = Uri.parse("${BASEURL}open?")
            putExtra("type", "update")
        }.toUri(Intent.URI_INTENT_SCHEME)
    }

    fun getBaseIntent(context: Context): Intent {
        return Intent(context, MainActivity::class.java).apply {
            setPackage(context.packageName)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
    }
}

enum class IntentEvent(val type: Int) {
    FeedbackPostPage(1),
    FeedbackSummaryPage(2),
    MailBox(3),
    SchedulePage(4),
    Update(5),
    EntryQrPage(6),
}
