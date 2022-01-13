package com.twt.service.push.model

import androidx.annotation.Keep

interface MessageData

@Keep
data class FeedbackMessage(
    val title: String,
    val content: String,
    val question_id: Int,
) : MessageData

@Keep
data class MailBoxMessage(
    val title: String,
    val content: String,
    val url: String,
) : MessageData

@Keep
data class HotFixMessage(
    val appVersionCode: Int,
    val fixCode: Int,
) : MessageData

@Keep
data class Event(
    val type: Int,
    val data: Any
)