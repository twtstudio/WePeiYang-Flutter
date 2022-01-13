package com.twt.service.push.model

data class BaseMessage(
    val type: Int,
    val data: Any,
)

interface MessageData

data class FeedbackMessage(
    val title: String,
    val content: String,
    val question_id: Int,
) : MessageData

data class MailBoxMessage(
    val title: String,
    val content: String,
    val url: String,
) : MessageData

data class Event(
    val type: Int,
    val data: Any
)