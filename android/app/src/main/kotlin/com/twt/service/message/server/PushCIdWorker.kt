package com.twt.service.message.server

import android.content.Context
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.twt.service.message.model.MessageDataBase

class PushCIdWorker(context: Context, workerParams: WorkerParameters) : CoroutineWorker(context, workerParams) {
    override suspend fun doWork(): Result {
        try {
            val cid = inputData.getString("cid") ?: return Result.failure()
            Log.d("WBYCID", cid)
            MessageDataBase.authToken?.let {
                val response = WBYServerAPI.pushCId(cid = cid)
                Log.d("WBYCID", response.message)
                return Result.success()
            }
            return Result.failure()
        } catch (e: Exception) {
            return Result.failure()
        }
    }
}