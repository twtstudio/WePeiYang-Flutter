package com.twt.service.widget

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Color
import com.google.zxing.BarcodeFormat
import com.google.zxing.EncodeHintType
import com.google.zxing.qrcode.QRCodeWriter
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel
import okhttp3.HttpUrl.Companion.toHttpUrl
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import org.xmlpull.v1.XmlPullParser
import org.xmlpull.v1.XmlPullParserFactory
import java.security.GeneralSecurityException
import java.util.Locale
import java.util.concurrent.TimeUnit
import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec

object EntryQrService {
    private const val PREFS_NAME = "FlutterSharedPreferences"
    private const val USER_NUMBER_KEY = "flutter.userNumber"
    private const val BASE_URL = "https://f.tju.edu.cn/tp_up/up/mobile/ifs/"
    private const val DES_KEY = "neusofteducationplatform"
    private const val DES_IV = "01234567"

    private val client = OkHttpClient.Builder()
        .connectTimeout(8, TimeUnit.SECONDS)
        .readTimeout(8, TimeUnit.SECONDS)
        .build()

    fun readSid(context: Context): String {
        return context
            .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(USER_NUMBER_KEY, "")
            .orEmpty()
    }

    fun fetchQrContent(sid: String): String {
        if (sid.isBlank()) error("请先登录后再刷新")

        val encryptedPath = encryptPath("method=getAccountQRcodeInfo&ID_NUMBER=$sid")
        val url = BASE_URL.toHttpUrl().newBuilder()
            .addPathSegment(encryptedPath)
            .build()

        val request = Request.Builder()
            .url(url)
            .header("Accept", "application/json;charset=UTF-8")
            .header("Host", "f.tju.edu.cn")
            .header("Connection", "Keep-Alive")
            .header("User-Agent", "okhttp/3.12.0")
            .build()

        client.newCall(request).execute().use { response ->
            if (!response.isSuccessful) error("刷新失败 ${response.code}")
            val body = response.body?.string().orEmpty()
            return extractQrContent(body).ifBlank { error("未获取到二维码") }
        }
    }

    fun createQrBitmap(content: String, size: Int = 512): Bitmap {
        val hints = mapOf(
            EncodeHintType.CHARACTER_SET to "UTF-8",
            EncodeHintType.ERROR_CORRECTION to ErrorCorrectionLevel.M,
            EncodeHintType.MARGIN to 1,
        )
        val matrix = QRCodeWriter().encode(content, BarcodeFormat.QR_CODE, size, size, hints)
        val pixels = IntArray(size * size)
        for (y in 0 until size) {
            val offset = y * size
            for (x in 0 until size) {
                pixels[offset + x] = if (matrix[x, y]) Color.BLACK else Color.WHITE
            }
        }
        return Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888).apply {
            setPixels(pixels, 0, size, 0, 0, size, size)
        }
    }

    private fun extractQrContent(body: String): String {
        val trimmed = body.trim()
        if (trimmed.startsWith("{")) {
            return parseJsonMessage(trimmed)
        }
        return parseXmlMessage(trimmed)
    }

    private fun parseJsonMessage(json: String): String {
        return try {
            val root = JSONObject(json)
            root.optString("message", "").ifEmpty {
                root.keys().asSequence()
                    .map { root.optJSONObject(it)?.optString("message", "") }
                    .firstOrNull { it?.isNotEmpty() == true } ?: ""
            }
        } catch (_: Exception) {
            ""
        }
    }

    private fun parseXmlMessage(xml: String): String {
        val parser = XmlPullParserFactory.newInstance().newPullParser()
        parser.setInput(xml.reader())
        var eventType = parser.eventType
        while (eventType != XmlPullParser.END_DOCUMENT) {
            if (eventType == XmlPullParser.START_TAG && parser.name == "message") {
                return parser.nextText()
            }
            eventType = parser.next()
        }
        return ""
    }

    private fun encryptPath(source: String): String {
        return tripleDesEncrypt(source, DES_KEY, DES_IV)
            .joinToString(separator = "") { "%02X".format(Locale.US, it.toInt() and 0xFF) }
    }

    private fun tripleDesEncrypt(source: String, key: String, iv: String): ByteArray {
        try {
            val cipher = Cipher.getInstance("DESede/CBC/PKCS5Padding")
            cipher.init(
                Cipher.ENCRYPT_MODE,
                SecretKeySpec(key.toByteArray(Charsets.UTF_8), "DESede"),
                IvParameterSpec(iv.toByteArray(Charsets.UTF_8)),
            )
            return cipher.doFinal(source.toByteArray(Charsets.UTF_8))
        } catch (e: GeneralSecurityException) {
            throw IllegalStateException("二维码请求加密失败", e)
        }
    }
}
