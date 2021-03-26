package com.example.wei_pei_yang_demo.message.server

import com.example.wei_pei_yang_demo.common.WBYBaseData
import com.example.wei_pei_yang_demo.common.BaseServer
import com.example.wei_pei_yang_demo.message.model.FeedbackMessage
import okhttp3.OkHttpClient
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
                .connectTimeout(5, TimeUnit.SECONDS)
                .readTimeout(5, TimeUnit.SECONDS)
                .writeTimeout(5, TimeUnit.SECONDS)
                .addNetworkInterceptor(loggingInterceptor)
                .build()
}


interface FeedbackServerAPI {

    @GET("api/user/message/get")
    suspend fun getFeedbackMessage(
            @Query("token") token: String,
    ): FeedbackMessage

    @POST("api/user/message/read")
    suspend fun setMessageRead(
            @Field("token") token: String,
            @Field("message_id") id: String,
    )

    companion object : FeedbackServerAPI by FeedbackServer()

}