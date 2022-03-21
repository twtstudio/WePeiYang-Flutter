package com.twt.service.push

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationManagerCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.igexin.sdk.PushManager
import com.twt.service.BuildConfig
import com.twt.service.MainActivity
import com.twt.service.WBYApplication
import com.twt.service.common.CanPushType
import com.twt.service.common.LogUtil
import com.twt.service.common.WbyPlugin
import com.twt.service.common.WbySharePreference
import com.twt.service.push.model.Event
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry


// 和产品商量后不获取这两个权限：WRITE_EXTERNAL_STORAGE , READ_PHONE_STATE
//    sd卡权限不要可能cid会变化
//    read_phone那个可能影响cid唯一性

// 微北洋推送流程：
// 1.用户没有登录时不初始化sdk，不开启推送
// 2.用户登陆时确认过《隐私政策》后，进入主页后 初始化个推 sdk（推送服务默认是开启状态），如果这时候检测到通知权限没有，
//   会弹窗引导用户打开推送，如果拒绝则关闭推送
// 3.如果用户通过通知栏关闭了微北洋的推送服务，那默认用户想要关闭推送
// 不管用户是否允许推送，只要确认了隐私权限就初始化 sdk

// Assist_

class WbyPushPlugin : WbyPlugin(), PluginRegistry.NewIntentListener, ActivityAware {
    private var receiver: PushBroadCastReceiver? = null
    private lateinit var binding: ActivityPluginBinding
    private val pushManager by lazy { PushManager.getInstance() }
    private var initSdk = false
    private var goToPushPermissionPage = false
    private lateinit var permissionResult: MethodChannel.Result

