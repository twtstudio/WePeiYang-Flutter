package com.twt.service.message.model

import android.content.Context
import android.util.Log
import com.twt.service.WBYApplication

object MessageDataBase {

    private val sharedPreferences by lazy {
        WBYApplication.appContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    }

    private const val authTokenKey = "flutter.token"

    val authToken: String?
        get() = sharedPreferences.getString(authTokenKey, "null").also {
            Log.d("WBYTOKEN", it.toString())
        }
}