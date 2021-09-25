package com.twt.service

import android.app.AlertDialog
import android.app.PendingIntent
import android.content.ContentResolver
import android.content.ContentValues
import android.content.Intent
import android.graphics.Bitmap
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.os.SystemClock
import android.provider.MediaStore
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import com.amap.api.location.AMapLocationClientOption.AMapLocationMode
import com.amap.api.location.AMapLocationClientOption.AMapLocationProtocol
import com.amap.api.location.AMapLocationListener
import com.example.umeng_sdk.UmengSdkPlugin
import com.google.gson.Gson
import com.twt.service.widget.ScheduleWidgetProvider
import com.umeng.analytics.MobclickAgent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.*
import java.io.File
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.lang.ref.WeakReference
import java.util.*
import kotlin.time.milliseconds

class MainActivity : FlutterFragmentActivity() {
    var messageChannel: MethodChannel? = null
    var placeChannel: MethodChannel? = null
    private var imgSaveChannel: BasicMessageChannel<String>? = null
    lateinit var locationClient: AMapLocationClient
    private val notificationManager: NotificationManagerCompat by lazy {
        NotificationManagerCompat.from(this)
    }

    override fun onPause() {
        super.onPause()
        MobclickAgent.onPause(this)
        Log.i("UMLog", "onPause@MainActivity")
    }

    override fun onResume() {
        super.onResume()
        MobclickAgent.onResume(this)
        Log.i("UMLog", "onResume@MainActivity")
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WBYApplication.activity = WeakReference(this)
        UmengSdkPlugin.setContext(this)
        Log.i("UMLog", "UMConfigure.init@MainActivity")
//        GlobalScope.launch {
//            delay(5000)
//            showNotification(FeedbackMessage(title = "test", content = "test", question_id = 824))
//        }

        locationClient = AMapLocationClient(applicationContext)
        val locationOption = getDefaultOption()
        locationClient.setLocationOption(locationOption)
        locationClient.setLocationListener(locationListener)
//        locationClient.startLocation()

        val intent = Intent(this@MainActivity, ScheduleWidgetProvider::class.java).apply {
            action = "com.twt.appwidget.refresh"
        }
        sendBroadcast(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        messageChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.twt.service/message").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getPostId" -> {
                        result.success(WBYApplication.postId)
                        WBYApplication.postId = -1
                    }
                    "getCid" -> {
                        result.success(WBYApplication.tempCid)
                    }
                    "cancelNotification" -> {
                        try {
                            call.argument<Int>("id")
                        } catch (e: Exception) {
                            -1
                        }.takeIf { it != -1 }?.let {
                            notificationManager.cancel(it)
                        }
                        result.success("cancel success")
                    }
                    "getMessageUrl" -> {
                        result.success(WBYApplication.url)
                        WBYApplication.url = ""
                    }
                    "refreshScheduleWidget" -> {
                        val intent = Intent(this@MainActivity, ScheduleWidgetProvider::class.java).apply {
                            action = "com.twt.appwidget.refresh"
                        }
                        sendBroadcast(intent)
                    }
                    else -> result.error("-1", "cannot find method", null)
                }
            }
        }
        placeChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.twt.service/place").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getLocation" -> {
                        locationClient.startLocation()
                    }
                    else -> result.error("-1", "cannot find method", null)
                }
            }
        }
        imgSaveChannel = BasicMessageChannel<String>(flutterEngine.dartExecutor.binaryMessenger, "com.twt.service/saveBase64Img", StringCodec.INSTANCE).apply {
            setMessageHandler { message, reply ->
                message?.let {
                    try {
                        savePictureToAlbum(it)
                        reply.reply("success")
                    } catch (e: Exception) {
                        reply.reply(null)
                    }
                }
            }
        }
        super.configureFlutterEngine(flutterEngine)
    }

    private fun savePictureToAlbum(filePath: String) {
        val file = File(filePath)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {//Android Q把文件插入到系统图库
            val values = ContentValues()
            values.put(MediaStore.Images.Media.DESCRIPTION, "This is an qr image")
            values.put(MediaStore.Images.Media.DISPLAY_NAME, file.name)
            values.put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
            values.put(MediaStore.Images.Media.TITLE, "Image.jpg")
            values.put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/微北洋")

            val external = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            val resolver = this.contentResolver
            val uri = resolver.insert(external, values)
            uri?.let {
                file.inputStream().use { input ->
                    resolver.openOutputStream(it).use { output ->
                        output?.let {
                            input.copyTo(it)
                        }
                    }
                }
            }

        }
    }

    fun showNotification(data: MessageData) {
        fun send(id: Int, title: String, content: String, intent: Intent) {
            val pendingIntent = PendingIntent.getActivity(this, 0, intent, 0)
            val builder = NotificationCompat.Builder(this, "1")
                    .setSmallIcon(R.drawable.push_small)
                    .setContentTitle(title)
                    .setContentText(content)
//                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
//                .setDefaults(NotificationCompat.DEFAULT_ALL)
                    .setContentIntent(pendingIntent)
                    .setWhen(System.currentTimeMillis())
                    .setAutoCancel(true)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                Log.d("WBY", "Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP")
                val intent2 = Intent(this, MainActivity::class.java)
                val pIntent = PendingIntent.getActivity(applicationContext, 1, intent2, PendingIntent.FLAG_UPDATE_CURRENT)
                builder.setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                builder.setFullScreenIntent(pIntent, false)
            }
            notificationManager.notify(id, builder.build())
        }

        // 点击时想要打开的界面
        val intent = Intent(this, MainActivity::class.java)

        when (data) {
            is FeedbackMessage -> {
                // 一般点击通知都是打开独立的界面，为了避免添加到现有的activity栈中，可以设置下面的启动方式
                // intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                val intentContent = IntentType(type = 1, data = data.question_id.toString())
                intent.data = Uri.parse(Gson().toJson(intentContent))
                send(data.question_id, data.title, data.content, intent)
            }
            is WBYPushMessage -> {
                val intentContent = IntentType(type = 2, data = Gson().toJson(data))
                intent.data = Uri.parse(Gson().toJson(intentContent))
                send(0, data.title, data.content, intent)
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        intent.dataString?.let {
            Log.d("WBY", it)
            val intentContent = Gson().fromJson(it, IntentType::class.java)
            when (intentContent.type) {
                1 -> {
                    WBYApplication.postId = intentContent.data.toIntOrNull() ?: -1
                    messageChannel?.invokeMethod("getReply", null, object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            Log.d("WBY", "message channel: get reply success ?")
//                            WBYApplication.postId = -1
                        }

                        override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                            Log.d("WBY", "message channel: get reply error ?")
                        }

                        override fun notImplemented() {
                        }
                    })
                }
                2 -> {
                    val data = Gson().fromJson(intentContent.data, WBYPushMessage::class.java)
                    WBYApplication.url = data.url
                    messageChannel?.invokeMethod("getWBYPushMessage", mapOf("title" to data.title, "url" to data.url), object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            Log.d("WBY", "message channel: get wby push message success ?")
                        }

                        override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                            Log.d("WBY", "message channel: get wby push message error ?")
                        }

                        override fun notImplemented() {
                        }
                    })
                }
                3 -> {
                    messageChannel?.invokeMethod("enterSchedulePage", null, object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            Log.d("WBY", "message channel: enter schedule page success ?")
                        }

                        override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                            Log.d("WBY", "message channel: enter schedule page error ?")
                        }

                        override fun notImplemented() {
                        }
                    })
                }
                else -> {
                }
            }
        }
        super.onNewIntent(intent)
    }

