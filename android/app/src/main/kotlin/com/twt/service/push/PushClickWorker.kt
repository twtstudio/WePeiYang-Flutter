package com.twt.service.push

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.twt.service.BuildConfig
import com.twt.service.common.FlutterSharePreference
import com.twt.service.push.server.WBYServerAPI
import retrofit2.HttpException
import java.io.IOException

/** Retries click reporting while keeping credentials and payloads out of logs. */
internal class PushClickWorker(
    context: Context,
    workerParams: WorkerParameters,
) : CoroutineWorker(context, workerParams) {

    override suspend fun doWork(): Result {
        val taskId = inputData.getString(TASK_ID)?.trim()?.takeIf { it.isNotEmpty() }
            ?: return Result.failure()
        val cid = inputData.getString(CID)?.trim()?.takeIf { it.isNotEmpty() }
            ?: return Result.failure()
        val messageId = inputData.getString(MESSAGE_ID)?.trim().orEmpty()
        val token = FlutterSharePreference.authToken?.trim()?.takeIf { it.isNotEmpty() }
            ?: return if (runAttemptCount < MAX_ATTEMPTS) Result.retry() else Result.failure()
        val appId = BuildConfig.PUSH_APP_ID.trim().takeIf { it.isNotEmpty() }
            ?: return Result.failure()
        val environment = BuildConfig.PUSH_ENVIRONMENT.trim().takeIf { it.isNotEmpty() }
            ?: return Result.failure()

        return try {
            val response = WBYServerAPI.reportPushClick(
                token = token,
                cid = cid,
                taskId = taskId,
                messageId = messageId,
                appId = appId,
                environment = environment,
                platform = "ANDROID",
                installId = PushCidStore.getOrCreateInstallId(applicationContext),
            )
            when {
                response.error_code == 0 -> Result.success()
                response.error_code in 40000..49999 -> Result.failure()
                runAttemptCount < MAX_ATTEMPTS -> Result.retry()
                else -> Result.failure()
            }
        } catch (e: HttpException) {
            if (e.code() in 400..499) {
                Result.failure()
            } else if (runAttemptCount < MAX_ATTEMPTS) {
                Result.retry()
            } else {
                Result.failure()
            }
        } catch (_: IOException) {
            if (runAttemptCount < MAX_ATTEMPTS) Result.retry() else Result.failure()
        } catch (e: Exception) {
            WbyPushPlugin.log("push click report failed type=${e.javaClass.simpleName}")
            Result.failure()
        }
    }

    companion object {
        const val TASK_ID = "taskId"
        const val MESSAGE_ID = "messageId"
        const val CID = "cid"
        private const val MAX_ATTEMPTS = 5
    }
}
