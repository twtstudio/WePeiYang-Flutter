package com.twt.service.common

import android.content.Context
import android.util.Log
import com.twt.service.BuildConfig
import com.twt.service.WBYApplication
import com.twt.service.widget.WbyWidgetPlugin
import java.io.File

object WbySharePreference {
    private val flutterSharedPreferences by lazy {
        WBYApplication.context?.get()
                ?.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    }
    private val fixSoSharedPreferences by lazy {
        WBYApplication.context?.get()
                ?.getSharedPreferences("fixSoFiles", Context.MODE_PRIVATE)
    }

    const val TAG = "WBY_SHARE_PREFERENCE"
    fun log(message: String) = LogUtil.d(TAG, message)

    private const val authTokenKey = "flutter.token"
    private const val canPushKey = "flutter.can_push"
    private const val fixSoKey = "fix_so"
    private const val currentUseKey = "current_use"

    val authToken: String?
        get() = flutterSharedPreferences?.getString(authTokenKey, null).also {
            log( "authToken : $it")
        }

    // hotfix的更新方式为改变微北洋启动路径，在应用私有文件夹下创建hotfix文件夹，将热修复的.so文件存储在那里，然后向
    // WbySharePreference.fixSo中添加新获得的.so文件路径，存储方式为获取的所有.so文件列表（当前版本，在应用更新后，
    // 不符合当前版本的.so文件将被清除）。如果启动应用发生闪退，则猜测获得的热修复.so文件出现问题，在下次启动时将跳过该
    // 文件（存储值为 false），若启动成功将删除该文件，并且报告错误
    // 一定要保证.so文件名中没有"@"，存储的时候通过"@"隔断：path1@path2@path3...
    // 每个.so文件能否运行 ： path : canUse
    // 运行前设为false，运行后设为true
    const val listSplit = "@"
    var fixSo: String?
        get() {
            fixSoSharedPreferences?.let { pref ->
                log(pref.all.toString())
                pref.getString(fixSoKey, null)
                        ?.split(listSplit)?.forEach { path ->
                            // 保证.so文件上次运行时没发生问题，如果发生了问题就换下一个
                            val file = File(path)
                            val canUse = pref.getBoolean(path, false)
                            log("$path  $canUse")
                            if (canUse && file.exists() && file.extension == "so") {
                                pref.edit().let {
                                    it.putBoolean(path, false)
                                    it.putString(currentUseKey, path)
                                    it.commit()
                                }
                                return path
                            }
                        }
            }
            // 如果都没有满足的文件就加载原来的libapp.so文件
            return null
        }
        set(value) {
            // value 为.so文件路径，第一次添加时我们假设这个文件时可以执行的
            value?.takeIf {
                val allow = it.isNotBlank() && !it.contains(listSplit)
                if (allow) {
                    return@takeIf allow
                } else {
                    throw IllegalArgumentException("illegal file path")
                }
            }?.let { path ->
                fixSoSharedPreferences?.let { pref ->
                    pref.getString(fixSoKey, "")?.takeIf { !it.contains(path) }?.let { list ->
                        // 把list清洗一次
                        val files = mutableListOf(path)

                        list.takeIf { it.isNotBlank() }?.split(listSplit)?.forEach { soFile ->
                            soFile.split(File.separator).last().split("-").takeIf { it.size == 3 }?.runCatching {
                                // fileName = "$versionCode-$fixCode-libapp.so"
                                val versionCode = this[0].toIntOrNull()
                                val fixCode = this[1].toIntOrNull()
                                if (versionCode == null || fixCode == null) {
                                    throw Exception("")
                                }
                                File(soFile).takeIf { it.exists() }?.let {
                                    if (versionCode - fixCode > BuildConfig.VERSION_CODE) {
                                        it.deleteOnExit()
                                    } else {
                                        files.add(soFile)
                                    }
                                }
                            }
                        }

                        val c1: Comparator<String> = Comparator { o1, o2 ->
                            val s1 = o1.split(File.separator).last().split("-")
                            val s2 = o2.split(File.separator).last().split("-")
                            if (s1[0] == s2[0]) {
                                s1[1].compareTo(s2[1])
                            } else {
                                s1[0].compareTo(s2[0])
                            }
                        }

                        files.sortWith(c1)
                        val result = files.joinToString(listSplit)

                        pref.edit()?.let {
                            it.putString(fixSoKey, result)
                            it.putBoolean(path, true)
                            it.commit()
                        }
                    }
                }
            }
        }

    var fixSoFiles: List<String>
        get() = fixSoSharedPreferences?.getString(fixSoKey, "")?.split(listSplit) ?: emptyList()
        set(value) {
            fixSoSharedPreferences?.edit()?.let {
                it.putString(fixSoKey, value.joinToString(listSplit))
                it.commit()
            }
        }

    fun soFileContainAndCanUse(path: String): Boolean {
        fixSoSharedPreferences?.let { pref ->
            pref.getString(fixSoKey, null)?.split(listSplit)?.forEach {
                if (it == path && pref.getBoolean(it, false)) {
                    return true
                }
            }
        }
        return false
    }

    fun setCurrentUseSoFileCanUse() {
        fixSoSharedPreferences?.let { pref ->
            pref.getString(currentUseKey, null)?.let { path ->
                pref.edit().let {
                    it.putBoolean(path, true)
                    it.commit()
                }
            }
        }
    }

    var canPush: CanPushType
        get() = with(flutterSharedPreferences?.getInt(canPushKey, CanPushType.Unknown.value)) {
            return@with when (this) {
                1 -> CanPushType.Not
                2 -> CanPushType.Want
                else -> CanPushType.Unknown
            }
        }.also {
            log( "canPush : $it")
        }
        set(type) {
            flutterSharedPreferences?.edit()?.let {
                it.putInt(canPushKey, type.value)
                it.commit()
            }
        }

    val allowAgreement: Boolean
        get() = !authToken.isNullOrEmpty()
}

enum class CanPushType(val value: Int) {
    Unknown(0), Not(1), Want(2)
}