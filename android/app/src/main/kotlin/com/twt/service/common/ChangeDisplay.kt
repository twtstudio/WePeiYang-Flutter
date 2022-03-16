package com.twt.service.common

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.res.Configuration
import android.view.Display
import java.lang.reflect.Method

// 参考：
// https://blog.csdn.net/duyiqun/article/details/96976197
// https://www.jianshu.com/p/c4944ea4b85f

@SuppressLint("PrivateApi")
object ChangeDisplay {

    /**
     * 不进行文字和显示大小改变，保持1：1
     */
    fun changeConfig(context: Context) {
        try {
            context.resources.configuration.apply {
                fontScale = 1F
//                densityDpi = defaultDisplayDensity
            }
        } catch (e: Throwable) {
            LogUtil.e(TAG, e)
        }
    }

    /**
     * 当更改手机字体大小，或显示大小后，重启activity
     */
    fun recreateWhenConfigChange(newConfig: Configuration, activity: Activity) {
        if ( /* newConfig.densityDpi != defaultDisplayDensity || */ newConfig.fontScale != 1F) {
            LogUtil.d(TAG, "recreate activity")
            activity.recreate()
        }
    }

    /**
     * 获取手机出厂时默认的densityDpi
     */
    val defaultDisplayDensity by lazy {
        try {
            val aClass = Class.forName("android.view.WindowManagerGlobal")
            val method: Method = aClass.getMethod("getWindowManagerService")
            method.isAccessible = true
            val iwm = method.invoke(aClass)
            val getInitialDisplayDensity: Method = iwm.javaClass.getMethod(
                "getInitialDisplayDensity",
                Int::class.javaPrimitiveType
            )
            getInitialDisplayDensity.isAccessible = true
            val densityDpi = getInitialDisplayDensity.invoke(iwm, Display.DEFAULT_DISPLAY)
            densityDpi as Int
        } catch (e: Exception) {
            LogUtil.e(TAG, e)
            Configuration.DENSITY_DPI_UNDEFINED
        }
    }

    const val TAG = "WBY_CHANGE_DISPLAY"
}