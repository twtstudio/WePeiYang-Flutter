package com.twt.service

import android.text.TextUtils
import android.util.Log
import com.amap.api.location.AMapLocation
import com.amap.api.location.AMapLocationQualityReport
import java.text.SimpleDateFormat
import java.util.*

object Utils {

    /**
     * 根据定位结果返回定位信息的字符串
     * @param location
     * @return
     */
    @Synchronized
    fun getLocationStr(location: AMapLocation?,onSuccess:(AMapLocation) -> Unit,onError:(AMapLocation)-> Unit ) {
        if (null != location) {
            val sb = StringBuffer()
            //errCode等于0代表定位成功，其他的为定位失败，具体的可以参照官网定位错误码说明
            if (location.errorCode == 0) {
                sb.append("""
    定位成功

    """.trimIndent())
                sb.append("""
    定位类型: ${location.locationType}

    """.trimIndent())
                sb.append("""
    经    度    : ${location.longitude}

    """.trimIndent())
                sb.append("""
    纬    度    : ${location.latitude}

    """.trimIndent())
                sb.append("""
    精    度    : ${location.accuracy}米

    """.trimIndent())
                sb.append("""
    提供者    : ${location.provider}

    """.trimIndent())
                sb.append("""
    速    度    : ${location.speed}米/秒

    """.trimIndent())
                sb.append("""
    角    度    : ${location.bearing}

    """.trimIndent())
                // 获取当前提供定位服务的卫星个数
                sb.append("""
    星    数    : ${location.satellites}

    """.trimIndent())
                sb.append("""
    国    家    : ${location.country}

    """.trimIndent())
                sb.append("""
    省            : ${location.province}

    """.trimIndent())
                sb.append("""
    市            : ${location.city}

    """.trimIndent())
                sb.append("""
    城市编码 : ${location.cityCode}

    """.trimIndent())
                sb.append("""
    区            : ${location.district}

    """.trimIndent())
                sb.append("""
    区域 码   : ${location.adCode}

    """.trimIndent())
                sb.append("""
    地    址    : ${location.address}

    """.trimIndent())
                sb.append("""
    兴趣点    : ${location.poiName}

    """.trimIndent())
                //定位完成的时间
                sb.append("""
    定位时间: ${formatUTC(location.time, "yyyy-MM-dd HH:mm:ss")}

    """.trimIndent())

                onSuccess(location)
            } else {
                //定位失败
                sb.append("""
    定位失败

    """.trimIndent())
                sb.append("""
    错误码:${location.errorCode}

    """.trimIndent())
                sb.append("""
    错误信息:${location.errorInfo}

    """.trimIndent())
                sb.append("""
    错误描述:${location.locationDetail}

    """.trimIndent())
                
                onError(location)
            }
            sb.append("***定位质量报告***").append("\n")
            sb.append("* WIFI开关：").append(if (location.locationQualityReport.isWifiAble) "开启" else "关闭").append("\n")
            sb.append("* GPS状态：").append(getGPSStatusString(location.locationQualityReport.gpsStatus)).append("\n")
            sb.append("* GPS星数：").append(location.locationQualityReport.gpsSatellites).append("\n")
            sb.append("* 网络类型：" + location.locationQualityReport.networkType).append("\n")
            sb.append("* 网络耗时：" + location.locationQualityReport.netUseTime).append("\n")
            sb.append("****************").append("\n")
            //定位之后的回调时间
            sb.append("""
    回调时间: ${formatUTC(System.currentTimeMillis(), "yyyy-MM-dd HH:mm:ss")}

    """.trimIndent())

            //解析定位结果
            val result = sb.toString()
            Log.d("locationresult", result)
        } else {
            Log.d("locationresult", "定位失败，loc is null")
        }
    }

    private var sdf: SimpleDateFormat? = null
    private fun formatUTC(l: Long, strPattern: String?): String {
        var strPattern = strPattern
        if (TextUtils.isEmpty(strPattern)) {
            strPattern = "yyyy-MM-dd HH:mm:ss"
        }
        if (sdf == null) {
            try {
                sdf = SimpleDateFormat(strPattern, Locale.CHINA)
            } catch (e: Throwable) {
            }
        } else {
            sdf!!.applyPattern(strPattern)
        }
        return if (sdf == null) "NULL" else sdf!!.format(l)
    }

    /**
     * 获取GPS状态的字符串
     * @param statusCode GPS状态码
     * @return
     */
    private fun getGPSStatusString(statusCode: Int): String {
        var str = ""
        when (statusCode) {
            AMapLocationQualityReport.GPS_STATUS_OK -> str = "GPS状态正常"
            AMapLocationQualityReport.GPS_STATUS_NOGPSPROVIDER -> str = "手机中没有GPS Provider，无法进行GPS定位"
            AMapLocationQualityReport.GPS_STATUS_OFF -> str = "GPS关闭，建议开启GPS，提高定位质量"
            AMapLocationQualityReport.GPS_STATUS_MODE_SAVING -> str = "选择的定位模式中不包含GPS定位，建议选择包含GPS定位的模式，提高定位质量"
            AMapLocationQualityReport.GPS_STATUS_NOGPSPERMISSION -> str = "没有GPS定位权限，建议开启gps定位权限"
        }
        return str
    }
}