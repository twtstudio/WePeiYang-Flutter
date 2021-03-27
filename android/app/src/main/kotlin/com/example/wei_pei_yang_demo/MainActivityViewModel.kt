package com.example.wei_pei_yang_demo

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.wei_pei_yang_demo.message.model.MessageDataBase
import com.example.wei_pei_yang_demo.message.server.FeedbackServerAPI
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.launch

class MainActivityViewModel : ViewModel() {

    fun refreshFeedbackMessage(result: MethodChannel.Result) {
        MessageDataBase.feedbackToken?.let { token ->
            viewModelScope.launch {
                FeedbackServerAPI.getUserData(token).data?.let {
                    MessageDataBase.feedbackBaseData = it
                    MessageDataBase.feedbackMessage = FeedbackServerAPI.getFeedbackMessage(token)
                    result.success(MessageDataBase.feedbackMessageCount)
                }
            }.invokeOnCompletion {
                it?.let {
                    Log.d("WBYERROR", it.toString())
                    result.success(0)
                }
            }
        }
    }

    fun setMessageReadById(result: MethodChannel.Result, id: Int?) =
            MessageDataBase.feedbackToken?.let { token ->
                id?.let {
                    viewModelScope.launch {
                        FeedbackServerAPI.setMessageRead(token = token, id = it).apply {
                            when (ErrorCode) {
                                0 -> {
                                    result.success(0)
                                }
                                else -> {
                                    result.error(ErrorCode.toString(),msg,msg)
                                }
                            }
                        }
                    }.invokeOnCompletion {
                        it?.let {
                            Log.d("WBYERROR", it.toString())
                            result.error("0", it.message.toString(), it.message)
                        }
                    }
                }
            }

}