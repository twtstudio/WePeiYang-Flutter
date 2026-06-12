import Flutter
import UIKit
import Darwin

extension Channel {
    func deviceInfoHandler() -> FlutterMethodCallHandler {
        return { call, result in
            switch call.method {
            case "getDeviceInfo":
                let device = UIDevice.current
                let screen = UIScreen.main

                let physicalMemory = ProcessInfo.processInfo.physicalMemory
                let ramGB = Double(physicalMemory) / 1_073_741_824.0

                var sysinfo = utsname()
                uname(&sysinfo)
                let modelIdentifier = withUnsafePointer(to: &sysinfo.machine) {
                    $0.withMemoryRebound(to: CChar.self, capacity: Int(_SYS_NAMELEN)) {
                        String(cString: $0)
                    }
                }

                device.isBatteryMonitoringEnabled = true

                result([
                    "manufacturer": "Apple",
                    "brand": "Apple",
                    "model": device.model,
                    "display": "\(device.systemName) \(device.systemVersion)",
                    "versionRelease": device.systemVersion,
                    "sdkInt": "0",
                    "incremental": "",
                    "fingerprint": device.identifierForVendor?.uuidString ?? "unknown",
                    "hardware": device.model,
                    "type": "",
                    "tags": "",
                    "buildTime": "0",
                    "supportedAbis": "",
                    "miuiVersion": "",
                    "hyperosVersion": "",
                    "serial": "",
                    "deviceName": device.name,
                    "idiom": device.userInterfaceIdiom == .phone ? "iPhone" : "iPad",
                    "modelIdentifier": modelIdentifier,
                    "ram": [
                        "totalRam": String(format: "%.1f", ramGB),
                        "availRam": "",
                        "lowMemory": "false",
                    ],
                    "storage": [
                        "storageTotal": "",
                        "storageAvail": "",
                    ],
                    "battery": [
                        "batteryPct": String(format: "%.0f", device.batteryLevel * 100),
                    ],
                    "density": [
                        "densityDpi": 0,
                        "density": screen.nativeScale,
                        "scaledDensity": screen.scale,
                        "refreshRate": 0,
                    ],
                ])
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}
