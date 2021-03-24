package com.example.wei_pei_yang_demo

import com.umeng.analytics.MobclickAgent
import io.flutter.app.FlutterApplication
import com.umeng.commonsdk.UMConfigure

class MainApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        UMConfigure.init(this, "60464782b8c8d45c1390e7e3", "Umeng", UMConfigure.DEVICE_TYPE_PHONE, "")
        UMConfigure.setLogEnabled(true)
        MobclickAgent.setPageCollectionMode(MobclickAgent.PageMode.AUTO)
        android.util.Log.i("UMLog", "UMConfigure.init@MainApplication")
    }
}