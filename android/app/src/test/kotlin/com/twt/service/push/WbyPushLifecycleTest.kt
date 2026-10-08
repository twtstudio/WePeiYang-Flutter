package com.twt.service.push

import android.app.Application
import android.content.Context
import com.twt.service.WBYApplication
import com.twt.service.common.FlutterSharePreference
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.*
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config
import java.lang.ref.WeakReference

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [28], application = Application::class, manifest = Config.NONE)
class WbyPushLifecycleTest {
    private lateinit var context: Context
    private lateinit var sdk: PushSdk
    private lateinit var plugin: WbyPushPlugin

    @Before
    fun setUp() {
        context = RuntimeEnvironment.getApplication()
        WBYApplication.context = WeakReference(context)
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .edit().clear().commit()
        context.getSharedPreferences("wby_push_state", Context.MODE_PRIVATE)
            .edit().clear().commit()
        sdk = mock(PushSdk::class.java)
        `when`(sdk.isPushTurnedOn(context)).thenReturn(true)
        `when`(sdk.areNotificationsEnabled(context)).thenReturn(true)
        plugin = WbyPushPlugin(sdk).also { it.context = context }
    }

    @After
    fun tearDown() {
        WBYApplication.context = null
    }

    @Test
    fun logoutStopsReceptionEvenWhenRemoteDisableCannotBeAuthenticated() {
        FlutterSharePreference.canPush = CanPushType.Want
        val result = call("disablePushDevice")

        assertEquals(false, result.value)
        assertFalse(PushCidStore.isRegistrationAllowed(context))
        assertEquals(CanPushType.Want, FlutterSharePreference.canPush)
        verify(sdk).turnOffPush(context)

        // Even a late SDK read that still reports "on" must not enqueue a CID.
        assertNull(call("getCid").value)
        verify(sdk, never()).getClientid(context)
    }

    @Test
    fun logoutStillBlocksRegistrationIfVendorStopThrows() {
        FlutterSharePreference.canPush = CanPushType.Want
        doThrow(IllegalStateException("SDK unavailable")).`when`(sdk).turnOffPush(context)

        assertEquals(false, call("disablePushDevice").value)
        assertFalse(PushCidStore.isRegistrationAllowed(context))
        assertNull(call("getCid").value)
    }

    @Test
    fun nextLoginRestoresAllowedPushAfterFlutterPreferencesWereCleared() {
        FlutterSharePreference.canPush = CanPushType.Want
        call("disablePushDevice")
        clearFlutterPreferences()
        setLoginToken()
        `when`(sdk.isPushTurnedOn(context)).thenReturn(false)

        assertEquals(CanPushType.Want, FlutterSharePreference.canPush)
        assertEquals("open push service success", call("initGeTuiSdk").value)
        assertTrue(PushCidStore.isRegistrationAllowed(context))
        verify(sdk).initialize(context)
        verify(sdk).turnOnPush(context)
    }

    @Test
    fun nextLoginDoesNotOverrideTheUsersDisabledPreference() {
        FlutterSharePreference.canPush = CanPushType.Not
        call("disablePushDevice")
        clearFlutterPreferences()
        setLoginToken()

        assertEquals("refuse open push", call("initGeTuiSdk").value)
        assertEquals(CanPushType.Not, FlutterSharePreference.canPush)
        assertFalse(PushCidStore.isRegistrationAllowed(context))
        verify(sdk, never()).turnOnPush(context)
        verify(sdk, never()).initialize(context)
    }

    @Test
    fun initializationWithoutLoginDoesNotResumeSavedPushPreference() {
        FlutterSharePreference.canPush = CanPushType.Want

        assertEquals("refuse open push", call("initGeTuiSdk").value)
        assertFalse(PushCidStore.isRegistrationAllowed(context))
        verify(sdk, never()).turnOnPush(context)
        verify(sdk, never()).initialize(context)
    }

    @Test
    fun attachingAnEngineDoesNotResumeAPausedSession() {
        FlutterSharePreference.canPush = CanPushType.Want
        setLoginToken()
        PushCidStore.setRegistrationAllowed(context, false)
        val binding = mock(FlutterPlugin.FlutterPluginBinding::class.java)
        `when`(binding.applicationContext).thenReturn(context)
        `when`(binding.binaryMessenger).thenReturn(mock(BinaryMessenger::class.java))

        plugin.onAttachedToEngine(binding)

        assertFalse(PushCidStore.isRegistrationAllowed(context))
        assertEquals(CanPushType.Want, FlutterSharePreference.canPush)
        verify(sdk, never()).turnOnPush(context)
        verify(sdk).turnOffPush(context)
        plugin.onDetachedFromEngine(binding)
    }

    private fun clearFlutterPreferences() {
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .edit().clear().commit()
    }

    private fun setLoginToken() {
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .edit().putString("flutter.token", "test-login-token").commit()
    }

    private fun call(method: String): Result = Result().also {
        plugin.onMethodCall(MethodCall(method, null), it)
        assertNull("Unexpected platform error", it.error)
    }

    private class Result : MethodChannel.Result {
        var value: Any? = null
        var error: String? = null
        override fun success(result: Any?) { value = result }
        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
            error = "$errorCode: $errorMessage"
        }
        override fun notImplemented() { error = "not implemented" }
    }
}
