# iOS 推送配置与验收

客户端沿用个推 GTSDK 2.6.2.0，通过 APNs 展示通知；设备绑定使用 Android
相同的 `https://api.twt.edu.cn/api/notification/device/register` 接口，
复用个人中心的 DOMAIN/ticket 应用鉴权，并携带本次操作捕获的登录 token。
登录并允许通知后上传 CID、安装 ID、Bundle ID、App ID 和环境；退出账号或
关闭推送时调用 `device/disable`，并在本机暂停推送。账号升级成功不自动解绑。

推送开关以最近一次操作为准，过期的权限回调、关闭请求或错误不会覆盖新状态。
个推 SDK 上线或重新连接后，会再次同步当前开关；启动期间退出账号时也会同步关闭。

## 发布前需要完成的配置

1. Apple Developer 中为 `com.twt.WePeiYang-1` 开启 Push Notifications。
   Xcode Runner 的 Team 仍为项目现有的 `A4JNABY964`，签名描述文件必须包含
   对应的推送权限。更换团队或包名时，需要一起调整 Apple 和个推配置。
2. 个推控制台的应用 `43HGFmIKsnAmjrjDLr60X4` 需要配置该 Bundle ID 对应的
   APNs 凭据。若当前控制台支持 APNs Auth Key，配置 Key ID、Team ID 和 p8；
   否则按控制台要求上传开发/生产推送证书。私钥、证书密码不放进仓库。
3. `Runner.entitlements` 的 APNs 环境来自 `APS_ENVIRONMENT`：Debug 为
   `development`，Release/Profile 为 `production`。TestFlight/App Store
   使用生产 APNs；开发签名真机使用沙盒。以最终签名包的 entitlements 为准。
   个推控制台也必须支持待测包的对应 APNs 环境。
4. `PUSH_ENVIRONMENT` 是后端筛选设备的业务环境，默认 `RELEASE`，
   **不是** APNs 的开发/生产环境。不要因为 Xcode 使用 Debug 就改成 DEVELOP。
   若要隔离测试，需同时准备个推测试应用凭据、后端 appId/environment 和客户端配置；
   仅改变 Dart 参数不会创建一套测试推送通道。
5. 同步部署 opencenter 的 iOS 修复：iOS 设备不生成 Android Intent；
   APNs `payload` 必须为 `{"type":2,"data":{"title":"…","content":"…","url":"…"}}`。
   旧后端的占位 payload 无法完成点击跳转。

## Mac 上构建

使用项目要求的 Flutter 3.44，安装 Xcode、CocoaPods，运行 `flutter pub get`，
在 ios 目录运行 `pod install`，打开 `ios/Runner.xcworkspace` 检查 Runner 的
Signing & Capabilities（Push Notifications 和 Background Modes / Remote notifications）。
用 `flutter build ipa --release --dart-define=PUSH_ENVIRONMENT=RELEASE` 或 Xcode Archive
构建并验证签名。此仓库中的 iOS 修改尚需 Mac/Xcode 编译与真机确认。

## 真机验收

- 首次登录：同意通知权限，确认后台该账号有 IOS / 正确 Bundle ID / 当前 CID 的 ACTIVE 设备。
- 从系统设置拒绝/重新允许通知后回到应用，开关和设备注册应同步；关闭应用内推送后回前台不能自动开启。
- 同账号多设备分别保留注册；退出或切换账号后旧账号不能继续向当前安装推送。
- 应用前台、后台、冷启动分别测试评论/回复通知。仅点击时进入帖子，返回到论坛；重复回调不重复打开。
- 删帖/公告通知点击进入湖底通知；普通网页通知进入消息详情；非法链接不导航。
- 临时断网再恢复，CID 注册可在有限重试或回到前台时恢复；退出后的迟到回调不能重新绑定。
- 弱网下快速关闭再开启推送，最终保持开启；SDK 尚未连接时退出账号，连接后仍保持暂停。
- TestFlight 单独验证生产 APNs 送达。模拟器或 Dart 测试通过不能代替这一步。

Windows 可运行的回归测试：`flutter test test/ios_push_manager_test.dart test/ios_push_registration_test.dart test/ios_push_device_api_test.dart test/ios_notification_target_test.dart test/post_notification_target_test.dart test/push_notification_navigation_test.dart`。
