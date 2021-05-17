package com.twt.wepeiyang.message.model

data class FeedbackMessageBaseData(
        val ErrorCode: Int,
        val msg: String,
        val data: List<FeedbackMessageItem>,
)


data class FeedbackMessageItem(
        val id: Int,
        val type: Int,
        val created_at: String,
        val updated_at: String,
        val contain: Contain,
        val question: Question,
)

data class Contain(
        val id: Int,
        val contain: String,
        val user_id: Int,
        val admin_id: Int,
        val likes: Int,
        val created_at: String,
        val updated_at: String,
        val username: String,
        val admin_name: String,
        val is_liked: Boolean,
        val score: Int,
        val commit: String,
)

data class Question(
        val id: Int,
        val name: String,
        val description: String,
        val campus: Int,
        val user_id: Int,
        val visible: Int,
        val solved: Int,
        val no_commit: Int,
        val likes: Int,
        val created_at: String,
        val updated_at: String,
        val username: String,
        val msgCount: Int,
        val url_list: List<String>,
        val thumbImg: String,
        val tags: List<MTag>,
        val is_liked: Boolean,
        val is_favorite: Boolean,
        val is_owner: Boolean,
)

data class MTag(
        val id: Int,
        val name: String,
)

data class MessageItem(
        val messageId: Int,
        val id: Int,
)