//
//  ChannelConfiguration.swift
//  Runner
//
//  Created by Zr埋 on 2022/9/6.
//

enum Channel: CaseIterable {
    case localSetting, push, umengStatistics
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
        }
    }
}

// handlers
extension Channel {
    func localSettingHandler() -> FlutterMethodCallHandler {
        return { call, result in
            var dict: [String: Any] = [:]
            if let callDict = call.arguments {
                dict = callDict as? [String: Any] ?? [:]
            }
            switch call.method {
            case "changeWindowBrightness":
                var brightness = dict["brightness"] as! Double
                if !(brightness >= 0 && brightness <= 1) {
                    brightness = 0.3
                }
                UIScreen.main.brightness = brightness
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    func pushSettingHandler() -> FlutterMethodCallHandler {
        return { call, result in
           
        }
    }
    
    func umengStatisticsHandler() -> FlutterMethodCallHandler {
        return { call, result in
            var dict: [String: Any] = [:]
            if let callDict = call.arguments {
                dict = callDict as? [String: Any] ?? [:]
            }
            switch call.method {
            case "onEvent":
                let event = dict["event"] as! String
                let maps = dict["map"] as! [String:Any]
                UMAnalyticsSwift.event(eventId: event, attributes: maps)
                print("onEvent: \(event); maps: \(maps.debugDescription)")
            case "onPageStart":
                let page = dict["page"] as! String
                UMAnalyticsSwift.beginLogPageView(pageName: page)
                print("onPageStart: \(page)")
            case "onPageEnd":
                let page = dict["page"] as! String
                UMAnalyticsSwift.endLogPageView(pageName: page)
                print("onPageEnd: \(page)")
            case "reportError":
                // TODO: 这里没有函数 就先不实现
                break
            case "onProfileSignIn":
                let userID = dict["userID"] as! String
                UMAnalyticsSwift.profileSignInWithPUID(puid: userID)
                print("onProfileSignIn: \(userID)")
            case "onProfileSignOff":
                UMAnalyticsSwift.profileSignOff()
                print("onProfileSignOff")
            default:
                result(FlutterMethodNotImplemented)
            }
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

