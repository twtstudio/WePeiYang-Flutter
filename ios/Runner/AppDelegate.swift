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
        
        if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            // 延迟1.5秒执行，等app初始化好
            let delaySeconds = 1.5
            DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
                self.handleShortcutItem(shortcutItem, controller: controller)
                }
            }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func applicationWillResignActive(_ application: UIApplication) {
        // 每次退出到桌面的时候刷新下
        Channel.reloadWidgetData()
    }
    
    override func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let controller = window.rootViewController as! FlutterViewController
        handleShortcutItem(shortcutItem, controller: controller)
        completionHandler(true)
    }
    
    private func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem, controller: FlutterViewController) {
        let channelName = "com.twt.service/shortcutItem"
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
        // 向Flutter发送快捷操作标识
        channel.invokeMethod("onShortcutAction", arguments: shortcutItem.type)
    }
}
