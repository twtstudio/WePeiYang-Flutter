package com.twt.service

import android.content.Context
import android.text.TextUtils
import android.util.Log
import com.amap.api.location.AMapLocation
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import com.amap.api.location.AMapLocationListener
import com.amap.api.location.AMapLocationQualityReport
import com.google.gson.Gson
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*

object AMapFactory {

    fun init(placeChannel: MethodChannel, context: Context): AMapLocationClient {
        val locationClient = AMapLocationClient(context)
        val locationOption = getDefaultOption()
        locationClient.setLocationOption(locationOption)

        val locationListener = AMapLocationListener { location ->
            getLocationStr(location, onSuccess = {
                // 定位成功
                val locationData = with(it) {
                    LocationData(
                        longitude,
                        latitude,
                        country,
                        province,
                        city,
                        cityCode,
                        district,
                        address,
                        time
                    )
                }
                val json = Gson().toJson(locationData)
                Log.d("locationresult", json)
                // 发送到flutter
                placeChannel.invokeMethod("showResult", json)
                locationClient.stopLocation()
            }, onError = {
                placeChannel.invokeMethod("showError", "定位失败,${it.locationDetail}")
                locationClient.stopLocation()
            })
        }

        locationClient.setLocationListener(locationListener)

        return locationClient
    }

    private fun getDefaultOption(): AMapLocationClientOption {
        val mOption = AMapLocationClientOption()
        mOption.locationMode =
            AMapLocationClientOption.AMapLocationMode.Hight_Accuracy //可选，设置定位模式，可选的模式有高精度、仅设备、仅网络。默认为高精度模式
        mOption.isGpsFirst = false //可选，设置是否gps优先，只在高精度模式下有效。默认关闭
        mOption.httpTimeOut = 30000 //可选，设置网络请求超时时间。默认为30秒。在仅设备模式下无效
        mOption.interval = 10000 //可选，设置定位间隔。默认为2秒
        mOption.isNeedAddress = true //可选，设置是否返回逆地理地址信息。默认是true
        mOption.isOnceLocation = false //可选，设置是否单次定位。默认是false
        mOption.isOnceLocationLatest =
            false //可选，设置是否等待wifi刷新，默认为false.如果设置为true,会自动变为单次定位，持续定位时不要使用
        AMapLocationClientOption.setLocationProtocol(AMapLocationClientOption.AMapLocationProtocol.HTTP) //可选， 设置网络请求的协议。可选HTTP或者HTTPS。默认为HTTP
        mOption.isSensorEnable = false //可选，设置是否使用传感器。默认是false
        mOption.isWifiScan =
            true //可选，设置是否开启wifi扫描。默认为true，如果设置为false会同时停止主动刷新，停止以后完全依赖于系统刷新，定位位置可能存在误差
        mOption.isLocationCacheEnable = true //可选，设置是否使用缓存定位，默认为true
        mOption.geoLanguage =
            AMapLocationClientOption.GeoLanguage.DEFAULT //可选，设置逆地理信息的语言，默认值为默认语言（根据所在地区选择语言）
        return mOption
    }

