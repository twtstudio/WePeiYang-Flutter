package com.example.wei_pei_yang_demo.message.model

import android.content.Context
import android.util.Log
import androidx.core.content.edit
import com.example.wei_pei_yang_demo.WBYApplication
import com.google.gson.Gson

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