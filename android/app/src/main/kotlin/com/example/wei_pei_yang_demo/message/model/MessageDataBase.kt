package com.example.wei_pei_yang_demo.message.model

import android.content.Context
import android.util.Log
import androidx.core.content.edit
import com.example.wei_pei_yang_demo.WBYApplication
import com.google.gson.Gson

object MessageDataBase {

    private val sharedPreferences by lazy {
        WBYApplication.appContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    }

    private const val authTokenKey = "flutter.token"
    private const val feedbackTokenKey = "flutter.feedbackToken"
    private const val feedbackMessageCountKey = "flutter.feedbackMessageCount"
    private const val feedbackMessageListKey = "flutter.feedbackMessageList"

    val authToken: String?
        get() = sharedPreferences.getString(authTokenKey, "null").also {
            Log.d("WBYTOKEN", it.toString())
        }

    val feedbackToken: String?
        get() = sharedPreferences.getString(feedbackTokenKey, "null").also {
            Log.d("WBYFEEDBACKTOKEN", it.toString())
        }

    var feedbackMessageCount: Int
        get() = sharedPreferences.getInt(feedbackMessageCountKey, 0).also {
            Log.d("WBYFEEDBACKMESSAGECOUNT", it.toString())
        }
        set(value) = synchronized(this) {
            sharedPreferences.edit {
                putInt(feedbackMessageCountKey, value)
            }
        }

    var feedbackMessageList: FeedbackMessageList
        get() {
            val str = sharedPreferences.getString(feedbackMessageListKey, "")
            return Gson().fromJson(str, FeedbackMessageList::class.java)
        }
        set(value) = synchronized(this) {
            feedbackMessageCount = value.list.size
            sharedPreferences.edit {
                putString(feedbackMessageListKey, value.toString())
            }
        }

}