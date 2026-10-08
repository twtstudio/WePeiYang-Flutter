package com.twt.service.push

import android.content.Context
import java.util.UUID

/**
 * Stores the latest CID outside Flutter's preferences so a callback received
 * before the Flutter engine is attached is not lost.
 */
internal object PushCidStore {
    private const val PREFERENCES = "wby_push_state"
    private const val CID_KEY = "cid"
    private const val INSTALL_ID_KEY = "install_id"
    private const val REGISTRATION_ALLOWED_KEY = "registration_allowed"
    private const val USER_PREFERENCE_KEY = "user_preference"
    private const val REGISTRATION_GENERATION_KEY = "registration_generation"

    fun saveUserPreference(context: Context, preference: CanPushType) {
        if (preference == CanPushType.Unknown) return
        context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .edit()
            .putInt(USER_PREFERENCE_KEY, preference.value)
            .commit()
    }

    fun getUserPreference(context: Context): CanPushType {
        return when (context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .getInt(USER_PREFERENCE_KEY, CanPushType.Unknown.value)) {
            CanPushType.Not.value -> CanPushType.Not
            CanPushType.Want.value -> CanPushType.Want
            else -> CanPushType.Unknown
        }
    }

    fun save(context: Context, cid: String) {
        context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .edit()
            .putString(CID_KEY, cid.trim())
            .apply()
    }

    fun get(context: Context): String? {
        return context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .getString(CID_KEY, null)
            ?.trim()
            ?.takeIf { it.isNotEmpty() }
    }

    /**
     * Identifies one installation of one app package. SharedPreferences are
     * cleared on uninstall, so reinstalling the app naturally gets a new ID.
     */
    @Synchronized
    fun getOrCreateInstallId(context: Context): String {
        val preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
        preferences.getString(INSTALL_ID_KEY, null)
            ?.trim()
            ?.takeIf { it.isNotEmpty() }
            ?.let { return it }

        val installId = UUID.randomUUID().toString()
        // commit() makes the value immediately visible to a WorkManager worker
        // that may start as soon as the SDK callback schedules registration.
        preferences.edit().putString(INSTALL_ID_KEY, installId).commit()
        return installId
    }

    fun isRegistrationAllowed(context: Context): Boolean {
        return context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .getBoolean(REGISTRATION_ALLOWED_KEY, true)
    }

    fun getRegistrationGeneration(context: Context): Long =
        context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .getLong(REGISTRATION_GENERATION_KEY, 0L)

    @Synchronized
    fun isCurrentRegistration(context: Context, generation: Long): Boolean {
        val preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
        return generation >= 0 &&
            preferences.getBoolean(REGISTRATION_ALLOWED_KEY, true) &&
            preferences.getLong(REGISTRATION_GENERATION_KEY, 0L) == generation
    }

    @Synchronized
    fun setRegistrationAllowed(context: Context, allowed: Boolean) {
        val preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
        val editor = preferences.edit().putBoolean(REGISTRATION_ALLOWED_KEY, allowed)
        if (!allowed && preferences.getBoolean(REGISTRATION_ALLOWED_KEY, true)) {
            // Fence queued work from this session before Flutter clears its token.
            // Resuming push must not make a cancelled session's work current again.
            editor.putLong(REGISTRATION_GENERATION_KEY,
                preferences.getLong(REGISTRATION_GENERATION_KEY, 0L) + 1)
        }
        editor.commit()
    }
}