    override val name: String
        get() = "com.twt.service/push"

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        super.onAttachedToEngine(binding)
        // 从 Android 8.0（API 26）开始，所有的 Notification 都要指定 Channel
        createNotificationChannel()
        // 如果用户同意了条款，并且打开通知权限，就初始化个推 sdk
        runCatching(::initSdkWhenOpenApp).onFailure {
            log("init sdk when open app failure : $it")
        }
    }

    // 创建通知 channel
    private fun createNotificationChannel() {
        runCatching {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val name = "通知"
                val description = "横幅，锁屏"
                //不同的重要程度会影响通知显示的方式
                val importance = NotificationManager.IMPORTANCE_HIGH
                val channel = NotificationChannel("1", name, importance)
                channel.description = description
                channel.setSound(null, null)
                channel.vibrationPattern = longArrayOf(0, 1000, 500, 1000)
                channel.enableVibration(true)
                val notificationManager = context.getSystemService(NotificationManager::class.java)
                notificationManager.createNotificationChannel(channel)
            }
        }.onFailure {
            log("创建 Notification Channel 失败")
        }
    }

    // 如果用户同意了条款，就初始化个推 sdk，如果用户没有允许推送，或者没有权限，就关闭推送
    // 但只要同意了条款，就会初始化sdk，
    private fun initSdkWhenOpenApp() {
        WbySharePreference.takeIf { it.allowAgreement && it.canPush != CanPushType.Unknown }
            ?.apply {
                initGeTuiSdk()
                initSdk = true
                log("init push sdk success when open app")
                if ((canPush != CanPushType.Want) || !isNotificationEnabled) {
                    canPush = CanPushType.Not
                    pushManager.turnOffPush(context)
                    log("don't allow push ,so turn off push service")
                }
            }
    }

    fun onWindowFocusChanged() {
        log("onWindowFocusChanged")
        runCatching {
            // 去权限授权页面后返回
            if (goToPushPermissionPage) {
                goToPushPermissionPage = false
                checkNotificationAndTurnOnPushService {
                    WbySharePreference.canPush = CanPushType.Not
                    permissionResult.success("refuse open push")
                    log("don't allow permission")
                }
                return
            }
            // 用户手动去权限页面关闭权限，回到app后自动设置不想打开推送
            if (WbySharePreference.canPush == CanPushType.Want && !isNotificationEnabled) {
                WbySharePreference.canPush = CanPushType.Not
                channel.invokeMethod("refreshPushPermission", null)
            }
        }.onFailure {
            log("$it")
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // 个推 sdk 初始化，开启推送，关闭推送，获取当前是否接收推送
            "initGeTuiSdk" -> WbySharePreference.apply {
                if (canPush == CanPushType.Not) {
                    result.success("refuse open push")
                    return
                }
                // 这个方法每次进入主页都会调用，所以要先判断用户是否进入过主页，美金如果主页则 canPush = Unknown
                // 若进入过主页，则 canPush = Want / Not
                if (canPush == CanPushType.Unknown) {
                    // 个推默认在初始化 sdk 后开启推送
                    // 认为用户在同意隐私协议后同意接收推送
                    canPush = CanPushType.Want
                }

                log("initGeTuiSdk")
                runCatching {
                    initGeTuiSdk()
                    if (isNotificationEnabled) {
                        result.success("open push service success")
                    } else {
                        pushManager.turnOffPush(context)
                        requestPushPermissionBy(result) {
                            // canPush = CanPushType.Want 但是没有通知权限，
                            // 有可能是用户手动关闭了，那么久告知他推送需要开启通知权限
                            result.success("showRequestNotificationDialog")
                        }
                    }
                }.onFailure {
                    result.error(INIT_GT_SDK_ERROR, it.message, it.toString())
                }
            }
            // 用户在设置中打开了推送选项，
            "turnOnPushService" -> {
                // 既然用户选择打开推送，则必然用户想要接收推送
                log("turn on push service")
                requestPushPermissionBy(result, ::openNotificationConfigPage)
            }
            "turnOffPushService" -> {
                runCatching(::turnOffPushService).onSuccess {
                    log("turn off push service success")
                    result.success("")
                }.onFailure {
                    log("turn off push service error : $it")
                    result.error("", "", "")
                }
            }
            "getCurrentCanReceivePush" -> {
                runCatching {
                    pushManager.areNotificationsEnabled(context)
                }.onSuccess {
                    log("get current can receive push success")
                    result.success(it)
                }.onFailure {
                    log("get current can receive push error : $it")
                    result.error("", "", "")
                }
            }

            "getCid" -> {
                runCatching {
                    if (pushManager.isPushTurnedOn(context)) {
                        pushManager.getClientid(context)
                    } else {
                        null
                    }
                }.onSuccess {
                    log("get cid success : $it")
                    result.success(it)
                }.onFailure {
                    log("get cid error : $it")
                    result.error("", "", "")
                }
            }
            "cancelNotification" -> {
                runCatching {
                    val id = call.argument<Int>("id")
                    if (id == null) {
                        result.error("", "", "")
                        return
                    }
                    NotificationManagerCompat.from(context).cancel(id)
                    log("cancel notification success id : $id")
                }.onSuccess {
                    result.success("cancel success")
                }.onFailure {
                    log("cancel notification failure throwable: $it")
                    result.error("", "", it.message)
                }
            }
            "cancelAllNotification" -> {
                runCatching {
                    NotificationManagerCompat.from(context).cancelAll()
                }.onSuccess {
                    log("cancel all notification success")
                    result.success("")
                }.onFailure {
                    log("cancel all notification error : $it")
                    result.error("", "", "")
                }
            }
            "getIntentUri" -> {
                getIntentUri(call, result)
            }
            else -> result.notImplemented()
        }
    }

    private fun initGeTuiSdk() {
        pushManager.initialize(context)
        log("init push sdk success")
        if (BuildConfig.DEBUG) {
            pushManager.setDebugLogger(context) { s -> Log.i(TAG, s) }
        }
    }

    private fun turnOffPushService() {
        if (pushManager.isPushTurnedOn(context)) {
            pushManager.turnOffPush(context)
        }
        WbySharePreference.canPush = CanPushType.Not
    }

    private fun turnOnPushService() {
        if (!pushManager.isPushTurnedOn(context)) {
            pushManager.turnOnPush(context)
        }
        WbySharePreference.canPush = CanPushType.Want
    }

    // 检查是否具有权限：WRITE_EXTERNAL_STORAGE , READ_PHONE_STATE
    // sd卡权限不要可能cid会变化
    // read_phone那个可能影响cid唯一性
    // 和产品商量后，暂时不要这两个权限
