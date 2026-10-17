package com.twt.service.push

import android.content.Context
import com.igexin.sdk.PushManager

/** Keeps local lifecycle tests independent of the vendor's native runtime. */
internal interface PushSdk {
    fun initialize(context: Context)
    fun turnOnPush(context: Context)
    fun turnOffPush(context: Context)
    fun isPushTurnedOn(context: Context): Boolean
    fun areNotificationsEnabled(context: Context): Boolean
    fun getClientid(context: Context): String?
    fun setDebugLogger(context: Context, logger: (String?) -> Unit)
}

internal class GetuiPushSdk : PushSdk {
    private val delegate by lazy { PushManager.getInstance() }
    override fun initialize(context: Context) = delegate.initialize(context)
    override fun turnOnPush(context: Context) = delegate.turnOnPush(context)
    override fun turnOffPush(context: Context) = delegate.turnOffPush(context)
    override fun isPushTurnedOn(context: Context) = delegate.isPushTurnedOn(context)
    override fun areNotificationsEnabled(context: Context) = delegate.areNotificationsEnabled(context)
    override fun getClientid(context: Context): String? = delegate.getClientid(context)
    override fun setDebugLogger(context: Context, logger: (String?) -> Unit) {
        delegate.setDebugLogger(context) { logger(it) }
    }
}
