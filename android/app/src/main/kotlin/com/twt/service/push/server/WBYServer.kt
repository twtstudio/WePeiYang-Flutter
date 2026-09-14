package com.twt.service.push.server

import com.twt.service.common.WBYBaseData
import com.twt.service.common.BaseServer
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor

import retrofit2.http.Field
import retrofit2.http.FormUrlEncoded
import retrofit2.http.Header
import retrofit2.http.POST
import retrofit2.http.Query
import java.util.concurrent.TimeUnit

private object WBYServer : BaseServer(baseUrl = "https://api.twt.edu.cn/api/") {
    private val loggingInterceptor = HttpLoggingInterceptor().apply {
        // HEADERS would include the JWT/ticket and the legacy CID query.
        // Registration already emits a redacted status log in the worker.
        level = HttpLoggingInterceptor.Level.NONE
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

    @FormUrlEncoded
    @POST("notification/device/register")
    suspend fun registerPushDevice(
        @Field("cid") cid: String,
        @Field("appId") appId: String,
        @Field("environment") environment: String,
        @Field("packageName") packageName: String,
        @Field("platform") platform: String,
        @Field("installId") installId: String,
    ): WBYBaseData<Any>

    @FormUrlEncoded
    @POST("notification/device/disable")
    suspend fun disablePushDevice(
        @Header("token") token: String,
        @Field("appId") appId: String,
        @Field("installId") installId: String,
    ): WBYBaseData<Any>

    @FormUrlEncoded
    @POST("notification/delivery/click")
    suspend fun reportPushClick(
        @Header("token") token: String,
        @Field("cid") cid: String,
        @Field("taskId") taskId: String,
        @Field("messageId") messageId: String,
        @Field("appId") appId: String,
        @Field("environment") environment: String,
        @Field("platform") platform: String,
        @Field("installId") installId: String,
    ): WBYBaseData<Any>

    @POST("notification/cid")
    suspend fun pushCId(
            @Query("cid") cid: String,
    ): WBYBaseData<Any>

    companion object : WBYServerAPI by WBYServer()
}
