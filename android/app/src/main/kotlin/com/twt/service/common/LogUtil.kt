package com.twt.service.common

import android.util.Log
import com.twt.service.BuildConfig
import com.umeng.umcrash.UMCrash

object LogUtil {
    /**
     * 一般的Log，当[BuildConfig.LOG_OUTPUT] = true 时，会打印
     */
    fun d(tag: String, message: String) {
        if (BuildConfig.LOG_OUTPUT) {
            Log.d("WBY_$tag", message)
        }
    }

    /**
     * 输出错误，
     *
     * 如果[BuildConfig.LOG_OUTPUT] = true 时，会打印在本地
     *
     * 如果[BuildConfig.LOG_OUTPUT] = false 时，会上报友盟
     */
    fun e(tag: String, error: Throwable, message: String? = null) {
        if (BuildConfig.LOG_OUTPUT) {
            if (message != null) Log.e("WBY_$tag", "message: $message")
            Log.e("WBY_$tag", "error: $error")
            error.printStackTrace()
        } else {
            UMCrash.generateCustomLog(error, "WBY_$tag")
        }
    }
}