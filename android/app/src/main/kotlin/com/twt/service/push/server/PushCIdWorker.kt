package com.twt.service.push.server

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.twt.service.common.WbySharePreference
import com.twt.service.push.WbyPushPlugin

class PushCIdWorker(val context: Context, workerParams: WorkerParameters) : CoroutineWorker(context, workerParams) {
    override suspend fun doWork(): Result {
        try {
            val cid = inputData.getString("cid") ?: return Result.failure()
            WbyPushPlugin.log(cid)
            WbySharePreference.authToken?.let {
                val response = WBYServerAPI.pushCId(cid = cid)
                WbyPushPlugin.log(response.message)
                return Result.success()
            }
            return Result.failure()
        } catch (e: Exception) {
            return Result.failure()
        }
    }
}