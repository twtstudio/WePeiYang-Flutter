package com.twt.service.push.server

import android.util.Base64
import com.twt.service.common.FlutterSharePreference
import okhttp3.Interceptor
import okhttp3.Request
import okhttp3.Response

internal const val APP_KEY = "banana"

internal const val APP_SECRET = "37b590063d593716405a2c5a382b1130b28bf8a7"

internal const val DOMAIN = "weipeiyang.twt.edu.cn"


internal val Request.signed: Request
    get() {
        val token = header("token") ?: FlutterSharePreference.authToken.orEmpty()
        return with(newBuilder()) {
            addHeader("DOMAIN", DOMAIN)
            addHeader(
                "ticket",
                Base64.encodeToString("$APP_KEY.$APP_SECRET".toByteArray(), Base64.NO_WRAP)
            )
            // A lifecycle request may capture the token before Flutter clears it
            // during logout. Preserve an explicitly supplied header in that case.
            header("token", token)
        }.build()
    }

internal object SignatureInterceptor : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response = chain.proceed(chain.request().signed)
}