//    @Suppress("unused")
//    private fun checkPermissionAnd(do: () -> Unit) {
//        if (checkPermission) {
//
//        } else {
//            if (Build.VERSION.SDK_INT >= 23) {
//                binding.activity.requestPermissions(
//                    arrayOf(
//                        Manifest.permission.WRITE_EXTERNAL_STORAGE,
//                        Manifest.permission.READ_PHONE_STATE
//                    ),
//                    REQUEST_NOTIFICATION_PERMISSION
//                )
//            }
//        }
//    }

    private fun checkNotificationAndTurnOnPushService(notAllow: () -> Unit) {
        log("check notification permission")
        // 做双重检查，主要是两个方式不一样，一个是 NotificationManagerCompat
        // 一个是 NotificationManagerCompat + AppOpsManager 反射挺搞
        with(permissionResult) {
            runCatching {
                if (isNotificationEnabled) {
                    runCatching(::turnOnPushService).onSuccess {
                        log("turnOnPushService success")
                        success("open push service success")
                    }.onFailure {
                        log("turnOnPushService error : $it")
                        error(
                            OPEN_PUSH_SERVICE_ERROR,
                            "turnOnPushService error when enable notification",
                            it.message
                        )
                    }
                } else {
                    notAllow()
                }
            }.onFailure {
                log("check notification error : $it")
                error(CHECK_NOTIFICATION_ENABLE_ERROR, "", it.message)
            }
        }
    }

    private fun requestPushPermissionBy(result: MethodChannel.Result, send: () -> Unit) {
        permissionResult = result
        checkNotificationAndTurnOnPushService {
            runCatching(send).onFailure {
                log("open notification config page error : $it")
                permissionResult.error(OPEN_NOTIFICATION_CONFIG_PAGE_ERROR, "", it.message)
            }
        }
    }

    // 打开系统通知权限页面
    private fun openNotificationConfigPage() {
        // 参考个推 demo
        val intent = Intent().apply {
            when {
                Build.VERSION.SDK_INT >= 26 -> {
                    // android 8.0引导
                    action = "android.settings.APP_NOTIFICATION_SETTINGS"
                    putExtra("android.provider.extra.APP_PACKAGE", context.packageName)
                }
                else -> {
                    // android 6.0 - 7.0
                    action = "android.settings.APP_NOTIFICATION_SETTINGS"
                    putExtra("app_package", context.packageName)
                    putExtra("app_uid", context.applicationInfo.uid)
                }
            }
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        goToPushPermissionPage = true
        binding.activity.startActivity(intent)
        // 这里很坑，因为你打开权限页后，activity自动重启
        // 所以在MainActivity中的onWindowFocusChanged中捕获回到APP
    }

    private val isNotificationEnabled: Boolean
        get() = NotificationManagerCompat.from(context)
            .areNotificationsEnabled() && pushManager.areNotificationsEnabled(context)

    // 和产品商量过，暂时不用这两个权限
//    private val checkPermission: Boolean
//        get() {
//            val pkgManager: PackageManager = context.packageManager
//
//            // 读写 sd card 权限非常重要, android6.0默认禁止的, 建议初始化之前就弹窗让用户赋予该权限
//            val sdCardWritePermission = pkgManager.checkPermission(
//                Manifest.permission.WRITE_EXTERNAL_STORAGE,
//                context.packageName
//            ) == PackageManager.PERMISSION_GRANTED
//
//            // read phone state用于获取 imei 设备信息
//            val phoneSatePermission = pkgManager.checkPermission(
//                Manifest.permission.READ_PHONE_STATE,
//                context.packageName
//            ) == PackageManager.PERMISSION_GRANTED
//            // 在5.0及以下的android系统上并没有动态请求权限的方法，不过我们可以在获得这些权限时，try catch
//            // 如果报错意味着我们没有这些权限，这时候提示用户打开权限也是可以实现判断的目的的。
//            return sdCardWritePermission && phoneSatePermission
//        }

    // 点击通知进入微北洋，若应用未在后台，会传递intent，并在 onCreate 中解析
    // 若在后台，就调用 onNewIntent
    // 什么情况会调用 handleIntent:
    //    1.推送（通知栏）：
    //       Ⅰ：青年湖底推送
    //       Ⅱ：天外天官方推送
    //       Ⅲ：热修复通知推送
    //    2.点击桌面小组件：暂时只有课程表小组件
    private fun handleIntent(intent: Intent): Boolean {
        // 走 url scheme 打开微北洋的拦截
        if (intent.scheme == "wpy" && intent.data?.host == "qnhd.app" && intent.data?.getQueryParameter("page") == "summary") {
            log("jump from url")
            WBYApplication.eventList.add(
                Event(IntentEvent.FeedbackSummaryPage.type, "null")
            )
            return true
        }

        // 下面是走intent打开微北洋的拦截
        // 华为和小米厂商通道可以传递 data ，魅族厂商通道只能产地 extra ，所以只通过 extra 传递数据
        log("WbyPushPlugin handle intent : $intent")
        when (intent.getStringExtra("type")) {
            "feedback" -> {
                intent.getIntExtra("question_id", -1).takeIf { it != -1 }?.let { id ->
                    log("question_id : $id")
                    WBYApplication.eventList.add(
                        Event(IntentEvent.FeedbackPostPage.type, id)
                    )
                    return true
                }
                intent.getStringExtra("page")?.takeIf { it == "summary" }?.let {
                    WBYApplication.eventList.add(
                        Event(IntentEvent.FeedbackSummaryPage.type, "null")
                    )
                    return true
                }
                return true
            }
            "mailbox" -> {
                val createdAt = intent.getStringExtra("createdAt")
                val url = intent.getStringExtra("url")
                val title = intent.getStringExtra("title")
                val content = intent.getStringExtra("content")
                val data = mapOf(
                    "url" to url,
                    "title" to title,
                    "createdAt" to createdAt,
                    "content" to content
                )
                WBYApplication.eventList.add(
                    Event(IntentEvent.MailBox.type, data)
                )
                return true
            }
            "update" -> {
                val versionCode = intent.getIntExtra("versionCode", 0)
                val fixCode = intent.getIntExtra("fixCode", 0)
                val url = intent.getStringExtra("url") ?: ""
                val data = mapOf(
                    "versionCode" to versionCode,
                    "fixCode" to fixCode,
                    "url" to url,
                )
                WBYApplication.eventList.add(
                    Event(IntentEvent.Update.type, data)
                )
                return true
            }
        }
        return false
    }

    // 设置 MainActivity:  android:launchMode="singleInstance"
    // 若 activity 进程还在，则调用 onNewIntent，
    // 若 activity 进程没有，则调用 onCreate
    override fun onNewIntent(intent: Intent?): Boolean {
        intent?.runCatching {
            return handleIntent(this)
        }
        return false
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        kotlin.runCatching { handleIntent(binding.activity.intent) }
        binding.addOnNewIntentListener(this)
        this.binding = binding
        runCatching(::initLocalBroadcast)
    }

    // 初始化 LocalBroadcast
    private fun initLocalBroadcast() {
        receiver = PushBroadCastReceiver(binding, channel)
        val intentFilter = IntentFilter().apply {
            addAction(DATA)
            addAction(CID)
            addDataScheme("twtstudio")
        }
        LocalBroadcastManager.getInstance(context).registerReceiver(receiver!!, intentFilter)
        log("init local broadcast success")
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    // 注销 LocalBroadcast
    override fun onDetachedFromActivity() {
        receiver?.let {
            LocalBroadcastManager.getInstance(context).unregisterReceiver(it)
        }
    }

    // 获取发送通知打开具体页面所用的 intent
    private fun getIntentUri(call: MethodCall, result: MethodChannel.Result) {
        val intent = Intent(context, MainActivity::class.java).apply {
            setPackage(context.packageName)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }

        when (call.argument<String>("type")) {
            "feedback" -> {
                // 跳转问题详情页面
                call.argument<Int>("question_id")?.let { id ->
                    val intentUri = intent.apply {
                        data = Uri.parse("twtstudio://weipeiyang.app/feedback?")
                        putExtra("question_id", id)
                        putExtra("type", "feedback")
                    }.toUri(Intent.URI_INTENT_SCHEME)

                    log("get feedback intent success : $intentUri")
                    result.success(intentUri)
                    return
                }
                // 跳转校务总结页面
                call.argument<String>("page")?.takeIf { it == "summary" }?.let {
                    val intentUri = intent.apply {
                        data = Uri.parse("wpy://qnhd?page=summary")
                        putExtra("page", "summary")
                        putExtra("type", "feedback")
                    }.toUri(Intent.URI_INTENT_SCHEME)

                    log("get feedback intent success : $intentUri")
                    result.success(intentUri)
                    return
                }

                result.error("-1", "question_id can't be null!", "")
                return
            }
            "mailbox" -> {
                val url = call.argument<String>("url")
                val title = call.argument<String>("title")
                val content = call.argument<String>("content")
                val createAt = call.argument<String>("createdAt")
                if (url.isNullOrBlank() || title.isNullOrBlank()) {
                    result.error("-1", "url and title can't be null!", "")
                    return
                }

                val intentUri = intent.apply {
                    data = Uri.parse("twtstudio://weipeiyang.app/mailbox?")
                    putExtra("url", url)
                    putExtra("title", title)
                    putExtra("createdAt", createAt)
                    putExtra("content", content)
                    putExtra("type", "mailbox")
                }.toUri(Intent.URI_INTENT_SCHEME)

                log("get mailbox intent success : $intentUri")
                result.success(intentUri)
            }
            "update" -> {
                val versionCode = call.argument<Int>("versionCode") ?: 0
                val fixCode = call.argument<Int>("fixCode") ?: 0
                val url = call.argument<String>("url") ?: ""
                val intentUri = intent.apply {
                    data = Uri.parse("twtstudio://weipeiyang.app/mailbox?")
                    putExtra("url", url)
                    putExtra("versionCode", versionCode)
                    putExtra("fixCode", fixCode)
                    putExtra("type", "update")
                }.toUri(Intent.URI_INTENT_SCHEME)

                log("get update intent success : $intentUri")
                result.success(intentUri)
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        const val DATA = "com.twt.service.PUSH_DATA"
        const val CID = "com.twt.service.PUSH_TOKEN"
        const val TAG = "WBY_PUSH"
        const val REQUEST_NOTIFICATION_PERMISSION = 303

        const val OPEN_PUSH_SERVICE_ERROR = "OPEN_PUSH_SERVICE_ERROR"
        const val OPEN_NOTIFICATION_CONFIG_PAGE_ERROR = "OPEN_NOTIFICATION_CONFIG_PAGE_ERROR"
        const val CHECK_NOTIFICATION_ENABLE_ERROR = "CHECK_NOTIFICATION_ENABLE_ERROR"
        const val INIT_GT_SDK_ERROR = "INIT_GT_SDK_ERROR"

        const val OPEN_REQUEST_NOTIFICATION_DIALOG_ERROR = "OPEN_REQUEST_NOTIFICATION_DIALOG_ERROR"
        const val FATAL_ERROR = "FATAL_ERROR"
        fun log(message: String) = LogUtil.d(TAG, message)
    }
}