// 这么写没用，但是先留着，如果之后有厂商推送就有用了
//    override fun getInitialRoute(): String {
//        WBYApplication.postId.takeIf { it != -1 }?.let {
//            return "feedback/detail"
//        }
//        return super.getInitialRoute()
//    }

    fun showDialog(data: String) {
        val builder = AlertDialog.Builder(this)
        builder.setPositiveButton("确定", null)
        builder.setTitle(data)
        builder.show()
    }

    private fun getDefaultOption(): AMapLocationClientOption {
        val mOption = AMapLocationClientOption()
        mOption.locationMode = AMapLocationMode.Hight_Accuracy //可选，设置定位模式，可选的模式有高精度、仅设备、仅网络。默认为高精度模式
        mOption.isGpsFirst = false //可选，设置是否gps优先，只在高精度模式下有效。默认关闭
        mOption.httpTimeOut = 30000 //可选，设置网络请求超时时间。默认为30秒。在仅设备模式下无效
        mOption.interval = 10000 //可选，设置定位间隔。默认为2秒
        mOption.isNeedAddress = true //可选，设置是否返回逆地理地址信息。默认是true
        mOption.isOnceLocation = false //可选，设置是否单次定位。默认是false
        mOption.isOnceLocationLatest = false //可选，设置是否等待wifi刷新，默认为false.如果设置为true,会自动变为单次定位，持续定位时不要使用
        AMapLocationClientOption.setLocationProtocol(AMapLocationProtocol.HTTP) //可选， 设置网络请求的协议。可选HTTP或者HTTPS。默认为HTTP
        mOption.isSensorEnable = false //可选，设置是否使用传感器。默认是false
        mOption.isWifiScan = true //可选，设置是否开启wifi扫描。默认为true，如果设置为false会同时停止主动刷新，停止以后完全依赖于系统刷新，定位位置可能存在误差
        mOption.isLocationCacheEnable = true //可选，设置是否使用缓存定位，默认为true
        mOption.geoLanguage = AMapLocationClientOption.GeoLanguage.DEFAULT //可选，设置逆地理信息的语言，默认值为默认语言（根据所在地区选择语言）
        return mOption
    }

    /**
     * 定位监听
     */
    var locationListener = AMapLocationListener { location ->
        Utils.getLocationStr(location, onSuccess = {
            // 定位成功
            val locationData = with(it) {
                LocationData(longitude, latitude, country, province, city, cityCode, district, address, time)
            }
            val json = Gson().toJson(locationData)
            Log.d("locationresult", json)
            // 发送到flutter
            placeChannel?.invokeMethod("showResult", json)
            locationClient.stopLocation()
        }, onError = {
            placeChannel?.invokeMethod("showError", "定位失败,${it.locationDetail}")
            locationClient.stopLocation()
        })
    }
}

data class IntentType(
        val type: Int,
        val data: String,
)

data class LocationData(
        val longitude: Double,
        val latitude: Double,
        val nation: String,
        val province: String,
        val city: String,
        val cityCode: String,
        val district: String,
        val address: String,
        val time: Long,
)