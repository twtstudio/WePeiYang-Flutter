package com.twt.service.push.server

import android.util.Base64
import com.twt.service.push.model.AuthToken
import okhttp3.Interceptor
import okhttp3.Request
import okhttp3.Response

internal const val APP_KEY = "banana"

internal const val APP_SECRET = "37b590063d593716405a2c5a382b1130b28bf8a7"

internal const val DOMAIN = "weipeiyang.twt.edu.cn"


internal inline val Request.signed
    get() = with(newBuilder()) {
        addHeader("DOMAIN", DOMAIN)
        addHeader("ticket", Base64.encodeToString("$APP_KEY.$APP_SECRET".toByteArray(), Base64.NO_WRAP))
        addHeader("token", AuthToken.authToken.orEmpty())
    }.build()

internal object SignatureInterceptor : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response = chain.proceed(chain.request().signed)
}