    /**
     * 根据定位结果返回定位信息的字符串
     * @param location
     * @return
     */
    @Synchronized
    fun getLocationStr(
        location: AMapLocation?,
        onSuccess: (AMapLocation) -> Unit,
        onError: (AMapLocation) -> Unit
    ) {
        if (null != location) {
            val sb = StringBuffer()
            //errCode等于0代表定位成功，其他的为定位失败，具体的可以参照官网定位错误码说明
            if (location.errorCode == 0) {
                sb.append(
                    """
    定位成功

    """.trimIndent()
                )
                sb.append(
                    """
    定位类型: ${location.locationType}

    """.trimIndent()
                )
                sb.append(
                    """
    经    度    : ${location.longitude}

    """.trimIndent()
                )
                sb.append(
                    """
    纬    度    : ${location.latitude}

    """.trimIndent()
                )
                sb.append(
                    """
    精    度    : ${location.accuracy}米

    """.trimIndent()
                )
                sb.append(
                    """
    提供者    : ${location.provider}

    """.trimIndent()
                )
                sb.append(
                    """
    速    度    : ${location.speed}米/秒

    """.trimIndent()
                )
                sb.append(
                    """
    角    度    : ${location.bearing}

    """.trimIndent()
                )
                // 获取当前提供定位服务的卫星个数
                sb.append(
                    """
    星    数    : ${location.satellites}

    """.trimIndent()
                )
                sb.append(
                    """
    国    家    : ${location.country}

    """.trimIndent()
                )
                sb.append(
                    """
    省            : ${location.province}

    """.trimIndent()
                )
                sb.append(
                    """
    市            : ${location.city}

    """.trimIndent()
                )
                sb.append(
                    """
    城市编码 : ${location.cityCode}

    """.trimIndent()
                )
                sb.append(
                    """
    区            : ${location.district}

    """.trimIndent()
                )
                sb.append(
                    """
    区域 码   : ${location.adCode}

    """.trimIndent()
                )
                sb.append(
                    """
    地    址    : ${location.address}

    """.trimIndent()
                )
                sb.append(
                    """
    兴趣点    : ${location.poiName}

    """.trimIndent()
                )
                //定位完成的时间
                sb.append(
                    """
    定位时间: ${formatUTC(location.time, "yyyy-MM-dd HH:mm:ss")}

    """.trimIndent()
                )

                onSuccess(location)
            } else {
                //定位失败
                sb.append(
                    """
    定位失败

    """.trimIndent()
                )
                sb.append(
                    """
    错误码:${location.errorCode}

    """.trimIndent()
                )
                sb.append(
                    """
    错误信息:${location.errorInfo}

    """.trimIndent()
                )
                sb.append(
                    """
    错误描述:${location.locationDetail}

    """.trimIndent()
                )

                onError(location)
            }
            sb.append("***定位质量报告***").append("\n")
            sb.append("* WIFI开关：")
                .append(if (location.locationQualityReport.isWifiAble) "开启" else "关闭").append("\n")
            sb.append("* GPS状态：")
                .append(getGPSStatusString(location.locationQualityReport.gpsStatus)).append("\n")
            sb.append("* GPS星数：").append(location.locationQualityReport.gpsSatellites).append("\n")
            sb.append("* 网络类型：" + location.locationQualityReport.networkType).append("\n")
            sb.append("* 网络耗时：" + location.locationQualityReport.netUseTime).append("\n")
            sb.append("****************").append("\n")
            //定位之后的回调时间
            sb.append(
                """
    回调时间: ${formatUTC(System.currentTimeMillis(), "yyyy-MM-dd HH:mm:ss")}

    """.trimIndent()
            )

            //解析定位结果
            val result = sb.toString()
            Log.d("locationresult", result)
        } else {
            Log.d("locationresult", "定位失败，loc is null")
        }
    }

    private var sdf: SimpleDateFormat? = null
    private fun formatUTC(l: Long, strPattern: String?): String {
        var str = strPattern
        if (TextUtils.isEmpty(str)) {
            str = "yyyy-MM-dd HH:mm:ss"
        }
        if (sdf == null) {
            try {
                sdf = SimpleDateFormat(str, Locale.CHINA)
            } catch (e: Throwable) {
            }
        } else {
            sdf!!.applyPattern(str)
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
            AMapLocationQualityReport.GPS_STATUS_NOGPSPROVIDER -> str =
                "手机中没有GPS Provider，无法进行GPS定位"
            AMapLocationQualityReport.GPS_STATUS_OFF -> str = "GPS关闭，建议开启GPS，提高定位质量"
            AMapLocationQualityReport.GPS_STATUS_MODE_SAVING -> str =
                "选择的定位模式中不包含GPS定位，建议选择包含GPS定位的模式，提高定位质量"
            AMapLocationQualityReport.GPS_STATUS_NOGPSPERMISSION -> str = "没有GPS定位权限，建议开启gps定位权限"
        }
        return str
    }
}

data class LocationData(
    val longitude: Double,
    val latitude: Double,
    val nation: String,
    val province: String,
    val city: String,
    val cityCode: String,
    val district: String,
    val address: String,
    val time: Long,
)