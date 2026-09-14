package com.twt.service.push

import android.content.Context
import androidx.work.BackoffPolicy
import androidx.work.Constraints
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

/** Reports provider-rendered notification clicks without logging payload data. */
internal object PushClickReporter {
    fun report(context: Context?, taskId: String?, messageId: String?, cid: String?) {
        val appContext = context?.applicationContext ?: return
        val normalizedTaskId = taskId?.trim()?.takeIf { it.isNotEmpty() } ?: return
        val normalizedCid = cid?.trim()?.takeIf { it.isNotEmpty() } ?: return
        val normalizedMessageId = messageId?.trim().orEmpty()
        runCatching {
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .setRequiresStorageNotLow(true)
                .build()
            val request = OneTimeWorkRequest.Builder(PushClickWorker::class.java)
                .setInputData(
                    androidx.work.workDataOf(
                        PushClickWorker.TASK_ID to normalizedTaskId,
                        PushClickWorker.MESSAGE_ID to normalizedMessageId,
                        PushClickWorker.CID to normalizedCid,
                    )
                )
                .setConstraints(constraints)
                .setBackoffCriteria(BackoffPolicy.EXPONENTIAL, 30, TimeUnit.SECONDS)
                .build()
            WorkManager.getInstance(appContext).enqueue(request)
        }.onFailure {
            WbyPushPlugin.log("push click report task unavailable")
        }
    }
}
