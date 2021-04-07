package com.example.wei_pei_yang_demo

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.util.Log
import androidx.work.*
import com.example.wei_pei_yang_demo.message.model.MessageDataBase
import com.example.wei_pei_yang_demo.message.server.PushCIdWorker
import com.igexin.sdk.PushManager
import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference
import com.umeng.commonsdk.UMConfigure
import com.umeng.analytics.MobclickAgent

class WBYApplication : FlutterApplication() {
    companion object {
        const val TAG = "WBY"
        lateinit var appContext: Context
        private val handler = MyHandler()
        var activity: WeakReference<MainActivity>? = null

        fun sendMessage(msg: Message) = handler.sendMessage(msg)

        class MyHandler : Handler(Looper.getMainLooper()) {
            companion object {
                const val RECEIVE_MESSAGE_DATA = 0
                const val RECEIVE_CLIENT_ID = 1
            }

            override fun handleMessage(msg: Message) {
                when (msg.what) {
                    RECEIVE_CLIENT_ID -> {
                        val cId = msg.obj.toString()
                        val workManager = WorkManager.getInstance(appContext)
                        val constraints = Constraints.Builder()
                                .setRequiredNetworkType(NetworkType.CONNECTED)
                                .setRequiresStorageNotLow(true)
                                .build()
                        val task = OneTimeWorkRequest.Builder(PushCIdWorker::class.java)
                                .addTag("1")
                                .setInputData(workDataOf("cid" to cId))
                                .setConstraints(constraints)
                                .build()
                        workManager.enqueueUniqueWork("download", ExistingWorkPolicy.KEEP, task)

                    }
                    RECEIVE_MESSAGE_DATA -> {
                        val data = msg.obj.toString()
                        Log.d("WBY", data)
                        Log.d("WBY", (activity?.get()?.messageChannel == null).toString())
                        activity?.get()?.messageChannel?.invokeMethod("showMessage", data, object : MethodChannel.Result {
                            override fun success(result: Any?) {
                                Log.d("WBY", "success")
                            }

                            override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                                Log.d("WBY", errorCode.toString())
                            }

                            override fun notImplemented() {
                                activity?.get()?.showDialog("notimplemented")
                            }
                        })
                    }
                }
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        appContext = this
        initSdk()
        // 友盟初始化
        UMConfigure.init(this, "60464782b8c8d45c1390e7e3", "Umeng", UMConfigure.DEVICE_TYPE_PHONE, "")
        UMConfigure.setLogEnabled(true)
        MobclickAgent.setPageCollectionMode(MobclickAgent.PageMode.AUTO)
        android.util.Log.i("UMLog", "UMConfigure.init@MainApplication")
    }

    private fun initSdk() {
        Log.d(TAG, "initializing sdk...")
        PushManager.getInstance().initialize(this)
        if (BuildConfig.DEBUG) {
            //切勿在 release 版本上开启调试日志
            PushManager.getInstance().setDebugLogger(this) { s -> Log.i("PUSH_LOG", s) }
        }
    }


}