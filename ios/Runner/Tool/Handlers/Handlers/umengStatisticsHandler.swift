//
//  umengStatisticsHandler.swift
//  Runner
//
//  Created by TwT on 2022/9/19.
//

extension Channel {
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
