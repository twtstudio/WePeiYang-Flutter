package com.twt.service.message.server

import com.twt.service.common.WBYBaseData
import com.twt.service.common.BaseServer
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor

import retrofit2.http.POST
import retrofit2.http.Query
import java.util.concurrent.TimeUnit

private object WBYServer : BaseServer(baseUrl = "https://api.twt.edu.cn/api/") {
    private val loggingInterceptor = HttpLoggingInterceptor().apply {
        level = HttpLoggingInterceptor.Level.HEADERS
    }

    override val client: OkHttpClient
        get() = OkHttpClient.Builder()
                .retryOnConnectionFailure(false)
                .addInterceptor(SignatureInterceptor.forTrusted)
                .connectTimeout(5, TimeUnit.SECONDS)
                .readTimeout(5, TimeUnit.SECONDS)
                .writeTimeout(5, TimeUnit.SECONDS)
                .addNetworkInterceptor(loggingInterceptor)
                .build()
}


interface WBYServerAPI {

    @POST("notification/cid")
    suspend fun pushCId(
            @Query("cid") cid: String,
    ): WBYBaseData<Any>

    companion object : WBYServerAPI by WBYServer()

}