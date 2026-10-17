package com.twt.service.push.server

import android.app.Application
import android.content.Context
import androidx.work.Data
import androidx.work.ListenableWorker
import androidx.work.WorkerParameters
import com.twt.service.WBYApplication
import com.twt.service.common.FlutterSharePreference
import com.twt.service.common.WBYBaseData
import com.twt.service.push.CanPushType
import com.twt.service.push.PushCidStore
import com.twt.service.push.PushCidSync
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineStart
import kotlinx.coroutines.async
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.*
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config
import java.io.IOException
import java.lang.ref.WeakReference

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [28], application = Application::class, manifest = Config.NONE)
class PushCIdWorkerTest {
    private lateinit var context: Context
    private lateinit var server: RecordingServer

    @Before
    fun setUp() {
        context = RuntimeEnvironment.getApplication()
        WBYApplication.context = WeakReference(context)
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .edit().clear().commit()
        context.getSharedPreferences("wby_push_state", Context.MODE_PRIVATE)
            .edit().clear().commit()
        FlutterSharePreference.canPush = CanPushType.Want
        setToken("test-first-session")
        server = RecordingServer()
    }

    @After
    fun tearDown() { WBYApplication.context = null }

    @Test
    fun queuedRegistrationCannotReviveAfterLogoutAndLoginWithTheSameCid() = runBlocking {
        val oldWorker = worker()
        val pending = PushCidSync.withLifecycleLock {
            val waiting = async(start = CoroutineStart.UNDISPATCHED) { oldWorker.doWork() }
            PushCidStore.setRegistrationAllowed(context, false)
            setToken("test-second-session")
            PushCidStore.setRegistrationAllowed(context, true)
            waiting
        }

        assertEquals(ListenableWorker.Result.success(), pending.await())
        assertTrue(server.requests.isEmpty())
        assertEquals(ListenableWorker.Result.success(), worker().doWork())
        assertEquals(listOf("test-second-session" to "test-cid"), server.requests)
    }

    @Test
    fun logoutWhileWaitingForTheLockPreventsRegistration() = runBlocking {
        val currentWorker = worker()
        val pending = PushCidSync.withLifecycleLock {
            val waiting = async(start = CoroutineStart.UNDISPATCHED) { currentWorker.doWork() }
            PushCidStore.setRegistrationAllowed(context, false)
            waiting
        }

        assertEquals(ListenableWorker.Result.success(), pending.await())
        assertTrue(server.requests.isEmpty())
    }

    @Test
    fun userDisablingPushIsCheckedAfterTheLockIsAcquired() = runBlocking {
        val currentWorker = worker()
        val pending = PushCidSync.withLifecycleLock {
            val waiting = async(start = CoroutineStart.UNDISPATCHED) { currentWorker.doWork() }
            FlutterSharePreference.canPush = CanPushType.Not
            waiting
        }

        assertEquals(ListenableWorker.Result.success(), pending.await())
        assertTrue(server.requests.isEmpty())
    }

    @Test
    fun requestKeepsItsCapturedTokenWhenPreferencesChangeDuringSending() = runBlocking {
        server.onRegister = { setToken("test-later-token") }

        assertEquals(ListenableWorker.Result.success(), worker().doWork())
        assertEquals(listOf("test-first-session" to "test-cid"), server.requests)
        assertEquals("test-later-token", FlutterSharePreference.authToken)
    }

    @Test
    fun legacyQueuedWorkWithoutAGenerationIsDiscarded() = runBlocking {
        assertEquals(ListenableWorker.Result.success(), worker(generation = null).doWork())
        assertTrue(server.requests.isEmpty())
    }

    @Test
    fun networkFailureRetriesButStillHonorsTheRetryLimit() = runBlocking {
        server.onRegister = { throw IOException("test offline") }

        assertEquals(ListenableWorker.Result.retry(), worker(attempt = 0).doWork())
        assertEquals(ListenableWorker.Result.failure(), worker(attempt = 5).doWork())
        assertEquals(2, server.requests.size)
    }

    @Test
    fun authenticationRejectionDoesNotRetry() = runBlocking {
        server.response = WBYBaseData(40001, "test rejected", null)

        assertEquals(ListenableWorker.Result.failure(), worker().doWork())
        assertEquals(1, server.requests.size)
    }

    @Test
    fun cancellationIsPropagatedInsteadOfBecomingARetryOrFailure() {
        server.onRegister = { throw CancellationException("test cancelled") }
        assertThrows(CancellationException::class.java) {
            runBlocking { worker().doWork() }
        }
    }

    private fun worker(
        generation: Long? = PushCidStore.getRegistrationGeneration(context),
        attempt: Int = 0,
    ): PushCIdWorker {
        val data = Data.Builder().putString("cid", "test-cid").apply {
            generation?.let { putLong(PushCidSync.GENERATION_KEY, it) }
        }.build()
        val parameters = mock(WorkerParameters::class.java, RETURNS_DEEP_STUBS)
        `when`(parameters.inputData).thenReturn(data)
        `when`(parameters.runAttemptCount).thenReturn(attempt)
        return PushCIdWorker(context, parameters, server)
    }

    private fun setToken(token: String) {
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .edit().putString("flutter.token", token).commit()
    }

    private class RecordingServer : WBYServerAPI {
        val requests = mutableListOf<Pair<String, String>>()
        var onRegister: () -> Unit = {}
        var response: WBYBaseData<Any> = WBYBaseData(0, "test accepted", null)

        override suspend fun registerPushDevice(
            token: String,
            cid: String,
            appId: String,
            environment: String,
            packageName: String,
            platform: String,
            installId: String,
        ): WBYBaseData<Any> {
            requests += token to cid
            onRegister()
            return response
        }

        override suspend fun disablePushDevice(
            token: String,
            appId: String,
            installId: String,
        ): WBYBaseData<Any> = throw AssertionError("Worker must not disable devices")
    }
}
