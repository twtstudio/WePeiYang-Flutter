package com.twt.service.share.system

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.content.FileProvider
import java.io.File

object SystemShare {
    fun startMarket(context: Context) {
        // https://blog.csdn.net/weixin_36318548/article/details/117544612

        val intent = Intent(Intent.ACTION_VIEW)

        // 如果不指定具体的报名，则系统弹出弹窗询问用哪个打开
        intent.`package` = when (Build.BRAND.lowercase()) {
            "huawei", "honor" -> "com.huawei.appmarket"
            "xiaomi" -> "com.xiaomi.market"
            "oppo" -> "com.oppo.market"
            else -> null
        }

        intent.data = Uri.parse("market://details?id=${context.packageName}")
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (intent.resolveActivity(context.packageManager) != null) {
            context.startActivity(intent)
        } else {
            context.startActivity(intent.apply { `package` = null })
        }
    }

    fun shareText(context: Context) {
        val intent = Intent().apply {
            action = Intent.ACTION_SEND
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, "文本内容")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            `package` = "com.tencent.mm"
        }
        context.startActivity(intent)
    }

    fun shareImages(context: Context, images: List<File>) {
        // 跳转到相册
        // https://blog.csdn.net/weixin_39524882/article/details/117613777

        // 将图片分享到app
        // https://blog.csdn.net/qq_34983989/article/details/78438254

        // 系统分享
        // https://www.cnblogs.com/yongdaimi/p/10287477.html
        // https://juejin.cn/post/6844903439193899022
        // https://juejin.cn/post/6949123159392157732?share_token=a6e39a23-15a7-4e40-aab7-dbbbac244e96
        // https://juejin.cn/post/6980664932974985247

        // 存储图片到相册
        // https://juejin.cn/post/7042218651482587172

        // 图片裁剪
        // https://juejin.cn/post/6922022765537001485

        val imageUris = images.mapNotNull {
            FileProvider.getUriForFile(context, "${context.packageName}.ImageProvider", it)
        }

        val shareIntent = Intent().apply {
            action = Intent.ACTION_SEND_MULTIPLE
            type = "image/*"
            putExtra(Intent.EXTRA_STREAM, imageUris.toTypedArray())
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        // https://blog.csdn.net/qq_32534441/article/details/105861078
        context.startActivity(Intent.createChooser(shareIntent, "dlgTitle"))
    }

    fun shareImage(context: Context, image: File) {
        val uri =
            FileProvider.getUriForFile(context, "${context.packageName}.ImageProvider", image)

        val intent = Intent().apply {
            action = Intent.ACTION_SEND
            type = "image/*"
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(Intent.createChooser(intent, "title"))
    }
}