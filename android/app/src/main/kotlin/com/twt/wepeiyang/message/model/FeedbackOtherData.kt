package com.twt.wepeiyang.message.model

data class FeedbackBaseData<T>(
        val ErrorCode: Int,
        val msg: String,
        val data: T?,
)

data class User(
        val id: Int,
        val name: String,
)