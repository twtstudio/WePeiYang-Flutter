package com.example.wei_pei_yang_demo.message.model

data class FeedbackMessage(
        val ErrorCode: Int,
        val msg: String,
        val data: FeedbackMessageList,
)

data class FeedbackMessageList(
        val list : List<FeedbackMessageItem>,
)

data class FeedbackMessageItem(
        val id: Int,
        val type: Int,
        val created_at: String,
        val updated_at: String,
        val contain: List<Contain>,
        val question: List<Question>,
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
        val adminname: String,
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
        val visible: Boolean,
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