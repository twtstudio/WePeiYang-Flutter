package com.twt.service.common

import android.content.Context
import com.twt.service.WBYApplication
import com.twt.service.push.CanPushType

/**
 * android 原生获取 flutter sharePreference
 *
 * https://blog.csdn.net/codekxx/article/details/102475084
 */
object FlutterSharePreference {
    private val flutterSharedPreferences by lazy {
        WBYApplication.context?.get()
            ?.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    }

    const val TAG = "SHARE_PREFERENCE"

    private const val authTokenKey = "flutter.token"
    private const val canPushKey = "flutter.can_push"

    /**
     * 天外天登录token
     */
    val authToken: String?
        get() = flutterSharedPreferences?.getString(authTokenKey, null).also {
            LogUtil.d(TAG, "authToken : $it")
        }

    /**
     * 能否使用推送
     * @return CanPushType
     */
    var canPush: CanPushType
        get() = with(flutterSharedPreferences?.getInt(canPushKey, CanPushType.Unknown.value)) {
            return@with when (this) {
                1 -> CanPushType.Not
                2 -> CanPushType.Want
                else -> CanPushType.Unknown
            }
        }.also {
            LogUtil.d(TAG, "canPush : $it")
        }
        set(type) {
            flutterSharedPreferences?.edit()?.let {
                it.putInt(canPushKey, type.value)
                it.commit()
            }
        }

    /**
     * 是否同意了隐私协议
     *
     * 如果同意了的话，那么就本地有token
     */
    val allowAgreement: Boolean
        get() = !authToken.isNullOrEmpty()
}