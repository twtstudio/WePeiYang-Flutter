package com.twt.service.push

import android.content.Context
import android.util.Log
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.igexin.sdk.GTIntentService
import com.igexin.sdk.PushConsts
import com.igexin.sdk.message.GTCmdMessage
import com.igexin.sdk.message.GTNotificationMessage
import com.igexin.sdk.message.GTTransmitMessage
import com.twt.service.common.IntentUtil


class WBYIntentService : GTIntentService() {
    companion object {
        const val TAG = "WBY"
    }

    override fun onReceiveServicePid(p0: Context?, p1: Int) {
    }

    override fun onReceiveClientId(p0: Context?, clientid: String?) {
        Log.e(WbyPushPlugin.TAG, "onReceiveClientId -> clientid = $clientid")
        if (!clientid.isNullOrEmpty()) {
            val intent = IntentUtil.cid(clientid)
            LocalBroadcastManager.getInstance(this).sendBroadcast(intent)
        }
    }

    // 暂时不用透传，不过先写到这里，因为一些重要通知肯定要透传
    override fun onReceiveMessageData(context: Context?, msg: GTTransmitMessage?) {
        val appid = msg?.appid
        val taskid = msg?.taskId
        val messageid = msg?.messageId
        val payload = msg?.payload
        val pkg = msg?.pkgName
        val cid = msg?.clientId

        // 第三方回执调用接口，actionid范围为90000-90999，可根据业务场景执行
        // val result = PushManager.getInstance().sendFeedbackMessage(context, taskid, messageid, 90001)
        // Log.d(TAG, "call sendFeedbackMessage = " + if (result) "success" else "failed")
        Log.d(
                WbyPushPlugin.TAG, """
            onReceiveMessageData -> appid = $appid
            taskid = $taskid
            messageid = $messageid
            pkg = $pkg
            cid = $cid
             """.trimIndent()
        )

        if (payload == null) {
            Log.e(WbyPushPlugin.TAG, "receiver payload = null")
        } else {
            val data = String(payload)
            Log.d(WbyPushPlugin.TAG, "receiver payload = $data")
            val intent = IntentUtil.messageData(data)
            LocalBroadcastManager.getInstance(this).sendBroadcast(intent)
        }
        Log.d(
                WbyPushPlugin.TAG,
                "----------------------------------------------------------------------------------------------"
        )
    }

    override fun onReceiveOnlineState(context: Context?, online: Boolean) {
        // TODO: 监听推送状态
    }

    override fun onReceiveCommandResult(context: Context?, cmdMessage: GTCmdMessage?) {
        // TODO: 命令回执
        Log.d(WbyPushPlugin.TAG, "onReceiveCommandResult -> $cmdMessage")
        /* action 结果值说明
       10009：设置标签的结果回执
       10010：绑定别名的结果回执
       10011：解绑别名的结果回执
       10006：自定义回执的结果回执 */
        when (cmdMessage?.action) {
            PushConsts.SET_TAG_RESULT -> {
                //            setTagResult(cmdMessage as SetTagCmdMessage?)
            }
            PushConsts.BIND_ALIAS_RESULT -> {
                //            bindAliasResult(cmdMessage as BindAliasCmdMessage?)
            }
            PushConsts.UNBIND_ALIAS_RESULT -> {
                //            unbindAliasResult(cmdMessage as UnBindAliasCmdMessage?)
            }
            PushConsts.THIRDPART_FEEDBACK -> {
                //            feedbackResult(cmdMessage as FeedbackCmdMessage?)
            }
        }
    }

    // 通知到达时回调该接口（仅支持个推 SDK 通道下发的通知）
    override fun onNotificationMessageArrived(p0: Context?, message: GTNotificationMessage?) {
        Log.d(
                WbyPushPlugin.TAG, "onNotificationMessageArrived -> "
                + "appid = " + message?.appid
                + "\ntaskid = " + message?.taskId
                + "\nmessageid = " + message?.messageId
                + "\npkg = " + message?.pkgName
                + "\ncid = " + message?.clientId
                + "\ncontent = " + message?.content
                + "\ntitle = " + message?.title
        )
    }

    // 通知点击回调接口（仅支持个推 SDK 通道下发的通知）
    override fun onNotificationMessageClicked(p0: Context?, message: GTNotificationMessage?) {
        Log.d(
                WbyPushPlugin.TAG, "onNotificationMessageArrived -> "
                + "appid = " + message?.appid
                + "\ntaskid = " + message?.taskId
                + "\nmessageid = " + message?.messageId
                + "\npkg = " + message?.pkgName
                + "\ncid = " + message?.clientId
                + "\ncontent = " + message?.content
                + "\ntitle = " + message?.title
        )
    }

    // 厂商 Token 回调 （该接口为非必须实现接口）
    override fun onReceiveDeviceToken(p0: Context?, token: String?) {
        super.onReceiveDeviceToken(p0, token)
    }
}