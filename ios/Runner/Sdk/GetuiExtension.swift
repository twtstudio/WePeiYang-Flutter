import UIKit
import UserNotifications

extension AppDelegate {
    func geTuiSDkDidNotifySdkState(_ status: SdkStatus) {
        IosPushService.shared.sdkStateChanged(status)
    }

    func geTuiSdkDidRegisterClient(_ clientId: String) {
        IosPushService.shared.cidChanged()
    }

    func geTuiSdkDidOccurError(_ error: Error) {
        let sdkError = error as NSError
        NSLog("GTSDK error domain=%@ code=%ld", sdkError.domain, sdkError.code)
    }

    func geTuiSdkNotificationCenter(_ center: UNUserNotificationCenter,
                                   willPresent notification: UNNotification,
                                   completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        DispatchQueue.main.async {
            completionHandler(IosPushService.shared.enabled ? [.badge, .sound, .list, .banner] : [])
        }
    }

    func geTuiSdkDidReceiveNotification(_ userInfo: [AnyHashable: Any],
                                       notificationCenter center: UNUserNotificationCenter?,
                                       response: UNNotificationResponse?,
                                       fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
        // Receiving a message is not a navigation event; only an explicit tap is.
        if let response = response { IosPushService.shared.receiveClick(response) }
        completionHandler?(.noData)
    }

    func geTuiSdkDidReceiveSlience(_ userInfo: [AnyHashable: Any],
                                 fromGetui: Bool, offLine: Bool, appId: String?,
                                 taskId: String?, msgId: String?,
                                 fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
        // The server uses visible APNs notifications (iOS strategy 4).
        // Do not render a duplicate local notification for a transmission.
        completionHandler?(.noData)
    }
}
