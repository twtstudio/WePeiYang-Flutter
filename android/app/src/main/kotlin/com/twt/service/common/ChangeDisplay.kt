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

// TODO: 目前想法是，这些放到flutter端，文字大小可在一定区间内改变，控件宽度不变，高度跟随字体大小改变

@SuppressLint("PrivateApi")
object ChangeDisplay {

    /**
     * 不进行文字大小改变，保持1：1
     */
    fun changeConfig(context: Context) {
        try {
            context.resources.configuration.apply {
                fontScale = 1F
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

    const val TAG = "CHANGE_DISPLAY"
}