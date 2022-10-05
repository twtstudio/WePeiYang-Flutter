//
//  UMAnalyticsSwift.swift
//  swiftDemo
//
//  Created by wangkai on 2019/8/30.
//  Copyright © 2019 wangkai. All rights reserved.
//

import Foundation
import CoreLocation

class UMAnalyticsSwift: NSObject {
    //页面统计    
    /** 手动页面时长统计, 记录某个页面展示的时长.
     @param pageName 统计的页面名称.
     @param seconds 单位为秒，int型.
     @return void.
     */
    static func logPageView(pageName:String,seconds:Int){
        MobClick.logPageView(pageName, seconds:Int32(seconds));
    }
    
    /** 自动页面时长统计, 开始记录某个页面展示时长.
     使用方法：必须配对调用beginLogPageView:和endLogPageView:两个函数来完成自动统计，若只调用某一个函数不会生成有效数据。
     在该页面展示时调用beginLogPageView:，当退出该页面时调用endLogPageView:
     @param pageName 统计的页面名称.
     @return void.
     */
    static func beginLogPageView(pageName:String){
        MobClick.beginLogPageView(pageName);
    }
    
    /** 自动页面时长统计, 结束记录某个页面展示时长.
     使用方法：必须配对调用beginLogPageView:和endLogPageView:两个函数来完成自动统计，若只调用某一个函数不会生成有效数据。
     在该页面展示时调用beginLogPageView:，当退出该页面时调用endLogPageView:
     @param pageName 统计的页面名称.
     @return void.
     */
    static func endLogPageView(pageName:String){
        MobClick.endLogPageView(pageName);
    }
    
    //事件统计    
    /** 自定义事件,数量统计.
     使用前，请先到友盟App管理后台的设置->编辑自定义事件 中添加相应的事件ID，然后在工程中传入相应的事件ID
     
     @param  eventId 网站上注册的事件Id.
     @param  label 分类标签。不同的标签会分别进行统计，方便同一事件的不同标签的对比,为nil或空字符串时后台会生成和eventId同名的标签.
     @param  accumulation 累加值。为减少网络交互，可以自行对某一事件ID的某一分类标签进行累加，再传入次数作为参数。
     @return void.
     */
    static func event(eventId:String){
        MobClick.event(eventId);
    }
    /** 自定义事件,数量统计.
     使用前，请先到友盟App管理后台的设置->编辑自定义事件 中添加相应的事件ID，然后在工程中传入相应的事件ID
     */
    // label为nil或@""时，等同于 event:eventId label:eventId;
    static func event(eventId:String,label:String){
        MobClick.event(eventId, label: label);
    }
    
    /** 自定义事件,数量统计.
     使用前，请先到友盟App管理后台的设置->编辑自定义事件 中添加相应的事件ID，然后在工程中传入相应的事件ID
     */
    static func event(eventId:String,attributes:Dictionary<String, Any>){
        MobClick.event(eventId, attributes:attributes);
    }
    
    static func event(eventId:String,attributes:Dictionary<String, Any>,counter:Int){
        MobClick.event(eventId, attributes: attributes, counter: Int32(counter));
    }
    
    /** 自定义事件,时长统计.
     使用前，请先到友盟App管理后台的设置->编辑自定义事件 中添加相应的事件ID，然后在工程中传入相应的事件ID.
     beginEvent,endEvent要配对使用,也可以自己计时后通过durations参数传递进来
     
     @param  eventId 网站上注册的事件Id.
     @param  label 分类标签。不同的标签会分别进行统计，方便同一事件的不同标签的对比,为nil或空字符串时后台会生成和eventId同名的标签.
     @param  primarykey 这个参数用于和event_id一起标示一个唯一事件，并不会被统计；对于同一个事件在beginEvent和endEvent 中要传递相同的eventId 和 primarykey
     @param millisecond 自己计时需要的话需要传毫秒进来
     @return void.
     
     @warning 每个event的attributes不能超过10个
     eventId、attributes中key和value都不能使用空格和特殊字符，必须是NSString,且长度不能超过255个字符（否则将截取前255个字符）
     id， ts， du是保留字段，不能作为eventId及key的名称
     */
    static func beginEvent(eventId:String){
        MobClick.beginEvent(eventId);
    }
    
    /** 自定义事件,时长统计.
     使用前，请先到友盟App管理后台的设置->编辑自定义事件 中添加相应的事件ID，然后在工程中传入相应的事件ID.
     */
    static func endEvent(eventId:String){
        MobClick.endEvent(eventId);
    }
    
    /** 自定义事件,时长统计.
     使用前，请先到友盟App管理后台的设置->编辑自定义事件 中添加相应的事件ID，然后在工程中传入相应的事件ID.
     */
    static func beginEvent(eventId:String,label:String){
        MobClick.beginEvent(eventId, label: label);
    }
    
    /** 自定义事件,时长统计.
     使用前，请先到友盟App管理后台的设置->编辑自定义事件 中添加相应的事件ID，然后在工程中传入相应的事件ID.
     */
    static func endEvent(eventId:String,label:String){
        MobClick.endEvent(eventId, label: label);
    }
    
