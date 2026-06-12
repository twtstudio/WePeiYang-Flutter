package com.twt.service.device_info

import android.app.ActivityManager
import android.content.Context
import android.os.BatteryManager
import android.os.Build
import android.os.StatFs
import android.util.DisplayMetrics
import com.twt.service.common.WbyPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class WbyDeviceInfoPlugin : WbyPlugin() {
    override val name = "com.twt.service/device_info"

    private fun getSystemProperty(key: String, default: String = ""): String {
        return try {
            val clazz = Class.forName("android.os.SystemProperties")
            val method = clazz.getMethod("get", String::class.java, String::class.java)
            method.invoke(null, key, default) as? String ?: default
        } catch (_: Exception) {
            default
        }
    }

    private fun getRamInfo(): Map<String, String> {
        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        am.getMemoryInfo(memInfo)
        return mapOf<String, String>(
            "totalRam" to (memInfo.totalMem / (1024 * 1024)).toString(),
            "availRam" to (memInfo.availMem / (1024 * 1024)).toString(),
            "lowMemory" to memInfo.lowMemory.toString(),
        )
    }

    private fun getStorageInfo(): Map<String, String> {
        return try {
            val stat = StatFs(context.filesDir.absolutePath)
            val total = stat.blockCountLong * stat.blockSizeLong
            val avail = stat.availableBlocksLong * stat.blockSizeLong
            mapOf<String, String>(
                "storageTotal" to (total / (1024 * 1024 * 1024)).toString(),
                "storageAvail" to (avail / (1024 * 1024 * 1024)).toString(),
            )
        } catch (_: Exception) {
            mapOf("storageTotal" to "0", "storageAvail" to "0")
        }
    }

    private fun getBatteryInfo(): Map<String, String> {
        return try {
            val bm = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            mapOf<String, String>(
                "batteryPct" to bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY).toString(),
            )
        } catch (_: Exception) {
            mapOf("batteryPct" to "-1")
        }
    }

    private fun getRefreshRate(): Float {
        return try {
            val wm = context.getSystemService(Context.WINDOW_SERVICE) as android.view.WindowManager
            wm.defaultDisplay.refreshRate
        } catch (_: Exception) {
            0f
        }
    }

    private fun getDensityInfo(): Map<String, Any> {
        val dm = context.resources.displayMetrics
        return mapOf<String, Any>(
            "densityDpi" to dm.densityDpi,
            "density" to dm.density.toDouble(),
            "scaledDensity" to dm.scaledDensity.toDouble(),
            "refreshRate" to getRefreshRate().toDouble(),
        )
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "getDeviceInfo") {
            result.success(
                mapOf<String, Any>(
                    "manufacturer" to Build.MANUFACTURER,
                    "brand" to Build.BRAND,
                    "model" to Build.MODEL,
                    "display" to Build.DISPLAY,
                    "versionRelease" to Build.VERSION.RELEASE,
                    "sdkInt" to Build.VERSION.SDK_INT.toString(),
                    "incremental" to Build.VERSION.INCREMENTAL,
                    "fingerprint" to Build.FINGERPRINT,
                    "hardware" to Build.HARDWARE,
                    "type" to Build.TYPE,
                    "tags" to Build.TAGS,
                    "buildTime" to Build.TIME.toString(),
                    "supportedAbis" to Build.SUPPORTED_ABIS.joinToString(", "),
                    "miuiVersion" to getSystemProperty("ro.miui.ui.version.name", "非 MIUI"),
                    "hyperosVersion" to getSystemProperty("ro.mi.os.version.name", ""),
                    "serial" to getSystemProperty("ro.serialno", ""),
                    "ram" to getRamInfo(),
                    "storage" to getStorageInfo(),
                    "battery" to getBatteryInfo(),
                    "density" to getDensityInfo(),
                )
            )
        } else {
            result.notImplemented()
        }
    }
}
