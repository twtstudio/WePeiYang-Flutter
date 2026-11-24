//
//  pushHandler.swift
//  Runner
//
//  Created by TwT on 2022/9/19.
//
import Flutter
import UIKit
import UserNotifications

extension Channel {
    func pushSettingHandler() -> FlutterMethodCallHandler {
        return { call, result in
            switch call.method {
            case "getCid":
                result(GeTuiSdk.clientId())
            case "getInstallId":
                result(IosPushService.shared.installId)
            case "getDeviceInfo":
                result(IosPushService.shared.deviceInfo)
            case "initGeTuiSdk":
                IosPushService.shared.enable(requestPermission: false, result: result)
            case "turnOnPushService":
                IosPushService.shared.enable(requestPermission: true, result: result)
            case "turnOffPushService":
                IosPushService.shared.pause(userDisabled: true)
                result(nil)
            case "pausePushService":
                IosPushService.shared.pause(userDisabled: false)
                result(nil)
            case "getCurrentCanReceivePush":
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    DispatchQueue.main.async {
                        result(IosPushService.shared.enabled && IosPushService.allowed(settings))
                    }
                }
            case "cancelAllNotification":
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    func messageHandler() -> FlutterMethodCallHandler {
        return { call, result in
            switch call.method {
            case "getLastEvent":
                result(IosPushService.shared.popEvent())
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}

/// SDK calls stay on the main queue. Flutter owns authenticated registration;
/// the installation ID survives account logout.
final class IosPushService {
    static let shared = IosPushService()
    private let installationKey = "wpy.push.installationId"
    private let disabledKey = "wpy.push.userDisabled"
    private var generation = 0
    private(set) var enabled = false
    private var started = false
    private var appliedPushEnabled: Bool?
    private var events: [[String: Any]] = []
    private var handledNotifications: [String] = []

    private var delegate: AppDelegate? {
        UIApplication.shared.delegate as? AppDelegate
    }

    var installId: String {
        if let value = UserDefaults.standard.string(forKey: installationKey), !value.isEmpty {
            return value
        }
        let value = UUID().uuidString.lowercased()
        UserDefaults.standard.set(value, forKey: installationKey)
        return value
    }

    var deviceInfo: [String: String] {
        ["cid": GeTuiSdk.clientId() ?? "",
         "appId": delegate?.pushAppId ?? "",
         "packageName": Bundle.main.bundleIdentifier ?? "",
         "installId": installId]
    }

    static func allowed(_ settings: UNNotificationSettings) -> Bool {
        settings.authorizationStatus == .authorized ||
            settings.authorizationStatus == .provisional ||
            settings.authorizationStatus == .ephemeral
    }

    func enable(requestPermission: Bool, result: @escaping FlutterResult) {
        generation += 1
        let current = generation
        if requestPermission {
            UserDefaults.standard.set(false, forKey: disabledKey)
        } else if UserDefaults.standard.bool(forKey: disabledKey) {
            result("refuse open push")
            return
        }
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                guard current == self.generation else {
                    result("refuse open push")
                    return
                }
                if Self.allowed(settings) {
                    self.start(result: result)
                } else if settings.authorizationStatus == .notDetermined {
                    guard requestPermission else {
                        result("showRequestNotificationDialog")
                        return
                    }
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                        DispatchQueue.main.async {
                            guard current == self.generation, granted else {
                                result("refuse open push")
                                return
                            }
                            self.start(result: result)
                        }
                    }
                } else {
                    self.pause(userDisabled: false)
                    if requestPermission, let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                    result("refuse open push")
                }
            }
        }
    }

    private func start(result: FlutterResult) {
        guard let delegate = delegate else {
            result(FlutterError(code: "INIT_GT_SDK_ERROR", message: "App delegate unavailable", details: nil))
            return
        }
        enabled = true
        if !started {
            delegate.startPushSdk()
            started = true
        }
        syncPushMode()
        // GTSDK 2.6.2 manages DeviceToken and APNs callbacks through this API.
        GeTuiSdk.registerRemoteNotification([.alert, .badge, .sound])
        result("open push service success")
    }

    func pause(userDisabled: Bool) {
        generation += 1
        enabled = false
        if userDisabled { UserDefaults.standard.set(true, forKey: disabledKey) }
        syncPushMode()
        UIApplication.shared.unregisterForRemoteNotifications()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        events.removeAll()
    }

    func sdkStateChanged(_ status: SdkStatus) {
        DispatchQueue.main.async {
            if status != .started { self.appliedPushEnabled = nil }
            self.syncPushMode()
        }
    }

    private func syncPushMode() {
        // GTSDK requires an online connection. Apply the latest desired state
        // after reconnecting, including a logout while startup was pending.
        guard GeTuiSdk.status() == .started, appliedPushEnabled != enabled else { return }
        appliedPushEnabled = enabled
        GeTuiSdk.setPushModeForOff(!enabled)
    }

    func cidChanged() {
        DispatchQueue.main.async {
            self.syncPushMode()
            guard self.enabled else { return }
            self.delegate?.getChannel(type: .push)?.channel.invokeMethod("cidChanged", arguments: nil)
        }
    }

    func receiveClick(_ response: UNNotificationResponse) {
        guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else { return }
        DispatchQueue.main.async {
            let request = response.notification.request
            // Both the system delegate and GTSDK may report the same tap.
            guard !self.handledNotifications.contains(request.identifier) else { return }
            self.handledNotifications.append(request.identifier)
            if self.handledNotifications.count > 64 { self.handledNotifications.removeFirst() }
            let userInfo = request.content.userInfo
            guard let payload = userInfo["payload"], payload is String || payload is [String: Any] else { return }
            self.enqueue(payload)
        }
    }

    func enqueue(_ payload: Any) {
        if events.count >= 20 { events.removeFirst() }
        events.append(["event": 8, "data": payload])
        delegate?.getChannel(type: .message)?.channel.invokeMethod("eventChanged", arguments: nil)
    }

    func popEvent() -> [String: Any] {
        events.isEmpty ? ["event": -1] : events.removeFirst()
    }
}
