package com.twt.service.cloud_config

import com.twt.service.BuildConfig
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
                latest_version_code -> getConfig(latest_version_code, result)
                update_time -> getConfig(update_time, result)
                "getLatestVersion" -> getLatestVersion(result)
            }
        }.onFailure {
            LogUtil.e(TAG, it)
            result.error("GET CLOUD CONFIG ERROR", it.toString(), null)
        }
    }

    private fun getConfig(key: String, result: MethodChannel.Result) {
        result.success(UMRemoteConfig.getInstance().getConfigValue(key))
    }

    private fun getLatestVersion(result: MethodChannel.Result) {
        with(UMRemoteConfig.getInstance()) {
            val versionCode = getConfigValue(latest_version_code)?.toIntOrNull()
                ?: BuildConfig.VERSION_CODE
            val version = getConfigValue(latest_version) ?: BuildConfig.VERSION_NAME
            val content = getConfigValue(update_content) ?: ""
            val isForced = getConfigValue(update_force)?.toIntOrNull() ?: 0
            val time = getConfigValue(update_time) ?: ""
            val path = getConfigValue(update_apk_path) ?: ""
            val apkSize = getConfigValue(update_apk_size) ?: ""
            val flutterFixCode = getConfigValue(update_so_support_version)?.toIntOrNull() ?: 0
            val flutterFixSo = getConfigValue(update_so_path) ?: ""
            val flutterSoFileSize = getConfigValue(update_so_size) ?: ""

            val latestVersion = mapOf(
                "versionCode" to versionCode,
                "version" to version,
                "content" to content,
                "isForced" to isForced,
                "time" to time,
                "path" to path,
                "apkSize" to apkSize,
                "flutterFixCode" to flutterFixCode,
                "flutterFixSo" to flutterFixSo,
                "fileSize" to flutterSoFileSize
            )

            result.success(latestVersion)
        }
    }

    companion object {
        const val latest_version_code = "latest_version_code"
        const val latest_version = "latest_version"
        const val update_content = "update_content"
        const val update_force = "update_force"
        const val update_apk_path = "update_apk_path"
        const val update_apk_size = "update_apk_size"
        const val update_so_path = "update_so_path"
        const val update_so_size = "update_so_size"
        const val update_so_support_version = "update_so_support_version"
        const val update_time = "update_time"
        const val TAG = "WBY_CLOUD_CONFIG"
    }
}