package com.twt.service

import android.Manifest
import android.annotation.TargetApi
import android.app.AlertDialog
import android.content.DialogInterface
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.KeyEvent
import io.flutter.embedding.android.FlutterFragmentActivity
import java.util.*


/**
 * 继承了Activity，实现Android6.0的运行时权限检测
 * 需要进行运行时权限检测的Activity可以继承这个类
 *
 * @创建时间：2016年5月27日 下午3:01:31
 * @项目名称： AMapLocationDemo
 * @author hongming.wang
 * @文件名称：PermissionsChecker.java
 * @类型名称：PermissionsChecker
 * @since 2.5.0
 */
open class CheckPermissionsActivity : FlutterFragmentActivity() {
    //是否需要检测后台定位权限，设置为true时，如果用户没有给予后台定位权限会弹窗提示
    private val needCheckBackLocation = false

    /**
     * 需要进行检测的权限数组
     */
    protected var needPermissions = arrayOf(
            Manifest.permission.ACCESS_COARSE_LOCATION,
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.READ_PHONE_STATE
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT > 28
                && applicationContext.applicationInfo.targetSdkVersion > 28) {
            needPermissions = arrayOf(
                    Manifest.permission.ACCESS_COARSE_LOCATION,
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE,
                    Manifest.permission.READ_EXTERNAL_STORAGE,
                    Manifest.permission.READ_PHONE_STATE,
                    BACKGROUND_LOCATION_PERMISSION
            )
        }
    }

    /**
     * 判断是否需要检测，防止不停的弹框
     */
    private var isNeedCheck = true
    override fun onResume() {
        super.onResume()
        if (Build.VERSION.SDK_INT >= 23
                && applicationInfo.targetSdkVersion >= 23) {
            if (isNeedCheck) {
                checkPermissions(needPermissions)
            }
        }
    }

    /**
     *
     * @param permissions
     * @since 2.5.0
     */
    private fun checkPermissions(permissions: Array<String>) {
        try {
            if (Build.VERSION.SDK_INT >= 23
                    && applicationInfo.targetSdkVersion >= 23) {
                val needRequestPermissionList = findDeniedPermissions(permissions)
                if (needRequestPermissionList.isNotEmpty()) {
                    val array = needRequestPermissionList.toTypedArray()
                    val method = javaClass.getMethod("requestPermissions", *arrayOf<Class<*>?>(Array<String>::class.java,
                            Int::class.javaPrimitiveType))
                    method.invoke(this, array, PERMISSON_REQUESTCODE)
                }
            }
        } catch (e: Throwable) {
        }
    }

    /**
     * 获取权限集中需要申请权限的列表
     *
     * @param permissions
     * @return
     * @since 2.5.0
     */
    private fun findDeniedPermissions(permissions: Array<String>): List<String> {
        val needRequestPermissonList: MutableList<String> = ArrayList()
        if (Build.VERSION.SDK_INT >= 23
                && applicationInfo.targetSdkVersion >= 23) {
            try {
                for (perm in permissions) {
                    val checkSelfMethod = javaClass.getMethod("checkSelfPermission", String::class.java)
                    val shouldShowRequestPermissionRationaleMethod = javaClass.getMethod("shouldShowRequestPermissionRationale",
                            String::class.java)
                    if (checkSelfMethod.invoke(this, perm) as Int != PackageManager.PERMISSION_GRANTED
                            || shouldShowRequestPermissionRationaleMethod.invoke(this, perm) as Boolean) {
                        if (!needCheckBackLocation
                                && BACKGROUND_LOCATION_PERMISSION == perm) {
                            continue
                        }
                        needRequestPermissonList.add(perm)
                    }
                }
            } catch (e: Throwable) {
            }
        }
        return needRequestPermissonList
    }

    /**
     * 检测是否所有的权限都已经授权
     * @param grantResults
     * @return
     * @since 2.5.0
     */
    private fun verifyPermissions(grantResults: IntArray): Boolean {
        for (result in grantResults) {
            if (result != PackageManager.PERMISSION_GRANTED) {
                return false
            }
        }
        return true
    }

    @TargetApi(23)
    override fun onRequestPermissionsResult(
            requestCode: Int,
            permissions: Array<String>, paramArrayOfInt: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, paramArrayOfInt)
        if (requestCode == PERMISSON_REQUESTCODE) {
            if (!verifyPermissions(paramArrayOfInt)) {
                showMissingPermissionDialog()
                isNeedCheck = false
            }
        }
    }

    /**
     * 显示提示信息
     *
     * @since 2.5.0
     */
    private fun showMissingPermissionDialog() {
        val builder = AlertDialog.Builder(this)
        builder.setTitle("提示")
        builder.setMessage("当前应用缺少必要权限。\\n\\n请点击\\\"设置\\\"-\\\"权限\\\"-打开所需权限。")

        // 拒绝, 退出应用
        builder.setNegativeButton("取消",
                DialogInterface.OnClickListener { dialog, which -> finish() })
        builder.setPositiveButton("设置",
                DialogInterface.OnClickListener { dialog, which -> startAppSettings() })
        builder.setCancelable(false)
        builder.show()
    }

    /**
     * 启动应用的设置
     *
     * @since 2.5.0
     */
    private fun startAppSettings() {
        val intent = Intent(
                Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        intent.data = Uri.parse("package:$packageName")
        startActivity(intent)
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            finish()
            return true
        }
        return super.onKeyDown(keyCode, event)
    }

    companion object {
        //如果设置了target > 28，需要增加这个权限，否则不会弹出"始终允许"这个选择框
        private const val BACKGROUND_LOCATION_PERMISSION = "android.permission.ACCESS_BACKGROUND_LOCATION"
        private const val PERMISSON_REQUESTCODE = 0
    }
}