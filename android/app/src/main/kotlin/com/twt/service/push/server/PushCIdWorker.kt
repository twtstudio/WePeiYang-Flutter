package com.twt.service.push.server

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.twt.service.BuildConfig
import com.twt.service.common.WBYBaseData
import com.twt.service.common.FlutterSharePreference
import com.twt.service.push.CanPushType
import com.twt.service.push.PushCidStore
import com.twt.service.push.PushCidSync
import com.twt.service.push.WbyPushPlugin

class PushCIdWorker(val context: Context, workerParams: WorkerParameters) : CoroutineWorker(context, workerParams) {
    override suspend fun doWork(): Result {
        try {
            val cid = inputData.getString("cid")?.trim()?.takeIf { it.isNotEmpty() }
                ?: return Result.failure()
            if (FlutterSharePreference.canPush == CanPushType.Not) {
                WbyPushPlugin.log("CID registration skipped because push is disabled")
                return Result.success()
            }
            if (!PushCidStore.isRegistrationAllowed(context)) {
                WbyPushPlugin.log("CID registration skipped by lifecycle state")
                return Result.success()
            }
            val token = FlutterSharePreference.authToken
            if (token.isNullOrEmpty()) {
                WbyPushPlugin.log("CID registration postponed until login")
                return if (runAttemptCount < 5) Result.retry() else Result.failure()
            }
            val response = PushCidSync.withLifecycleLock {
                registerDevice(cid)
            }
            WbyPushPlugin.log("CID registration response code=${response.error_code}")
            return when {
                response.error_code == 0 -> Result.success()
                response.error_code in 40000..49999 -> Result.failure()
                else -> retryOrFailure()
            }
        } catch (e: retrofit2.HttpException) {
            WbyPushPlugin.log("CID registration HTTP ${e.code()}")
            return if (e.code() in 400..499) Result.failure() else retryOrFailure()
        } catch (e: java.io.IOException) {
            WbyPushPlugin.log("CID registration network error")
            return retryOrFailure()
        } catch (e: Exception) {
            WbyPushPlugin.log("CID registration failed: ${e.javaClass.simpleName}")
            // Unknown/serialization errors are not expected to recover by
            // retrying forever; a later CID callback or foreground sync can
            // enqueue a fresh request.
            return Result.failure()
        }
    }

    private fun retryOrFailure(): Result {
        return if (runAttemptCount < MAX_ATTEMPTS) Result.retry() else Result.failure()
    }

    private suspend fun registerDevice(cid: String): WBYBaseData<Any> {
        val appId = BuildConfig.PUSH_APP_ID.trim()
        val environment = BuildConfig.PUSH_ENVIRONMENT.trim()
        if (appId.isEmpty() || environment.isEmpty()) {
            WbyPushPlugin.log("CID registration skipped because build metadata is missing")
            return WBYServerAPI.pushCId(cid)
        }

        return try {
            WBYServerAPI.registerPushDevice(
                cid = cid,
                appId = appId,
                environment = environment,
                packageName = context.packageName,
                platform = "ANDROID",
                installId = PushCidStore.getOrCreateInstallId(context),
            )
        } catch (e: retrofit2.HttpException) {
            // Keep old clients and deployments working while opencenter rolls
            // out /notification/device/register. Do not hide auth or server
            // failures behind the legacy endpoint.
            if (e.code() != 404 && e.code() != 405) throw e
            WbyPushPlugin.log("new CID registration endpoint unavailable; using legacy endpoint")
            WBYServerAPI.pushCId(cid)
        }
    }

    companion object {
        private const val MAX_ATTEMPTS = 5
    }
}
