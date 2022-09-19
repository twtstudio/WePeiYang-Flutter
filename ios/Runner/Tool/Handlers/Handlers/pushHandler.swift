//
//  pushHandler.swift
//  Runner
//
//  Created by TwT on 2022/9/19.
//

extension Channel {
    func pushSettingHandler() -> FlutterMethodCallHandler {
        return { call, result in
            switch call.method {
            case "getCid":
                result(GeTuiSdk.clientId())
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}
