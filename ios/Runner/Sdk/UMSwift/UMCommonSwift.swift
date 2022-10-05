//
//  UMCommonSwift.swift
//  swiftDemo
//
//  Created by wangkai on 2019/8/29.
//  Copyright © 2019 wangkai. All rights reserved.
//

import Foundation

class UMCommonSwift: NSObject {
    
    /** 初始化友盟所有组件产品
     @param appKey 开发者在友盟官网申请的appkey.
     @param channel 渠道标识，可设置nil表示"App Store".
     */
    static func initWithAppkey(appKey:String,channel:String){
        UMConfigure.initWithAppkey(appKey, channel: channel);
    }
    
    /** 设置是否在console输出sdk的log信息.
     @param bFlag 默认NO(不输出log); 设置为YES, 输出可供调试参考的log信息. 发布产品时必须设置为NO.
     */
    static func setLogEnabled(bFlag:Bool){
        UMConfigure.setLogEnabled(bFlag);
    }
    
    /** 设置是否对日志信息进行加密, 默认NO(不加密).
     @param value 设置为YES, umeng SDK 会将日志信息做加密处理
     */
    static func setEncryptEnabled(value:Bool){
        UMConfigure.setEncryptEnabled(value);
    }
    
    static func umidString() -> String{
        return UMConfigure.umidString();
    }
    
    /**
     集成测试需要device_id
     */
    static func deviceIDForIntegration() -> String{
        return UMConfigure.deviceIDForIntegration();
    }
}
