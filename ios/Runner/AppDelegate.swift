import UIKit
import Flutter
import WidgetKit

fileprivate struct KGTInfo {
    static let kGtAppId = "43HGFmIKsnAmjrjDLr60X4"
    static let kGtAppKey = "lMfDbXITSXALHE5EtfZv6A"
    static let kGtAppSecret = "kyL4r0PNpG9xnSEUO1omn5"
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, GeTuiSdkDelegate {
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
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func applicationWillResignActive(_ application: UIApplication) {

    }
}


