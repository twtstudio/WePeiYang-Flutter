import UIKit
import Flutter

fileprivate struct KGTInfo {
    static let kGtAppId = "43HGFmIKsnAmjrjDLr60X4"
    static let kGtAppKey = "lMfDbXITSXALHE5EtfZv6A"
    static let kGtAppSecret = "kyL4r0PNpG9xnSEUO1omn5"
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, GeTuiSdkDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      let controller = window.rootViewController as! FlutterViewController
      configureChannels(controller: controller)
      
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
//        l("[ GTSDK回调 ] 已注册客户端，本机cid:", context: clientId)
//        Storage.defaults.setValue(clientId, forKey: SharedMessage.gtCidKey)
    }
    
    // [ GTSDK回调 ] 状态通知
    func geTuiSDkDidNotifySdkState(_ status: SdkStatus) {
//        log.info("[ GTSDK回调 ] 状态通知:", context: status.description)
    }
    
    // [ GTSDK回调 ] SDK错误反馈
    func geTuiSdkDidOccurError(_ error: Error) {
//        log.error("[ GTSDK回调 ] SDK错误反馈:", context: error)
    }
    
    // [ GTSDK回调 ] 即将展示APNS通知
    func geTuiSdkNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        log.info("[ GTSDK回调 ] 即将展示APNS通知", context: center)
//        log.info("APNS通知", context: center)
        if #available(iOS 14.0, *) {
            completionHandler([.badge, .sound, .list, .banner])
        } else {
            completionHandler([.badge, .sound])
        }
    }
    
    // [ GTSDK回调 ] 接收到APNS通知
    func geTuiSdkDidReceiveNotification(_ userInfo: [AnyHashable : Any], notificationCenter center: UNUserNotificationCenter?, response: UNNotificationResponse?, fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
//        log.info("[ GTSDK回调 ] 接收到APNS通知", context: center)
//        log.info("response", context: response)
        completionHandler?(.noData)
    }
    
    // [ GTSDK回调 ] APNs的通知
    func geTuiSdkNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
//        log.info("[ GTSDK回调 ] APNs的通知", context: notification?.description ?? "")
    }
    
    // [ GTSDK回调 ] 接收到透传通知
    func geTuiSdkDidReceiveSlience(_ userInfo: [AnyHashable : Any], fromGetui: Bool, offLine: Bool, appId: String?, taskId: String?, msgId: String?, fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
//        log.info("[ GTSDK回调 ] 接收到透传通知: \(fromGetui ? "个推消息" : "APNs消息") appId:\(appId ?? "") offLine:\(offLine ? "离线" : "在线") taskId:\(taskId ?? "") msgId:\(msgId ?? "") userInfo:\(userInfo)")
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        log.info("APNS 回调")
    }
    
}

extension AppDelegate {
    // channel
    func configureChannels(controller: FlutterViewController) {
        let localSettingChannel = FlutterMethodChannel(name: "com.twt.service/local_setting", binaryMessenger: controller.binaryMessenger)
        
        localSettingChannel.setMethodCallHandler { call, result in
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
