//
//  localSettingHandler.swift
//  Runner
//
//  Created by TwT on 2022/9/19.
//
import Flutter

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
            case "bundleVersion":
                let localVersion:String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
                result(localVersion)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}
