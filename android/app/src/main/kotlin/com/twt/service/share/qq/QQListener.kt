package com.twt.service.share.qq

import com.tencent.tauth.DefaultUiListener
import com.tencent.tauth.UiError
import com.twt.service.share.WbySharePlugin

class QQListener(val plugin: WbySharePlugin) : DefaultUiListener() {
    override fun onComplete(obj: Any?) {
        WbySharePlugin.log("success : $obj")
        plugin.result.success("")
    }

    override fun onError(error: UiError?) {
        WbySharePlugin.log("error : $error")
        plugin.result.error("", "qq share error", "$error")
    }

    override fun onCancel() {
        WbySharePlugin.log("cancel")
        plugin.result.success("cancel")
    }

    override fun onWarning(code: Int) {
        WbySharePlugin.log("warning: $code")
        plugin.result.success("warning : $code")
    }
}