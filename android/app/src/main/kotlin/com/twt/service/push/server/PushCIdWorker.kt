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
import kotlinx.coroutines.CancellationException

class PushCIdWorker internal constructor(
    val context: Context,
    workerParams: WorkerParameters,
    private val server: WBYServerAPI,
) : CoroutineWorker(context, workerParams) {
    constructor(context: Context, workerParams: WorkerParameters) : this(context, workerParams, WBYServerAPI)

    override suspend fun doWork(): Result {
        try {
            val cid = inputData.getString("cid")?.trim()?.takeIf { it.isNotEmpty() }
                ?: return Result.failure()
            val generation = inputData.getLong(PushCidSync.GENERATION_KEY, -1L)
            return PushCidSync.withLifecycleLock {
                // Logout may have happened while this task was waiting for the lock.
                // A subsequent login must not revive that old task, even for the same account.
                if (!PushCidStore.isCurrentRegistration(context, generation) ||
                    FlutterSharePreference.canPush != CanPushType.Want) {
                    WbyPushPlugin.log("CID registration skipped by lifecycle state")
                    return@withLifecycleLock Result.success()
                }
                val token = FlutterSharePreference.authToken?.trim()?.takeIf { it.isNotEmpty() }
                if (token == null) {
                    WbyPushPlugin.log("CID registration postponed until login")
                    return@withLifecycleLock retryOrFailure()
                }
                // Pass the captured token explicitly instead of reading mutable preferences
                // again from the HTTP interceptor after another login/logout has started.
                val response = registerDevice(cid, token)
                WbyPushPlugin.log("CID registration response code=${response.error_code}")
                when {
                    response.error_code == 0 -> Result.success()
                    response.error_code in 40000..49999 -> Result.failure()
                    else -> retryOrFailure()
                }
            }
        } catch (e: CancellationException) {
            throw e
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

    private suspend fun registerDevice(cid: String, token: String): WBYBaseData<Any> {
        val appId = BuildConfig.PUSH_APP_ID.trim()
        val environment = BuildConfig.PUSH_ENVIRONMENT.trim()
        if (appId.isEmpty() || environment.isEmpty()) {
            throw IllegalStateException("push registration metadata missing")
        }
        return server.registerPushDevice(
            token = token,
            cid = cid,
            appId = appId,
            environment = environment,
            packageName = context.packageName,
            platform = "ANDROID",
            installId = PushCidStore.getOrCreateInstallId(context),
        )
    }

    companion object {
        private const val MAX_ATTEMPTS = 5
    }
}
