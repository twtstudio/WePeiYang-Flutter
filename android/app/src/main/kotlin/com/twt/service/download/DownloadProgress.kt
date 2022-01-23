package com.twt.service.download

import androidx.annotation.Keep

@Keep
data class Progress(
    val id: Long,
    val listenerId: String,
    val status: Status,
    val progress: Double,
    val taskId: String,
    val message: String = "",
    val path: String = "",
)

enum class Status {
    BEGIN,
    RUNNING,
    SUCCESS,
    FAILURE,
}
