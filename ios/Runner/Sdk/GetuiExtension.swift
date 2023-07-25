//
//  GetuiExtension.swift
//  Runner
//
//  Created by Zr埋 on 2022/9/6.
//

// MARK: - PushMessage
struct PushMessage: Codable {
    let data: PushData
    let type: Int
}

// MARK: - PushData
struct PushData: Codable {
    let title, content, url: String
}

extension AppDelegate {
    // [ GTSDK回调 ] 已注册客户端
    func geTuiSdkDidRegisterClient(_ clientId: String) {
        print("[ GTSDK回调 ] 已注册客户端，本机cid: \(clientId)")
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
//        let current = UNUserNotificationCenter.current()
//        let identifier = "wpy_push_from_getui"
//
//        current.removePendingNotificationRequests(withIdentifiers: [identifier])
//
//        let content = UNMutableNotificationContent()
//        content.title = ""
//        content.body = ""
//        content.sound = .defaultCriticalSound(withAudioVolume: 1.0)
//
//        let dateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//        current.add(request) { error in
//            if let error = error {
//                print("透传通知失败")
//            }
//        }
        
        print("[ GTSDK回调 ] 接收到透传通知: \(fromGetui ? "个推消息" : "APNs消息") appId:\(appId ?? "") offLine:\(offLine ? "离线" : "在线") taskId:\(taskId ?? "") msgId:\(msgId ?? "") userInfo:\(userInfo.keys) \(userInfo.debugDescription)")
        
        guard let msg = try? JSONDecoder().decode(PushMessage.self, from: (userInfo["payload"] as? String)?.data(using: .utf8) ?? Data()) else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = msg.data.title
        content.body = msg.data.content
        content.sound = UNNotificationSound.default

        // 创建触发条件，例如，在5秒后触发通知
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // 创建通知请求
        let request = UNNotificationRequest(identifier: "notificationIdentifier", content: content, trigger: trigger)

        // 获取通知中心实例
        let center = UNUserNotificationCenter.current()

        // 请求授权以显示通知
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                // 发送通知请求
                center.add(request) { (error) in
                    if let error = error {
                        print("发送通知失败：\(error.localizedDescription)")
                    } else {
                        print("通知已发送")
                    }
                }
            } else {
                print("用户未授权显示通知")
            }
        }
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
