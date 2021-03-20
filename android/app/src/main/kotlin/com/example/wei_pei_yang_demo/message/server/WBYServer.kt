package com.example.wei_pei_yang_demo.message.server

import com.example.wei_pei_yang_demo.common.BaseServer
import retrofit2.http.GET

private object WBYServer : BaseServer(baseUrl = "")

interface WBYServerAPI {

    @GET("api/")
    suspend fun pushCId(): Data

    companion object : WBYServerAPI by WBYServer()

}

data class Data(
        val totalHits: Int
)