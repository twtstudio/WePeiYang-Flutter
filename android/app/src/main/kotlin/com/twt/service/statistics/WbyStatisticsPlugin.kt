package com.twt.service.statistics

import android.util.Log
import com.twt.service.common.LogUtil
import com.twt.service.common.WbyPlugin
import com.umeng.analytics.MobclickAgent
import com.umeng.commonsdk.UMConfigure
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class WbyStatisticsPlugin : WbyPlugin() {

    override val name: String
        get() = "com.twt.service/umeng_statistics"

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "initCommon" -> initCommon()
                "onProfileSignIn" -> onProfileSignIn(call)
                "onProfileSignOff" -> onProfileSignOff()
                "onEvent" -> onEvent(call)
                "onPageStart" -> onPageStart(call)
                "onPageEnd" -> onPageEnd(call)
                "reportError" -> reportError(call)
                else -> result.notImplemented()
            }
            result.success("")
        } catch (e: Exception) {
            result.error("", "", null)
            Log.e("Umeng", "Exception:" + e.message)
        }
    }

    private fun initCommon() {
        UMConfigure.init(
            context,
            "60464782b8c8d45c1390e7e3",
            "android",
            UMConfigure.DEVICE_TYPE_PHONE,
            null
        )
        MobclickAgent.setPageCollectionMode(MobclickAgent.PageMode.MANUAL)
        log("友盟sdk初始化")
    }

    // 埋点
    private fun onEvent(call: MethodCall) {
        val event = call.argument<String>("event")
        val map = call.argument<Map<String, *>>("map")
        MobclickAgent.onEventObject(context, event, map)
        log("event : $event , map : $map")
    }

    private fun onPageStart(call: MethodCall) {
        val page = call.argument<String>("page")
        MobclickAgent.onPageStart(page)
        log("onPageStart:$page")
    }

    private fun onPageEnd(call: MethodCall) {
        val event = call.argument<String>("page")
        MobclickAgent.onPageEnd(event)
        log("onPageEnd:$event")
    }

    private fun reportError(call: MethodCall) {
        val error = call.argument<String>("error")
        MobclickAgent.reportError(context, error)
        log("reportError:$error")
    }

    private fun onProfileSignIn(call: MethodCall) {
        val userID = call.argument<String>("userID")
        MobclickAgent.onProfileSignIn(userID)
        log("sign in: $userID")
    }

    private fun onProfileSignOff() {
        MobclickAgent.onProfileSignOff()
        log("sign off")
    }

    companion object {
        const val TAG = "WBY_UMENG_STATISTICS"
        fun log(message: String) = LogUtil.d(TAG, message)
    }
}