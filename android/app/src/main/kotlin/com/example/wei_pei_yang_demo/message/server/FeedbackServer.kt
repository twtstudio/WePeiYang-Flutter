package com.example.wei_pei_yang_demo.message.server

import com.example.wei_pei_yang_demo.common.BaseServer
import com.example.wei_pei_yang_demo.message.model.FeedbackBaseData
import com.example.wei_pei_yang_demo.message.model.FeedbackMessageBaseData
import com.example.wei_pei_yang_demo.message.model.User
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.http.*
import java.util.concurrent.TimeUnit

private object FeedbackServer : BaseServer(baseUrl = "http://47.94.198.197:10805/") {
    private val loggingInterceptor = HttpLoggingInterceptor().apply {
        level = HttpLoggingInterceptor.Level.HEADERS
    }

    override val client: OkHttpClient
        get() = OkHttpClient.Builder()
                .retryOnConnectionFailure(false)
                .addInterceptor(UnconnectedInterceptor)
                .connectTimeout(5, TimeUnit.SECONDS)
                .readTimeout(5, TimeUnit.SECONDS)
                .writeTimeout(5, TimeUnit.SECONDS)
                .addNetworkInterceptor(loggingInterceptor)
                .build()
}

internal inline val Request.unconnected
    get() = with(newBuilder()) {
        addHeader("Connection", "close")
    }.build()

internal object UnconnectedInterceptor : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response = chain.proceed(chain.request().unconnected)
}


interface FeedbackServerAPI {

    @GET("api/user/message/get")
    suspend fun getFeedbackMessage(
            @Query("token") token: String,
    ): FeedbackMessageBaseData

    @FormUrlEncoded
    @POST("api/user/message/read")
    suspend fun setMessageRead(
            @Field("token") token: String,
            @Field("message_id") id: Int,
    ): FeedbackBaseData<Any>

    @GET("api/user/userData")
    suspend fun getUserData(
            @Query("token") token: String,
    ): FeedbackBaseData<User>

    companion object : FeedbackServerAPI by FeedbackServer()

}