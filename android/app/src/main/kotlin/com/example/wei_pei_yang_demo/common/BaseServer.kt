package com.example.wei_pei_yang_demo.common

import com.google.gson.GsonBuilder
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

abstract class BaseServer(baseUrl:String) {

    val client = OkHttpClient.Builder()
            .retryOnConnectionFailure(false)
            .build()

    open val retrofit: Retrofit = Retrofit.Builder()
            .baseUrl(baseUrl)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create(GsonBuilder().create()))
            .build()

    inline operator fun <reified T> invoke(): T = retrofit.create(T::class.java)
}