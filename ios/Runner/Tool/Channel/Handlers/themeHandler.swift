//
//  themeHandler.swift
//  Runner
//
//  Created by zsy on 2024/4/23.
//

import Foundation

extension Channel {
    func themeHandler() -> FlutterMethodCallHandler {
        return { call, result in
            if call.method == "isDarkMode" {
                result(ThemeHelper.isDarkMode())
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }
}

// 设置用于检查暗黑模式的 Flutter 方法通道
@objc class ThemeHelper: NSObject {
  @objc static func isDarkMode() -> Bool {
    if #available(iOS 13.0, *) {
        return UITraitCollection.current.userInterfaceStyle == .dark
    } else {
      // Fallback for iOS versions < 13
      return true
    }
  }
}
