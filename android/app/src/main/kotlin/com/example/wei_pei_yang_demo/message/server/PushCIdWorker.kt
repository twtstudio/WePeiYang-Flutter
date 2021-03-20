package com.example.wei_pei_yang_demo.message.server

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters

class PushCIdWorker(context: Context, workerParams: WorkerParameters) : CoroutineWorker(context, workerParams) {
    override suspend fun doWork(): Result {
        return try {
//            val response = WBYServerAPI.pushCId()
            Result.success()
        } catch (e: Exception) {
            Result.failure()
        }
    }
}