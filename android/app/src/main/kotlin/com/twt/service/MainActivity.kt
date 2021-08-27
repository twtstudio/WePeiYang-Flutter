package com.twt.service

import android.app.AlertDialog
import android.app.PendingIntent
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import com.amap.api.location.AMapLocationClientOption.AMapLocationMode
import com.amap.api.location.AMapLocationClientOption.AMapLocationProtocol
import com.amap.api.location.AMapLocationListener
import com.amap.api.location.AMapLocationQualityReport
import com.example.umeng_sdk.UmengSdkPlugin
import com.google.gson.Gson
import com.twt.service.widget.ScheduleWidgetProvider
import com.umeng.analytics.MobclickAgent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference

class MainActivity : FlutterFragmentActivity() {
    var messageChannel: MethodChannel? = null
    var placeChannel: MethodChannel? = null
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
                    "test" -> {
//                        Toast.makeText(this@MainActivity, "message channel test", Toast.LENGTH_SHORT).show()
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
//                        Toast.makeText(this@MainActivity, "place channel test", Toast.LENGTH_SHORT).show()
                    }
                    "test" -> {
//                        Toast.makeText(this@MainActivity, "place channel test", Toast.LENGTH_SHORT).show()
                    }
                    else -> result.error("-1", "cannot find method", null)
                }
            }
        }
        super.configureFlutterEngine(flutterEngine)
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
                intent.data = Uri.parse(intentContent.toString())
                send(data.question_id, data.title, data.content, intent)
            }
            is WBYPushMessage -> {
                val intentContent = IntentType(type = 2, data = Gson().toJson(data))
                intent.data = Uri.parse(intentContent.toString())
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
//                            WBYApplication.postId = -1
                        }

                        override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
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
                            Log.d("WBY", "open wby push message success ?")
                        }

                        override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                            Log.d("WBY", "open wby push message error ?")
                        }

                        override fun notImplemented() {
                            Log.d("WBY", "open wby push message not implemented ?")
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
//        Toast.makeText(this@MainActivity, "location", Toast.LENGTH_SHORT).show()
        if (null != location) {
            val sb = StringBuffer()
            //errCode等于0代表定位成功，其他的为定位失败，具体的可以参照官网定位错误码说明
            if (location.errorCode == 0) {
                sb.append("""
    定位成功

    """.trimIndent())
                sb.append("""
    定位类型: ${location.locationType}

    """.trimIndent())
                sb.append("""
    经    度    : ${location.longitude}

    """.trimIndent())
                sb.append("""
    纬    度    : ${location.latitude}

    """.trimIndent())
                sb.append("""
    精    度    : ${location.accuracy}米

    """.trimIndent())
                sb.append("""
    提供者    : ${location.provider}

    """.trimIndent())
                sb.append("""
    速    度    : ${location.speed}米/秒

    """.trimIndent())
                sb.append("""
    角    度    : ${location.bearing}

    """.trimIndent())
                // 获取当前提供定位服务的卫星个数
                sb.append("""
    星    数    : ${location.satellites}

    """.trimIndent())
                sb.append("""
    国    家    : ${location.country}

    """.trimIndent())
                sb.append("""
    省            : ${location.province}

    """.trimIndent())
                sb.append("""
    市            : ${location.city}

    """.trimIndent())
                sb.append("""
    城市编码 : ${location.cityCode}

    """.trimIndent())
                sb.append("""
    区            : ${location.district}

    """.trimIndent())
                sb.append("""
    区域 码   : ${location.adCode}

    """.trimIndent())
                sb.append("""
    地    址    : ${location.address}

    """.trimIndent())
                sb.append("""
    兴趣点    : ${location.poiName}

    """.trimIndent())
                //定位完成的时间
                sb.append("""
    定位时间: ${Utils.formatUTC(location.time, "yyyy-MM-dd HH:mm:ss")}

    """.trimIndent())

                // 定位成功
                val locationData = with(location) {
                    LocationData(longitude, latitude, country, province, city, cityCode, district, address, time)
                }
                val json = Gson().toJson(locationData)
                Log.d("locationresult", json)
//                Toast.makeText(this@MainActivity, json, Toast.LENGTH_SHORT).show()
                // 发送到flutter
                placeChannel?.invokeMethod("showResult", json)
                locationClient.stopLocation()
            } else {
                //定位失败
                sb.append("""
    定位失败

    """.trimIndent())
                sb.append("""
    错误码:${location.errorCode}

    """.trimIndent())
                sb.append("""
    错误信息:${location.errorInfo}

    """.trimIndent())
                sb.append("""
    错误描述:${location.locationDetail}

    """.trimIndent())

                placeChannel?.invokeMethod("showError", "定位失败,${location.locationDetail}")

                locationClient.stopLocation()
            }
            sb.append("***定位质量报告***").append("\n")
            sb.append("* WIFI开关：").append(if (location.locationQualityReport.isWifiAble) "开启" else "关闭").append("\n")
            sb.append("* GPS状态：").append(getGPSStatusString(location.locationQualityReport.gpsStatus)).append("\n")
            sb.append("* GPS星数：").append(location.locationQualityReport.gpsSatellites).append("\n")
            sb.append("* 网络类型：" + location.locationQualityReport.networkType).append("\n")
            sb.append("* 网络耗时：" + location.locationQualityReport.netUseTime).append("\n")
            sb.append("****************").append("\n")
            //定位之后的回调时间
            sb.append("""
    回调时间: ${Utils.formatUTC(System.currentTimeMillis(), "yyyy-MM-dd HH:mm:ss")}

    """.trimIndent())

            //解析定位结果
            val result = sb.toString()
            Log.d("locationresult", result)
        } else {
            Log.d("locationresult", "定位失败，loc is null")
        }
    }

    /**
     * 获取GPS状态的字符串
     * @param statusCode GPS状态码
     * @return
     */
    private fun getGPSStatusString(statusCode: Int): String {
        var str = ""
        when (statusCode) {
            AMapLocationQualityReport.GPS_STATUS_OK -> str = "GPS状态正常"
            AMapLocationQualityReport.GPS_STATUS_NOGPSPROVIDER -> str = "手机中没有GPS Provider，无法进行GPS定位"
            AMapLocationQualityReport.GPS_STATUS_OFF -> str = "GPS关闭，建议开启GPS，提高定位质量"
            AMapLocationQualityReport.GPS_STATUS_MODE_SAVING -> str = "选择的定位模式中不包含GPS定位，建议选择包含GPS定位的模式，提高定位质量"
            AMapLocationQualityReport.GPS_STATUS_NOGPSPERMISSION -> str = "没有GPS定位权限，建议开启gps定位权限"
        }
        return str
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