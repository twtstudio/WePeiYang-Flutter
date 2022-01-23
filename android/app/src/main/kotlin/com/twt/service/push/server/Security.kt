package com.twt.service.push.server

import okhttp3.Interceptor
import okhttp3.Request

internal inline val Request.isTrusted
    get() = url.host in trustedHosts

private val trustedHosts = setOf("api.twt.edu.cn")

internal val Interceptor.forTrusted
    get() = Interceptor {
        if (it.request().isTrusted) intercept(it)
        else it.proceed(it.request())
    }
