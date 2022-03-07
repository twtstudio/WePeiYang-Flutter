package com.twt.service.common

import android.util.Log
import com.twt.service.BuildConfig
import com.umeng.umcrash.UMCrash

object LogUtil {
    fun d(tag: String, message: String) {
        if (BuildConfig.LOG_OUTPUT) {
            Log.d(tag, message)
        }
    }

    fun e(tag: String, error: Throwable) {
        if (BuildConfig.LOG_OUTPUT) {
            Log.e(tag, "error: $error")
            error.printStackTrace()
        } else {
            UMCrash.generateCustomLog(error, "UmengException");
        }
    }
}