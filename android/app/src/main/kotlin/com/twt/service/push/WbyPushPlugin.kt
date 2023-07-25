package com.twt.service.push

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationManagerCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.igexin.sdk.PushManager
import com.twt.service.BuildConfig
import com.twt.service.MainActivity
import com.twt.service.WBYApplication
import com.twt.service.common.FlutterSharePreference
import com.twt.service.common.LogUtil
import com.twt.service.common.WbyPlugin
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

// Assist_

/**
 * 微北洋推送流程：
 *
 * 1.用户没有登录时不初始化sdk，不开启推送
 *
 * 2.用户登陆时确认过《隐私政策》后，进入主页后 初始化个推 sdk（推送服务默认是开启状态），如果这时候检测到通知权限没有，
 * 会弹窗引导用户打开推送，如果拒绝则关闭推送。目前测过的手机中，华为小米默认开启推送，OPPO默认关闭推送
 *
 * 3.如果用户通过通知栏关闭了微北洋的推送服务，那默认用户想要关闭推送（TODO: 关闭通知栏也应该会出发onConfigChange）
 *
 * 4.不管用户是否允许推送，只要确认了隐私权限就初始化 sdk
 *
 * @author what?
 * @date 2022/3/25
 */
class WbyPushPlugin : WbyPlugin(), PluginRegistry.NewIntentListener, ActivityAware {
    // 个推服务初始化成功，拿到cId后，通过 LocalBroadcast 广播后，发送到服务器
    private lateinit var receiver: PushBroadCastReceiver
    private lateinit var binding: ActivityPluginBinding

    // 个推推送服务单例
    private val pushManager by lazy { PushManager.getInstance() }

    // 请求通知权限回调
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

