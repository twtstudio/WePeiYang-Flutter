package com.twt.service.push.model

import androidx.annotation.Keep

@Keep
data class Event(
    val type: Int,
    val data: Any
)
