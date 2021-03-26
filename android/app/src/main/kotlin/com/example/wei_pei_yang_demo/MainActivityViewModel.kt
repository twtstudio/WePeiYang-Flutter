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
                val response = FeedbackServerAPI.getFeedbackMessage(token)
                MessageDataBase.feedbackMessageList = response.data
            }.invokeOnCompletion {
                Log.d("WBYERROR",it.toString())
            }
            result.success(0)
        }
    }

    fun clearFeedbackMessageCount(result: MethodChannel.Result) {
        MessageDataBase.feedbackMessageCount = 0
        result.success(0)
    }

}