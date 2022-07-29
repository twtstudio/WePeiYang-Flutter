package com.twt.service.cloud_config

import com.twt.service.common.LogUtil
import com.twt.service.common.WbyPlugin
import com.umeng.cconfig.UMRemoteConfig
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * 友盟在线参数
 *
 * [https://developer.umeng.com/docs/119267/detail/118637#title-z9f-vtl-7ep]
 */
class WbyCloudConfigPlugin : WbyPlugin() {
    override val name: String
        get() = "com.twt.service/cloud_config"

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        runCatching {
            when (call.method) {
                "latest_version_data_release" -> getConfig("latest_version_data_release", result)
                "latest_version_data_beta" -> getConfig("latest_version_data_beta", result)
                "getWebViews" -> getWebViews(result)
            }
        }.onFailure {
            LogUtil.e(TAG, it)
            result.error("GET CLOUD CONFIG ERROR", it.toString(), null)
        }
    }

    /**
     * 获取最新的在线参数
     *
     * 特别注意，在线参数只有在友盟上传数据时才能获得
     */
    private fun getConfig(key: String, result: MethodChannel.Result) {
        result.success(UMRemoteConfig.getInstance().getConfigValue(key))
    }

    /**
     * 获取有哪些 h5
     */
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
        const val TAG = "CLOUD_CONFIG"
        fun log(msg: String) = LogUtil.d(TAG, msg)
    }
}