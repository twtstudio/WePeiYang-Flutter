package com.twt.service

import android.os.Bundle
import com.twt.service.download.WbyDownloadPlugin
import com.twt.service.imageSave.WbyImageSavePlugin
import com.twt.service.install.WbyInstallPlugin
import com.twt.service.location.WbyLocationPlugin
import com.twt.service.message.WbyMessagePlugin
import com.twt.service.push.WbyPushPlugin
import com.twt.service.share.WbySharePlugin
import com.twt.service.widget.WbyWidgetPlugin
import com.umeng.commonsdk.UMConfigure
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        UMConfigure.preInit(this,"60464782b8c8d45c1390e7e3","Umeng")
        if (BuildConfig.DEBUG){
            UMConfigure.setLogEnabled(true)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(WbyWidgetPlugin())
        flutterEngine.plugins.add(WbyMessagePlugin())
        flutterEngine.plugins.add(WbySharePlugin())
        flutterEngine.plugins.add(WbyDownloadPlugin())
        flutterEngine.plugins.add(WbyInstallPlugin())
        flutterEngine.plugins.add(WbyLocationPlugin())
        flutterEngine.plugins.add(WbyImageSavePlugin())
        flutterEngine.plugins.add(WbyPushPlugin())
    }
}