    /** 自定义事件,时长统计.
     使用前，请先到友盟App管理后台的设置->编辑自定义事件 中添加相应的事件ID，然后在工程中传入相应的事件ID.
     */
    static func beginEvent(eventId:String,primarykey:String,attributes:Dictionary<String, Any>){
        MobClick.beginEvent(eventId, primarykey: primarykey, attributes: attributes);
    }
    
    /** 自定义事件,时长统计.
     使用前，请先到友盟App管理后台的设置->编辑自定义事件 中添加相应的事件ID，然后在工程中传入相应的事件ID.
     */
    static func endEvent(eventId:String,primarykey:String){
        MobClick.endEvent(eventId, primarykey: primarykey);
    }
    
    /** 自定义事件,时长统计.
     使用前，请先到友盟App管理后台的设置->编辑自定义事件 中添加相应的事件ID，然后在工程中传入相应的事件ID.
     */
    static func event(eventId:String,durations:Int){
        MobClick.event(eventId, durations: Int32(durations))
    }
    
    /** 自定义事件,时长统计.
     使用前，请先到友盟App管理后台的设置->编辑自定义事件 中添加相应的事件ID，然后在工程中传入相应的事件ID.
     */
    static func event(eventId:String,label:String,millisecond:Int){
        MobClick.event(eventId, label: label, durations: Int32(millisecond));
    }
    
    /** 自定义事件,时长统计.
     使用前，请先到友盟App管理后台的设置->编辑自定义事件 中添加相应的事件ID，然后在工程中传入相应的事件ID.
     */
    static func event(eventId:String,attributes:Dictionary<String, Any>,millisecond:Int){
        MobClick.event(eventId, attributes: attributes, durations: Int32(millisecond));
    }
    
    
    /** active user sign-in.
     使用sign-In函数后，如果结束该PUID的统计，需要调用sign-Off函数
     @param puid : user's ID
     @param provider : 不能以下划线"_"开头，使用大写字母和数字标识; 如果是上市公司，建议使用股票代码。
     @return void.
     */
    static func profileSignInWithPUID(puid:String){
        MobClick.profileSignIn(withPUID: puid);
    }
    static func profileSignInWithPUID(puid:String,provider:String){
        MobClick.profileSignIn(withPUID:puid, provider: provider);
    }
    
    /** active user sign-off.
     停止sign-in PUID的统计
     @return void.
     */
    static func profileSignOff(){
        MobClick.profileSignOff();
    }
    
    ///---------------------------------------------------------------------------------------
    /// @name 地理位置设置
    /// 需要链接 CoreLocation.framework 并且 #import <CoreLocation/CoreLocation.h>
    ///---------------------------------------------------------------------------------------
    
    /** 设置经纬度信息
     @param latitude 纬度.
     @param longitude 经度.
     @return void
     */
    static func setLatitude(latitude:Double,longitude:Double){
        MobClick.setLatitude(latitude, longitude: longitude);
    }
    
    
    ///---------------------------------------------------------------------------------------
    /// @name Utility函数
    ///---------------------------------------------------------------------------------------
    
    /** 判断设备是否越狱，依据是否存在apt和Cydia.app
     */
    static func isJailbroken() -> Bool{
        return MobClick.isJailbroken();
    }
    
    /** 判断App是否被破解
     */
    static func isPirated() -> Bool{
        return MobClick.isPirated();
    }
    
    /** 设置 app secret
     @param secret string
     @return void.
     */
    static func setSecret(secret:String){
        MobClick.setSecret(secret);
    }
    

    
    /**
     * 设置预置事件属性 键值对 会覆盖同名的key
     */
    static func registerPreProperties(property:Dictionary<String, Any>)
    {
        MobClick.registerPreProperties(property);
    }
    
    /**
     *
     * 删除指定预置事件属性
     @param key
     */
    static func unregisterPreProperty(propertyName:String)
    {
        MobClick.unregisterPreProperty(propertyName);
    }
    
    /**
     * 获取预置事件所有属性；如果不存在，则返回空。
     */
    static func getPreProperties() -> Dictionary<String, Any>
    {
        return  MobClick.getPreProperties() as! Dictionary<String, Any> ;
    }
    
    /**
     *清空所有预置事件属性。
     */
    static func clearPreProperties()
    {
        MobClick.clearPreProperties();
    }
    
    
    /**
     * 设置关注事件是否首次触发,只关注eventList前五个合法eventID.只要已经保存五个,此接口无效
     */
    static func setFirstLaunchEvent(eventList:Array<String>)
    {
        MobClick.setFirstLaunchEvent(eventList);
    }
    
    /** 设置是否自动采集页面, 默认NO(不自动采集).
     @param value 设置为YES, umeng SDK 会将自动采集页面信息
     */
    static func setAutoPageEnabled(value:Bool)
    {
        MobClick.setAutoPageEnabled(value);
    }

}
