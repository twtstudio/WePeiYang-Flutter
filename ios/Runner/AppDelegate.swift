import UIKit
import SwiftUI
import Flutter
import WidgetKit

fileprivate struct KGTInfo {
    static let kGtAppId = "43HGFmIKsnAmjrjDLr60X4"
    static let kGtAppKey = "lMfDbXITSXALHE5EtfZv6A"
    static let kGtAppSecret = "kyL4r0PNpG9xnSEUO1omn5"
}

@UIApplicationMain
@objc
class AppDelegate: FlutterAppDelegate, GeTuiSdkDelegate {
    var flutterChannels: [WChannel] = []

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let controller = window.rootViewController as! FlutterViewController
        configureChannels(controller: controller)

        // 友盟sdk
        UMCommonLogSwift.setUpUMCommonLogManager()
        // 是否打开日志
        UMCommonSwift.setLogEnabled(bFlag: false)
        UMCommonSwift.initWithAppkey(appKey: "605440876ee47d382b8b74c3", channel: "App Store")

        // [ GTSDK ]：使用APPID/APPKEY/APPSECRENT启动个推
        GeTuiSdk.start(withAppId: KGTInfo.kGtAppId, appKey: KGTInfo.kGtAppKey, appSecret: KGTInfo.kGtAppSecret, delegate: self)
        // [ GTSDK ]: 注册远程通知
        GeTuiSdk.registerRemoteNotification([.alert, .badge, .sound])

        GeneratedPluginRegistrant.register(with: self)

        // 设置用于检查暗黑模式的 Flutter 方法通道
        let themeChannel = FlutterMethodChannel(name: "com.twt.WePeiYang/theme",binaryMessenger: controller.binaryMessenger)
        themeChannel.setMethodCallHandler {
            (call, result) -> Void in
            if call.method == "isDarkMode" {
                result(ThemeHelper.isDarkMode())
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func applicationWillResignActive(_ application: UIApplication) {
        // 每次退出到桌面的时候刷新下
        Channel.reloadWidgetData()
    }
}

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



