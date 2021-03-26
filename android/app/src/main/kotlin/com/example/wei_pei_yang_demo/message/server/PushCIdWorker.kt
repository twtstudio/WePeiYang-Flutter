package com.example.wei_pei_yang_demo.message.server

import android.content.Context
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.example.wei_pei_yang_demo.message.model.MessageDataBase

class PushCIdWorker(context: Context, workerParams: WorkerParameters) : CoroutineWorker(context, workerParams) {
    override suspend fun doWork(): Result {
        return try {
            val cid = inputData.getString("cid") ?: return Result.failure()
            Log.d("WBYCID", cid)
            MessageDataBase.authToken?.let {
                val response = WBYServerAPI.pushCId(cid = cid)
                Log.d("WBYCID", response.message)
                Result.success()
            }
            Result.failure()
        } catch (e: Exception) {
            Result.failure()
        }
    }
}