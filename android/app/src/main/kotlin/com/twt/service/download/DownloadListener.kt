package com.twt.service.download

import android.app.DownloadManager
import com.twt.service.common.LogUtil
import io.flutter.plugin.common.MethodChannel

class DownloadListener(val plugin: WbyDownloadPlugin) {
    /**
     * 信息列表
     *
     * 使用[Map]保证不会有重复消息，使用 taskId 作为 key
     */
    val messageList = mutableMapOf<String, Map<String, *>>()

    /**
     * [MethodChannel.Result] 回调
     */
    val handler = object : MethodChannel.Result {
        override fun success(result: Any?) {
            messageList.clear()
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
            WbyDownloadPlugin.log("$errorCode + $errorMessage + $errorDetails")
        }

        override fun notImplemented() {
            WbyDownloadPlugin.log("")
        }

    }

    private fun report(arguments: List<Map<String, *>>) {
        WbyDownloadPlugin.log("arguments: $arguments")
        plugin.channel.invokeMethod("updateProgress", arguments, handler)
    }

    /**
     * 将信息列表中的数据发送到 flutter 端
     */
    fun apply() {
        if (messageList.isNotEmpty()) {
            report(messageList.values.toList())
        }
    }

    /**
     * 通过 downloadId 和 cursor 来获取当前下载状态
     *
     * @param task 下载任务
     * @param status 任务状态
     * @param progress 下载进度
     * @param reason 原因
     */
    fun updateStatus(task: DownloadTask, status: Int, progress: Double, reason: Any) {
        if (messageList.containsKey(task.id)) {
            WbyDownloadPlugin.log("messageList has task, taskId: ${task.id}")
        } else {
            WbyDownloadPlugin.log("updateStatus taskId: ${task.id}")
            val report = task.baseData()
            report["status"] = status
            report["progress"] = progress
            report["reason"] = reason.toString()
            messageList[task.id] = report
        }
    }

    /**
     * 通过 downloadId 更新任务状态
     *
     * @param id downloadId
     */
    fun updateStatus(id: Long) {
        val query = DownloadManager.Query().setFilterById(id)
        val cursor = plugin.manager.query(query)
        findTask(id) {
            updateStatus(
                it,
                status = cursor.status(),
                progress = cursor.progress(),
                reason = cursor.reason()
            )
        }
    }

    /**
     * 在数据库找不到下载信息了，就只能汇报错误
     *
     * @param task 下载任务
     */
    fun taskDisappear(task: DownloadTask) {
        WbyDownloadPlugin.log("taskDisappear")
        updateStatus(
            task,
            status = DownloadManager.STATUS_FAILED,
            progress = 0.0,
            reason = DownloadManager.ERROR_UNKNOWN
        )
    }

    /**
     * 通过downloadId，从[WbyDownloadPlugin.downloadList]中找到对应的下载项，如果没有找到，静默报错
     *
     * @param id downloadId
     * @param action 成功之后执行的函数
     */
    private fun findTask(id: Long, action: (task: DownloadTask) -> Unit) {
        val task = plugin.downloadList[id]
        if (task == null) {
            LogUtil.e(WbyDownloadPlugin.TAG, NullPointerException("can't find task $id"))
        } else {
            try {
                action(task)
            } catch (e: Throwable) {
                LogUtil.e(WbyDownloadPlugin.TAG, e)
            }
        }
    }
}