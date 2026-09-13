package com.twt.service.push

import android.content.Context
import androidx.work.BackoffPolicy
import androidx.work.Constraints
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import androidx.work.workDataOf
import com.twt.service.push.server.PushCIdWorker
import java.util.concurrent.TimeUnit

/** Enqueues one replaceable CID registration task for the current install. */
internal object PushCidSync {
    private const val WORK_NAME = "register_push_device"

    fun enqueue(context: Context, cid: String?) {
        val normalizedCid = cid?.trim()?.takeIf { it.isNotEmpty() } ?: return
        runCatching {
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .setRequiresStorageNotLow(true)
                .build()
            val request = OneTimeWorkRequest.Builder(PushCIdWorker::class.java)
                .setInputData(workDataOf("cid" to normalizedCid))
                .setConstraints(constraints)
                .setBackoffCriteria(BackoffPolicy.EXPONENTIAL, 30, TimeUnit.SECONDS)
                .addTag(WORK_NAME)
                .build()
            WorkManager.getInstance(context.applicationContext)
                .enqueueUniqueWork(WORK_NAME, ExistingWorkPolicy.REPLACE, request)
        }.onFailure {
            // WorkManager may not be initialized during an early SDK callback;
            // the CID remains persisted and the next foreground getCid() call
            // will enqueue it again.
            WbyPushPlugin.log("CID registration task unavailable")
        }
    }

    fun cancel(context: Context) {
        runCatching {
            WorkManager.getInstance(context.applicationContext).cancelUniqueWork(WORK_NAME)
        }.onFailure {
            WbyPushPlugin.log("CID registration task cancellation unavailable")
        }
    }
}
