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
}
