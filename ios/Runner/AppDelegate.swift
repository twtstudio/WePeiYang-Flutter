import UIKit
import Flutter

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
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}


extension AppDelegate {
    // [ GTSDK回调 ] 已注册客户端
    func geTuiSdkDidRegisterClient(_ clientId: String) {
        print("[ GTSDK回调 ] 已注册客户端，本机cid: \(clientId)")
        
        // 发送给flutter端
        if let chan = getChannel(type: .push) {
            chan.channel.invokeMethod("getCidFromIOS", arguments: ["cid": clientId])
        }
    }
    
    // [ GTSDK回调 ] 状态通知
    func geTuiSDkDidNotifySdkState(_ status: SdkStatus) {
        print("[ GTSDK回调 ] 状态通知: \(status.description)")
    }
    
    // [ GTSDK回调 ] SDK错误反馈
    func geTuiSdkDidOccurError(_ error: Error) {
        print("[ GTSDK回调 ] SDK错误反馈: \(error.localizedDescription)")
    }
    
    // [ GTSDK回调 ] 即将展示APNS通知
    func geTuiSdkNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("[ GTSDK回调 ] 即将展示APNS通知")
        print("APNS通知  \(center.description)")
        completionHandler([.badge, .sound, .list, .banner])
    }
    
    // [ GTSDK回调 ] 接收到APNS通知
    func geTuiSdkDidReceiveNotification(_ userInfo: [AnyHashable : Any], notificationCenter center: UNUserNotificationCenter?, response: UNNotificationResponse?, fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
        print("[ GTSDK回调 ] 接收到APNS通知")
        print("response \(response?.description)")
        completionHandler?(.noData)
    }
    
    // [ GTSDK回调 ] APNs的通知
    func geTuiSdkNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        print("[ GTSDK回调 ] APNs的通知 \(notification?.description)")
    }
    
    // [ GTSDK回调 ] 接收到透传通知
    func geTuiSdkDidReceiveSlience(_ userInfo: [AnyHashable : Any], fromGetui: Bool, offLine: Bool, appId: String?, taskId: String?, msgId: String?, fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
        print("[ GTSDK回调 ] 接收到透传通知: \(fromGetui ? "个推消息" : "APNs消息") appId:\(appId ?? "") offLine:\(offLine ? "离线" : "在线") taskId:\(taskId ?? "") msgId:\(msgId ?? "") userInfo:\(userInfo)")
    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        print("APNS 回调")
//    }
    
}

extension SdkStatus {
    var description: String {
        switch self {
            case .offline: return "离线"
            case .started: return "启动、在线"
            case .starting: return "正在启动"
            case .stoped: return "停止"
            @unknown default: return "unknown"
        }
    }
}


enum Channel: CaseIterable {
    case localSetting, push
}

struct WChannel {
    var name: String
    var channel: FlutterMethodChannel
}

extension Channel {
    func getSymbol() -> String {
        let domain = "com.twt.service"
        var method = ""
        switch self {
        case .localSetting:
            method = "local_setting"
        case .push:
            method = "push"
        }
        return domain + "/" + method
    }
    
    func methodHandler() -> FlutterMethodCallHandler? {
        switch self {
        case .localSetting:
            return localSettingHandler()
        case .push:
            return pushSettingHandler()
        }
    }
}

// handlers
extension Channel {
    func localSettingHandler() -> FlutterMethodCallHandler? {
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
    
    func pushSettingHandler() -> FlutterMethodCallHandler? {
        return { call, result in
           
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

