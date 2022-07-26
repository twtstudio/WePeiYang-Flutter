import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
//      let userDefaults = UserDefaults.init(suiteName: "group.com.weipeiyang")
//      userDefaults!.setValue("defaultID", forKey: "id")
//      userDefaults!.setValue("defauleName", forKey: "name")
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
