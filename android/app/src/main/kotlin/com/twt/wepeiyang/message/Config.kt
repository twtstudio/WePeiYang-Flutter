package com.twt.wepeiyang.message

import android.content.Context
import android.content.pm.PackageManager
import android.util.Log

object Config {
    const val AUTH_ACTION = "com.action.auth"
    private val TAG = Config::class.java.simpleName
    private var appid: String? = ""
    private var appName = ""
    private var packageName = ""
    var authToken: String? = null
    fun init(context: Context) {
        parseManifests(context)
    }

    private fun parseManifests(context: Context) {
        packageName = context.packageName
        try {
            val appInfo = context.packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
            appName = appInfo.loadLabel(context.packageManager).toString()
            if (appInfo.metaData != null) {
                appid = appInfo.metaData.getString("GETUI_APPID")
            }
        } catch (e: Exception) {
            Log.i(TAG, "parse manifest failed = $e")
        }
    }
}