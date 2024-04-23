//
//  ChannelConfiguration.swift
//  Runner
//
//  Created by Zr埋 on 2022/9/6.
//
import Foundation
import Flutter

enum Channel: CaseIterable {
         // 设置
    case localSetting,
         // 推送
         push,
         // 友盟分析
         umengStatistics,
         // 小组件
         widget,
        // 深色模式主题
         theme
}

struct WChannel {
    var name: String
    var channel: FlutterMethodChannel
}

extension Channel {
    var symbolDict: [Channel: String] {
        [
            .localSetting: "local_setting",
            .push: "push",
            .umengStatistics: "umeng_statistics",
            .widget: "widget",
            .theme: "theme",
        ]
    }
    
    func getSymbol() -> String {
        "com.twt.service/" + symbolDict[self]!
    }
    
    func methodHandler() -> FlutterMethodCallHandler? {
        switch self {
        case .localSetting:
            return localSettingHandler()
        case .push:
            return pushSettingHandler()
        case .umengStatistics:
            return umengStatisticsHandler()
        case .widget:
            return widgetHandler()
        case .theme:
            return themeHandler()
        }
    }
}

extension AppDelegate {
    
    // channel
    func configureChannels(controller: FlutterViewController) {
        for chan in Channel.allCases {
            let channel = FlutterMethodChannel(name: chan.getSymbol(), binaryMessenger: controller.binaryMessenger)
            channel.setMethodCallHandler(chan.methodHandler())
            flutterChannels.append(WChannel(name: chan.getSymbol(), channel: channel))
        }
    }
    
    // get channel
    func getChannel(type: Channel) -> WChannel? {
        for chan in flutterChannels {
            if chan.name == type.getSymbol() {
                return chan
            }
        }
        return nil
    }
    
}

