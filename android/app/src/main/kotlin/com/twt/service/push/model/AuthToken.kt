package com.twt.service.push.model

import android.content.Context
import android.util.Log
import com.twt.service.WBYApplication

object AuthToken {

    private val sharedPreferences by lazy {
        WBYApplication.context?.get()?.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    }

    private const val authTokenKey = "flutter.token"

    val authToken: String?
        get() = sharedPreferences?.getString(authTokenKey, "null").also {
            Log.d("WBYTOKEN", it.toString())
        }
}