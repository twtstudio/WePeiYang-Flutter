package com.twt.service.common

import android.util.Log
import com.twt.service.BuildConfig

object LogUtil {
    fun d(tag: String, message: String) {
        if (BuildConfig.LOG_OUTPUT) {
            Log.d(tag, message)
        }
    }
}