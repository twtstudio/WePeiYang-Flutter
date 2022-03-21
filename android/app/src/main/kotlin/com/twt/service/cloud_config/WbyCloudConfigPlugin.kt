package com.twt.service.cloud_config

import com.twt.service.common.LogUtil
import com.twt.service.common.WbyPlugin
import com.umeng.cconfig.UMRemoteConfig
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class WbyCloudConfigPlugin : WbyPlugin() {
    override val name: String
        get() = "com.twt.service/cloud_config"

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        runCatching {
            when (call.method) {
                latest_version_data -> getConfig(latest_version_data, result)
                "getWebViews" -> getWebViews(result)
            }
        }.onFailure {
            LogUtil.e(TAG, it)
            result.error("GET CLOUD CONFIG ERROR", it.toString(), null)
        }
    }

    private fun getConfig(key: String, result: MethodChannel.Result) {
        result.success(UMRemoteConfig.getInstance().getConfigValue(key))
    }

    private fun getWebViews(result: MethodChannel.Result) {
        with(UMRemoteConfig.getInstance()) {
            val webViewList = getConfigValue("webViewList")?.split(",") ?: emptyList()
            val webViews = mutableListOf<Map<String, Any>>()
            for (page in webViewList) {
                val pageConfig = mapOf(
                    "page" to getConfigValue("${page}_title"),
                    "url" to getConfigValue(page),
                    "channels" to getConfigValue("${page}_channels"),
                )
                webViews.add(pageConfig)
            }
            result.success(webViews)
        }
    }

    companion object {
        const val latest_version_data = "latest_version_data"
        const val TAG = "WBY_CLOUD_CONFIG"
        fun log(msg: String) = LogUtil.d(TAG, msg)
    }
}