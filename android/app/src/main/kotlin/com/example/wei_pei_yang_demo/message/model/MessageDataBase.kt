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
    private const val feedbackMessages = "flutter.feedbackMessageQuestionsList"
    private const val feedbackUserDataKey = "flutter.feedbackUserDataKey"

    val authToken: String?
        get() = sharedPreferences.getString(authTokenKey, "null").also {
            Log.d("WBYTOKEN", it.toString())
        }

    var feedbackBaseData: User?
        get() {
            val str = sharedPreferences.getString(feedbackUserDataKey, null)
            Log.d("WBYFBUSER", str.toString());
            return Gson().fromJson(str.toString(), User::class.java)
        }
        set(value) = synchronized(this) {
            Log.d("WBYFEEDBACKUSERDATA", value.toString())
            sharedPreferences.edit {
                putString(feedbackUserDataKey, Gson().toJson(value))
            }
        }

    val feedbackToken: String?
        get() = sharedPreferences.getString(feedbackTokenKey, null).also {
            Log.d("WBYFEEDBACKTOKEN", it.toString())
        }

    var feedbackMessage: FeedbackMessageBaseData
        get() {
            return Gson().fromJson("", FeedbackMessageBaseData::class.java)
        }
        set(value) = synchronized(this) {
            Log.d("WBYFEEDBACKMESSAGE", value.toString())
            feedbackBaseData?.id.let { user ->
                val feedbackMessageQuestions = mutableListOf<MessageItem>()
                val feedbackMessageFavourites = mutableListOf<MessageItem>()
                for (item in value.data) {
                    when (item.type) {
                        1 -> {
                            //评论提醒暂时不做
                        }
                        2 -> {
                            if (item.question.user_id == user) {
                                feedbackMessageQuestions.add(
                                        MessageItem(messageId = item.id, id = item.question.id)
                                )
                            }
                            if (item.question.is_favorite) {
                                feedbackMessageFavourites.add(
                                        MessageItem(messageId = item.id, id = item.question.id)
                                )
                            }
                        }
                        else -> {

                        }
                    }
                }
                val result = FeedbackMessages(qs = feedbackMessageQuestions, fs = feedbackMessageFavourites)
                Log.d("WBYFBQS", feedbackMessageQuestions.toString());
                sharedPreferences.edit {
                    putString(feedbackMessages, Gson().toJson(result))
                }
            }
        }

    val feedbackMessagesLists: String
        get() = sharedPreferences.getString(feedbackMessages, "") ?: ""

}

data class FeedbackMessages(
        val qs: List<MessageItem>,
        val fs: List<MessageItem>,
)