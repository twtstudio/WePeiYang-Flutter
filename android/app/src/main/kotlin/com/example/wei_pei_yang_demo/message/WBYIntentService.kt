package com.example.wei_pei_yang_demo.message

import android.content.Context
import android.os.Message
import android.util.Log
import com.example.wei_pei_yang_demo.WBYApplication
import com.google.gson.Gson
import com.igexin.sdk.GTIntentService
import com.igexin.sdk.PushManager
import com.igexin.sdk.message.GTCmdMessage
import com.igexin.sdk.message.GTNotificationMessage
import com.igexin.sdk.message.GTTransmitMessage
import java.lang.Exception

class WBYIntentService : GTIntentService() {

    companion object {
        const val TAG = "WBYDemo"
    }

    override fun onReceiveServicePid(p0: Context?, p1: Int) {
//        TODO("Not yet implemented")
    }

    override fun onReceiveClientId(p0: Context?, clientid: String?) {
//        TODO("Not yet implemented")
        Log.e(TAG, "onReceiveClientId -> clientid = $clientid")
        clientid?.let {
            sendMessage(it, WBYApplication.Companion.MyHandler.RECEIVE_CLIENT_ID)
        }
    }

    override fun onReceiveMessageData(context: Context?, msg: GTTransmitMessage?) {
        val appid = msg?.appid
        val taskid = msg?.taskId
        val messageid = msg?.messageId
        val payload = msg?.payload
        val pkg = msg?.pkgName
        val cid = msg?.clientId

        // 第三方回执调用接口，actionid范围为90000-90999，可根据业务场景执行

        // 第三方回执调用接口，actionid范围为90000-90999，可根据业务场景执行
//        val result = PushManager.getInstance().sendFeedbackMessage(context, taskid, messageid, 90001)
//        Log.d(TAG, "call sendFeedbackMessage = " + if (result) "success" else "failed")

        Log.d(TAG, """
            onReceiveMessageData -> appid = $appid
            taskid = $taskid
            messageid = $messageid
            pkg = $pkg
            cid = $cid
             """.trimIndent())

        if (payload == null) {
            Log.e(TAG, "receiver payload = null")
        } else {
            val data = String(payload)
            Log.d(TAG, "receiver payload = $data")
            sendMessage(data, WBYApplication.Companion.MyHandler.RECEIVE_MESSAGE_DATA)
        }

        Log.d(TAG, "----------------------------------------------------------------------------------------------")
    }

    override fun onReceiveOnlineState(p0: Context?, p1: Boolean) {
//        TODO("Not yet implemented")
    }

    override fun onReceiveCommandResult(p0: Context?, p1: GTCmdMessage?) {
//        TODO("Not yet implemented")
    }

    override fun onNotificationMessageArrived(p0: Context?, message: GTNotificationMessage?) {
        Log.d(TAG, "onNotificationMessageArrived -> "
                + "appid = " + message?.appid
                + "\ntaskid = " + message?.taskId
                + "\nmessageid = " + message?.messageId
                + "\npkg = " + message?.pkgName
                + "\ncid = " + message?.clientId
                + "\ncontent = " + message?.content
                + "\ntitle = " + message?.title);
    }

    override fun onNotificationMessageClicked(p0: Context?, message: GTNotificationMessage?) {
        message?.content?.let {
            sendMessage(it, 2)
        }
        Log.d(TAG, "onNotificationMessageArrived -> "
                + "appid = " + message?.appid
                + "\ntaskid = " + message?.taskId
                + "\nmessageid = " + message?.messageId
                + "\npkg = " + message?.pkgName
                + "\ncid = " + message?.clientId
                + "\ncontent = " + message?.content
                + "\ntitle = " + message?.title);


    }

    private fun sendMessage(data: String, what: Int) {
        val msg = Message.obtain()
        msg.what = what
        msg.obj = data
        WBYApplication.sendMessage(msg)
    }
}