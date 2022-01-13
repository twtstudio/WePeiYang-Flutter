package com.twt.service.download

class Progress(
        val id: Long,
        val state: State,
        val progress: Double,
        val fileName:String,
        val message: String = "",
        val path: String = "",
)

enum class State {
    BEGIN,
    RUNNING,
    SUCCESS,
    FAILURE,
}
