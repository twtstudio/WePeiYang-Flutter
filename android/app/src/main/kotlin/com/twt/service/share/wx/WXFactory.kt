package com.twt.service.share.wx
//
//import android.graphics.Bitmap
//import android.graphics.BitmapFactory
//import android.widget.Toast
//import com.tencent.mm.opensdk.modelmsg.SendMessageToWX
//import com.tencent.mm.opensdk.modelmsg.WXImageObject
//import com.tencent.mm.opensdk.modelmsg.WXMediaMessage
//import com.twt.service.R
//import com.twt.service.WBYApplication
//import java.io.ByteArrayOutputStream
//import java.io.File
//import java.lang.Exception
//
//object WXFactory {
//    private const val mTargetScene = SendMessageToWX.Req.WXSceneSession
//
//    fun shareImg(path: String?) {
//        WBYApplication.activity?.get()?.let {
//
//            var imgObj = WXImageObject()
//            if (path.isNullOrEmpty() || !File(path).exists()) {
//                val bmp = BitmapFactory.decodeResource(it.resources, R.mipmap.ic_launcher)
//                imgObj = WXImageObject(bmp)
//            } else {
//                imgObj.setImagePath(path)
//            }
//
//            imgObj.setImagePath(path)
//
//            val msg = WXMediaMessage()
//            msg.mediaObject = imgObj
//
//            val bmp = BitmapFactory.decodeFile(path)
//            val thumbBmp = Bitmap.createScaledBitmap(
//                bmp,
//                150,
//                150,
//                true
//            )
//            bmp.recycle()
//            msg.thumbData = bmpToByteArray(thumbBmp, true)
//
//            val req = SendMessageToWX.Req()
//            req.transaction = buildTransaction("img")
//            req.message = msg
//            req.scene = mTargetScene
//            it.WXapi.sendReq(req)
//        }
//    }
//
//    private fun buildTransaction(type: String?): String =
//        if (type == null) System.currentTimeMillis()
//            .toString() else type + System.currentTimeMillis()
//
//
//    private fun bmpToByteArray(bmp: Bitmap, needRecycle: Boolean): ByteArray? {
//        val output = ByteArrayOutputStream()
//        bmp.compress(Bitmap.CompressFormat.PNG, 100, output)
//        if (needRecycle) {
//            bmp.recycle()
//        }
//        val result = output.toByteArray()
//        try {
//            output.close()
//        } catch (e: Exception) {
//            e.printStackTrace()
//        }
//        return result
//    }
//}