    /**
     * 创建通知 channel
     * TODO：暂时不知道是否有自定义通知的需要，因为现在的推送全部走个推推送
     */
    private fun createNotificationChannel() {
        runCatching {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val name = "通知"
                val des = "横幅，锁屏"
                //不同的重要程度会影响通知显示的方式
                val importance = NotificationManager.IMPORTANCE_HIGH
                val channel = NotificationChannel("1", name, importance).apply {
                    description = des
                    // 声音
                    setSound(null, null)
                    // 是否震动
                    enableVibration(true)
                    vibrationPattern = longArrayOf(0, 1000, 500, 1000)
                }
                val notificationManager = context.getSystemService(NotificationManager::class.java)
                notificationManager.createNotificationChannel(channel)
            }
        }.onFailure {
            log("创建 Notification Channel 失败")
        }
    }

    /**
     * 如果用户同意了条款，就初始化个推 sdk，
     *
     * 如果用户没有允许推送，或者没有权限，就关闭推送但只要同意了条款，就会初始化sdk，不然后台数据会出错
     */
    private fun initSdkWhenOpenApp() {
        FlutterSharePreference.takeIf { it.allowAgreement && it.canPush != CanPushType.Unknown }
            ?.apply {
                pushManager.initialize(context)
                if (BuildConfig.LOG_OUTPUT) {
                    pushManager.setDebugLogger(context, ::log)
                }
                log("init push sdk success when open app")
                if ((canPush != CanPushType.Want) || !isNotificationEnabled) {
                    canPush = CanPushType.Not
                    pushManager.turnOffPush(context)
                    log("don't allow push ,so turn off push service")
                }
            }
    }

    /**
     * 请求通知权限需要去到系统设置页面，如果用户更改了权限，则会重启activity，
     * 所以只能通过[MainActivity.onWindowFocusChanged]来得知返回微北洋，继而接着执行
     */
    fun onWindowFocusChanged() {
        log("onWindowFocusChanged")
        runCatching {
            // 去权限授权页面后返回
            if (goToPushPermissionPage) {
                goToPushPermissionPage = false
                checkAndTurnOnPushService { result ->
                    FlutterSharePreference.canPush = CanPushType.Not
                    result.success("refuse open push")
                    log("don't allow permission")
                }
                return
            }
            // 用户手动去权限页面关闭权限，回到app后自动设置不想打开推送，并且告知用户推送的重要性，再次请求
            // TODO：1.看看在左滑通知关闭权限是否也有效  2.告知用户推送的重要性
            if (FlutterSharePreference.canPush == CanPushType.Want && !isNotificationEnabled) {
                FlutterSharePreference.canPush = CanPushType.Not
                channel.invokeMethod("refreshPushPermission", null)
            }
        }.onFailure {
            log("$it")
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                // 个推 sdk 初始化，开启推送，关闭推送，获取当前是否接收推送
                "initGeTuiSdk" -> initGeTuiSdk(result)
                // 用户在微北洋设置中打开了推送选项，
                "turnOnPushService" -> requestPushPermissionBy(result, ::openNotificationConfigPage)
                // 用户在微北洋设置中关闭了推送选项，
                "turnOffPushService" -> turnOffPushService(result)
                // 现在能否接受推送，即能否发送通知 TODO: 有用吗？
                "canReceivePush" -> pushManager.areNotificationsEnabled(context)
                // 获取个推 cid
                "getCid" -> getCid(result)
                // 获取个推需要跳转到指定页面的 uri
                "getIntentUri" -> getIntentUri(call, result)
                else -> result.notImplemented()
            }
        } catch (e: Throwable) {
            LogUtil.e(TAG, e)
        }
    }

    /**
     * 获取个推 cid，如果没有开启推送就返回null，但要注意未成功初始化个推，cid也会未null
     *
     * 所以如果返回 null，则代表广义未成功初始化推送
     */
    private fun getCid(result: MethodChannel.Result) {
        if (pushManager.isPushTurnedOn(context)) {
            pushManager.getClientid(context)
        } else {
            null
        }.let {
            result.success(it)
        }
    }

    /**
     * flutter端在进入主页后，会调用此方法初始化 sdk 并开启推送。
     *
     * 但如果用户已经或默认同意开启推送，则实际上在[onAttachedToEngine]中已经运行了[initSdkWhenOpenApp]，
     * 个推文档：多次调用 SDK 初始化并无影响 https://docs.getui.com/getui/mobile/android/androidstudio/
     * 所以这里再初始化一次也无所谓
     */
    private fun initGeTuiSdk(result: MethodChannel.Result) {
        FlutterSharePreference.apply {
            // 如果用户禁止推送或默认禁止推送，则通知flutter端不允许推送
            if (canPush == CanPushType.Not) {
                result.success("refuse open push")
                return
            }
            // 这个方法每次进入主页都会调用，所以要先判断用户是否进入过主页，如果没进主页则 canPush = Unknown
            // 若进入过主页，则 canPush = Want / Not
            if (canPush == CanPushType.Unknown) {
                // 个推默认在初始化 sdk 后开启推送
                // 认为用户在同意隐私协议后同意接收推送
                canPush = CanPushType.Want
            }

            runCatching {
                pushManager.initialize(context)
                if (BuildConfig.LOG_OUTPUT) {
                    pushManager.setDebugLogger(context, ::log)
                }
                log("init push sdk success")

                // 由 initSdkWhenOpenApp 可知其实下面只会在初次进入主页，即 canPush = Unknown 时才会执行
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
    }

    private fun turnOffPushService(result: MethodChannel.Result) {
        runCatching {
            if (pushManager.isPushTurnedOn(context)) {
                pushManager.turnOffPush(context)
            }
            FlutterSharePreference.canPush = CanPushType.Not
        }.onSuccess {
            log("turn off push service success")
            result.success("")
        }.onFailure {
            log("turn off push service error : $it")
            result.error("", "", "")
        }
    }

    /**
     * 开启推送，并且设置 [FlutterSharePreference.canPush] = [CanPushType.Want]
     */
    private fun turnOnPushService() {
        if (!pushManager.isPushTurnedOn(context)) {
            pushManager.turnOnPush(context)
        }
        FlutterSharePreference.canPush = CanPushType.Want
    }

    /**
     * 检查通知权限并打开推送
     *
     * 如果有通知权限，则直接打开推送，如果没有通知权限，执行[notAllow]
     */
    private fun checkAndTurnOnPushService(notAllow: (result: MethodChannel.Result) -> Unit) {
        log("check notification permission")
        with(permissionResult) {
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
                notAllow(this)
            }
        }
    }

    /**
     * 通过[send]请求通知权限
     */
    private fun requestPushPermissionBy(result: MethodChannel.Result, send: () -> Unit) {
        permissionResult = result
        checkAndTurnOnPushService { r ->
            runCatching(send).onFailure {
                log("open notification config page error : $it")
                r.error(OPEN_NOTIFICATION_CONFIG_PAGE_ERROR, "", it.message)
            }
        }
    }

    /**
     * 打开系统通知权限页面
     */
    private fun openNotificationConfigPage() {
        // 参考个推 demo
        val intent = Intent().apply {
            when {
                Build.VERSION.SDK_INT >= 26 -> {
                    // android 8.0 + 引导
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

    /**
     * 是否开启通知权限
     *
     * 做双重检查，主要是两个方式不一样，一个是 NotificationManagerCompat,
     * 一个是 NotificationManagerCompat + AppOpsManager 反射
     */
    private val isNotificationEnabled: Boolean
        get() = NotificationManagerCompat.from(context)
            .areNotificationsEnabled() && pushManager.areNotificationsEnabled(context)

    /**
     * 点击通知进入微北洋
     *
     * 设置 MainActivity:  android:launchMode="singleInstance"
     *
     * 若 activity 进程还在，则调用 onNewIntent，
     *
     * 若 activity 进程没有，则调用 onCreate
     *
     * 什么情况会调用 handleIntent:
     *
     * 1.推送（通知栏）：
     *  Ⅰ：青年湖底推送
     *  Ⅱ：天外天官方推送
     *  Ⅲ：TODO:热修复通知推送
     *
     * 2.点击桌面小组件：暂时只有课程表小组件
     *
     * 现在统一进入微北洋的 url：wpy://wpy.app/open
     *
     * 如果是通过网页进入的微北洋，即通过 url scheme 打开，则 query 中携带 page 参数
     * 如： wpy://wpy.app/open?page=qnhd_summary  进入打开求实论坛年度总结页面
     *
     * 由于推送使用 intent 打开具体页面，而在有的手机上，intent携带的 data 会丢失，所以推送采用 extra 的方式携带参数
     *
     * @return
     * true: 拦截到对应事件
     *
     * false: 未拦截到对应事件
     */
    private fun handleIntent(intent: Intent): Boolean {
        log("WbyPushPlugin handle intent : $intent")

        // 走 url scheme 打开微北洋
        when (intent.data?.getQueryParameter("page")) {
            "qslt_summary" -> {
                log("jump from url")
                WBYApplication.eventList.add(
                    Event(IntentEvent.FeedbackSummaryPage.type, "null")
                )
                return true
            }
        }

        // 下面是走intent打开微北洋的拦截
        when (intent.getStringExtra("type")) {
            "qslt" -> {
                // 通过问题id打开页面
                intent.getIntExtra("question_id", -1).takeIf { it != -1 }?.let { id ->
                    log("question_id : $id")
                    WBYApplication.eventList.add(
                        Event(IntentEvent.FeedbackPostPage.type, id)
                    )
                    return true
                }
                // 进入年度总结页面
                intent.getStringExtra("page")?.takeIf { it == "summary" }?.let {
                    WBYApplication.eventList.add(
                        Event(IntentEvent.FeedbackSummaryPage.type, "null")
                    )
                    return true
                }
                // TODO：通过评论id进入相应页面

                // 如果没有获取到参数，则跳到主页
                return true
            }
            "mailbox" -> {
                // 打开微北洋推送
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
                // 升级
                WBYApplication.eventList.add(
                    Event(IntentEvent.Update.type, "update")
                )
                return true
            }
        }
        return false
    }

    /**
     * 应用在后台，点击推送或 url scheme拉起
     */
    override fun onNewIntent(intent: Intent): Boolean {
        intent.runCatching {
            return handleIntent(this)
        }
        return false
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        // onCreate 时拦截intent
        kotlin.runCatching { handleIntent(binding.activity.intent) }
        // 添加 intent 拦截
        binding.addOnNewIntentListener(this)
        this.binding = binding
        // 初始化 LocalBroadcast
        initBroadcast()
    }

    override fun onDetachedFromActivityForConfigChanges() {
        runCatching {
            binding.removeOnNewIntentListener(this)
            LocalBroadcastManager.getInstance(context).unregisterReceiver(receiver)
        }
    }

    // TODO: 试一下通知设置改变后，这里会不会有回调
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        binding.addOnNewIntentListener(this)
        this.binding = binding
        // 初始化 LocalBroadcast
        initBroadcast()
    }

    /**
     * 初始化本地广播
     *
     * 每次 [binding] 修改后，都需要重新注册广播
     */
    private fun initBroadcast() {
        // 初始化 LocalBroadcast
        runCatching {
            receiver = PushBroadCastReceiver(binding)
            val intentFilter = IntentFilter().apply {
//                addAction(DATA)
                addAction(CID)
                addDataScheme("wpy")
            }
            LocalBroadcastManager.getInstance(context).registerReceiver(receiver, intentFilter)
            log("init local broadcast success")
        }
    }

    override fun onDetachedFromActivity() {
        // 注销 LocalBroadcast
        kotlin.runCatching {
            LocalBroadcastManager.getInstance(context).unregisterReceiver(receiver)
        }
    }

    /**
     * 获取发送通知打开具体页面所用的 intent
     */
    private fun getIntentUri(call: MethodCall, result: MethodChannel.Result) {

        when (call.argument<String>("type")) {
            "qslt" -> {
                // 跳转问题详情页面
                call.argument<Int>("question_id")?.let { id ->
                    val intentUri = IntentUtil.getQsltQuestionUri(id, context)
                    log("get feedback intent success : $intentUri")
                    result.success(intentUri)
                    return
                }
                // 跳转校务总结页面
                call.argument<String>("page")?.takeIf { it == "summary" }?.let {
                    val intentUri = IntentUtil.getQsltSummaryUri(context)

                    log("get feedback intent success : $intentUri")
                    result.success(intentUri)
                    return
                }

                result.error("-1", "question_id can't be null!", "")
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

                val intentUri = IntentUtil.getBaseIntent(context).apply {
                    data = Uri.parse("${BASEURL}open")
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
                val intentUri = IntentUtil.getUpdateUri(context)

                log("get update intent success : $intentUri")
                result.success(intentUri)
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        //        const val DATA = "com.twt.service.PUSH_DATA"
        const val CID = "com.twt.service.PUSH_TOKEN"

        const val REQUEST_NOTIFICATION_PERMISSION = 303

        // TODO
        const val OPEN_PUSH_SERVICE_ERROR = "OPEN_PUSH_SERVICE_ERROR"
        const val OPEN_NOTIFICATION_CONFIG_PAGE_ERROR = "OPEN_NOTIFICATION_CONFIG_PAGE_ERROR"
        const val CHECK_NOTIFICATION_ENABLE_ERROR = "CHECK_NOTIFICATION_ENABLE_ERROR"
        const val INIT_GT_SDK_ERROR = "INIT_GT_SDK_ERROR"

        const val OPEN_REQUEST_NOTIFICATION_DIALOG_ERROR = "OPEN_REQUEST_NOTIFICATION_DIALOG_ERROR"
        const val FATAL_ERROR = "FATAL_ERROR"

        fun log(msg: String?) = LogUtil.d(TAG, msg.toString())
        const val TAG = "PUSH"
    }
}