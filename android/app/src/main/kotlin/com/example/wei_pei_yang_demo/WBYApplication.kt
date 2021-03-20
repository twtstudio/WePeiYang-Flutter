package com.example.wei_pei_yang_demo

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.util.Log
import androidx.work.*
import com.example.wei_pei_yang_demo.message.server.PushCIdWorker
import com.igexin.sdk.PushManager
import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference

class WBYApplication : FlutterApplication(), Configuration.Provider {
    companion object {
        const val TAG = "WBY"
        lateinit var appContext: Context
        val handler = MyHandler()
        var activity: WeakReference<MainActivity>? = null
        var feedbackCount = 1

        fun sendMessage(msg: Message) = handler.sendMessage(msg)

        class MyHandler : Handler(Looper.getMainLooper()) {
            companion object {
                const val RECEIVE_MESSAGE_DATA = 0
                const val RECEIVE_CLIENT_ID = 1
                const val REFRESH_FEEDBACK_COUNT = 2
                const val CLEAR_FEEDBACK_COUNT = 3
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
                    REFRESH_FEEDBACK_COUNT -> {
                        val data = msg.obj.toString()
                        activity?.get()?.messageChannel?.invokeMethod("refreshFeedbackMessageCount", data)
                    }
                    CLEAR_FEEDBACK_COUNT -> {
                        feedbackCount = 0
                    }
                }
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        appContext = this
        initSdk()
    }

    private fun initSdk() {
        Log.d(TAG, "initializing sdk...")
        PushManager.getInstance().initialize(this)
        if (BuildConfig.DEBUG) {
            //切勿在 release 版本上开启调试日志
            PushManager.getInstance().setDebugLogger(this) { s -> Log.i("PUSH_LOG", s) }
        }
    }

    override fun getWorkManagerConfiguration(): Configuration {
        return if (BuildConfig.DEBUG) {
            Configuration.Builder()
                    .setMinimumLoggingLevel(Log.DEBUG)
                    .build()
        } else {
            Configuration.Builder()
                    .setMinimumLoggingLevel(Log.ERROR)
                    .build()
        }
    }


}