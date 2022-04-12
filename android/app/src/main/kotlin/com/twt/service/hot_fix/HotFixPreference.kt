package com.twt.service.hot_fix

import android.content.Context
import androidx.annotation.VisibleForTesting
import androidx.core.content.edit
import com.twt.service.BuildConfig
import com.twt.service.WBYApplication
import com.twt.service.common.FileUtil
import com.twt.service.common.LogUtil
import java.io.File

object HotFixPreference {
    private val preference by lazy {
        WBYApplication.context?.get()?.getSharedPreferences("fixSoFiles", Context.MODE_PRIVATE)
    }

    // 存储so文件的文件夹
    private val fixDir by lazy {
        WBYApplication.context?.get()?.let {
            FileUtil.fixDirectory(it)
        }
    }

    private const val fixSoKey = "fix_so"
    private const val currentUseKey = "current_use"
    private const val TAG = "WBY_HotFixPreference"

    // hotfix的更新方式为改变微北洋启动路径，在应用私有文件夹下创建hotfix文件夹，将热修复的.so文件存储在那里，然后向
    // WbySharePreference.fixSo中添加新获得的.so文件[名字]，存储方式为获取的所有.so文件列表
    // （当前版本，在应用更新后，不符合当前版本的.so文件将被清除）
    // 如果启动应用发生闪退，则猜测获得的热修复.so文件出现问题，在下次启动时将跳过该文件（存储值为 false），若启动成功将删除该文件，并且报告错误
    // 一定要保证.so文件名中没有"@"，存储的时候通过"@"隔断：name1@name2@name3...
    // 每个.so文件能否运行 ： path : canUse
    // 运行前设为false，运行后设为true
    const val listSplit = "@"

    /**
     * 设置热更新文件名以备下次启动时使用
     */
    fun checkAndSetFixSo(value: String?) {
        // value 为.so文件名字，第一次添加时我们假设这个文件时可以执行的
        value?.let { name ->
            preference?.let { pref ->
                val files = pref.getString(fixSoKey, "")!!.split("@")

                // 先清洗一次列表，去除不是这个版本的文件  （90-86-libapp 一定不会是90这个版本用的文件）
                val f = files.filter { it.isNotBlank() }.filter {
                    // 如果这个文件过期了或不能使用
                    val outDate = it.split("-").first().toInt() <= BuildConfig.VERSION_CODE
                    if (outDate or !pref.getBoolean(name, false)) {
                        fixDir?.runCatching {
                            File(this, it).delete()
                        }?.onFailure {
                            LogUtil.e(WbyFixPlugin.TAG, it)
                        }
                        pref.edit(true) {
                            remove(name)
                        }
                        return@filter false
                    }
                    // 剩下的都是可以用的
                    true
                }.toMutableList()

                if (f.contains(name)) {
                    // 如果本地已存在so文件，则将其设为可使用
                    pref.edit(true) {
                        putBoolean(name, true)
                    }
                } else {
                    // 本地不存在，则将其添加到名字列表的第一个，并且设为可使用
                    // 这样每次遍历列表必定从最新的开始
                    val newFiles = f.apply {
                        add(0, name)
                    }.joinToString("@")

                    WbyFixPlugin.log("---------------$newFiles")

                    pref.edit(true) {
                        putString(fixSoKey, newFiles)
                        putBoolean(name, true)
                    }
                }
            }
        }
    }

    /**
     * 获取最新的可使用的热修复文件
     */
    fun getCanUseFixSo(): String? {
        val soFile = preference?.let result@{ pref ->
            LogUtil.d(TAG, pref.all.toString())
            fixDir?.let { dir ->
                // 这个list大概长这样：  88-84-libapp@89-84-libapp@90-84-libapp
                // 那么后面的一定比前面的新
                fixSoFiles.forEach { name ->
                    // 保证.so文件上次运行时没发生问题，如果发生了问题就换下一个
                    val file = File(dir, "$name.so")
                    val canUse = pref.getBoolean(name, false)
                    LogUtil.d(TAG, "$name  $canUse ${file.path} ${file.exists()}")
                    if (canUse && file.exists()) {
                        pref.edit().let {
                            // 启动前：   canUse = false
                            // 启动后：   canUse = true
                            // 启动失败：  canUse still is false
                            it.putBoolean(name, false)
                            // 设置当前正在使用的so文件名
                            it.putString(currentUseKey, name)
                            // 立即同步
                            it.commit()
                        }
                        return@result file.path
                    }
                }
            }
            // 如果都没有满足的文件就加载原来的libapp.so文件
            return@result null
        }
        WbyFixPlugin.log("-------$soFile")
        return soFile
    }

    private var fixSoFiles: List<String>
        get() = preference?.getString(fixSoKey, "")?.split(listSplit) ?: emptyList()
        @VisibleForTesting
        set(value) {
            preference?.edit()?.let {
                it.putString(fixSoKey, value.joinToString(listSplit))
                it.commit()
            }
        }

    /**
     * 是否已下载热修复文件及是否可用
     * @return
     * null: 没有这个文件
     *
     * true: 有这个文件且能使用
     *
     * false: 有这个文件但不能使用
     */
    fun soFileContainAndCanUse(name: String): Boolean? {
        preference?.let { pref ->
            pref.getString(fixSoKey, null)?.split(listSplit)?.forEach {
                if (it == name) {
                    return pref.getBoolean(it, false)
                }
            }
        }
        return null
    }

    /**
     * 设置当前热修复文件可用
     *
     * 启动前：   canUse = false
     *
     * 启动后：   canUse = true
     *
     * 启动失败：  canUse still is false
     */
    fun setCurrentUseSoFileCanUse() {
        preference?.runCatching {
            getString(currentUseKey, null)?.let { path ->
                edit().let {
                    it.putBoolean(path, true)
                    it.commit()
                }
            }
        }
    }
}