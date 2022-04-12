package com.twt.service.download

import android.app.DownloadManager

interface DownloadStatusAction {
    /**
     * [DownloadManager.STATUS_PENDING]回调
     *
     * @param id 添加到下载列表后，拿到的id
     */
    fun pending(id: Long)

    /**
     * [DownloadManager.STATUS_RUNNING]回调
     *
     * @param id 添加到下载列表后，拿到的id
     * @param progress 下载进度
     */
    fun running(id: Long, progress: Double)

    /**
     * [DownloadManager.STATUS_PAUSED]回调
     *
     * @param id 添加到下载列表后，拿到的id
     */
    fun paused(id: Long, progress: Double, detail: String)

    /**
     * [DownloadManager.STATUS_SUCCESSFUL]回调
     *
     * 这里并不需要传下载文件路径，因为这是已知的
     *
     * @param id 添加到下载列表后，拿到的id
     */
    fun successful(id: Long)

    /**
     * [DownloadManager.STATUS_FAILED]回调
     *
     * @param id 添加到下载列表后，拿到的id
     * @param progress 下载失败时的进度
     * @param detail 失败信息
     * @param error 具体抛出的错误（可选）
     */
    fun failed(id: Long, progress: Double, detail: String, error: Throwable? = null)
}