//
//  widgetHandler.swift
//  Runner
//
//  Created by TwT on 2022/9/19.
//

import WidgetKit
import Flutter

extension Channel {
    private func reloadWidgetData() {
        // 将User Defaults中的数据存到文件里
        StorageKey.saveToGroupStorage()
        // 刷新小组件timeline
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func widgetHandler() -> FlutterMethodCallHandler {
        return { call, result in
//            var dict: [String: Any] = [:]
//            if let callDict = call.arguments {
//                dict = callDict as? [String: Any] ?? [:]
//            }
            switch call.method {
            case "refreshScheduleWidget":
                reloadWidgetData()
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}
