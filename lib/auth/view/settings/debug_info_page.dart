import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/schedule/page/course_page.dart';

class DebugInfoPage extends StatefulWidget {
  const DebugInfoPage({super.key});

  @override
  State<DebugInfoPage> createState() => _DebugInfoPageState();
}

class _DebugInfoPageState extends State<DebugInfoPage> {
  PackageInfo? _appInfo = null;
  String _osVersion = 'Unknown';
  String _deviceModel = 'Unknown';
  String osType = "OS";
  AndroidDeviceInfo? _androidDeviceInfo;
  IosDeviceInfo? _iosDeviceInfo;

  Future<void> _initDeviceInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceModel;
    String osVersion;

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      final iosDeviceInfo = await deviceInfo.iosInfo;
      deviceModel = iosDeviceInfo.model ?? 'Unknown model';
      osVersion = iosDeviceInfo.systemVersion ?? 'Unknown version';
      osType = "iOS";
      _iosDeviceInfo = iosDeviceInfo;
    } else {
      final androidDeviceInfo = await deviceInfo.androidInfo;
      androidDeviceInfo.display;
      deviceModel = androidDeviceInfo.model ?? 'Unknown model';
      osVersion = androidDeviceInfo.version.release ?? 'Unknown version';
      osType = "Android";
      _androidDeviceInfo = androidDeviceInfo;
    }

    setState(() {
      _appInfo = info;
      _deviceModel = deviceModel;
      _osVersion = osVersion;
    });
  }

  final screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _initDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      appBar: AppBar(
        title: Text('设备信息'),
        centerTitle: true,
        titleTextStyle: TextUtil.base.sp(18).primary(context),
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: WpyTheme.of(context).get(WpyColorKey.basicTextColor),
          ),
          onPressed: () => Navigator.pop(context),
          color: WpyTheme.of(context).get(WpyColorKey.basicTextColor),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _initDeviceInfo();
            },
            icon: Icon(
              Icons.refresh,
              size: 28,
              color: WpyTheme.of(context).get(WpyColorKey.basicTextColor),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.camera_alt_outlined,
              size: 28,
            ),
            onPressed: () {
              screenshotController.captureAsUiImage().then((value) async {
                if (value == null) {
                  ToastProvider.error("图片保存失败");
                  return;
                }
                final fullPath = await saveImageToPath(
                    (await value.toByteData(format: ImageByteFormat.png))!
                        .buffer
                        .asUint8List());
                GallerySaver.saveImage(fullPath!, albumName: "微北洋");
                ToastProvider.success("图片保存成功");
              }).onError((error, stackTrace) {
                ToastProvider.error("图片保存失败");
              });
            },
            color: WpyTheme.of(context).get(WpyColorKey.basicTextColor),
          ),
        ],
      ),
      body: ListView(children: [
        Screenshot(
          controller: screenshotController,
          child: ColoredBox(
            color:
                WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset(
                          'assets/app_icon.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                      Text(
                        '微北洋 Flutter',
                        style: TextUtil.base.sp(22).bold.primary(context),
                      ),
                      Text(
                        'Powered By TWT Studio',
                        style: TextStyle(
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.secondaryTextColor)
                              .withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                ListTile(
                  title: Text(
                    'Package Info',
                    style: TextStyle(
                      color:
                          WpyTheme.of(context).get(WpyColorKey.basicTextColor),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  title: Text('Package Info'),
                  subtitle: Text(
                      "${EnvConfig.ENVIRONMENT} ${EnvConfig.VERSION}+${EnvConfig.VERSIONCODE}"),
                ),
                ListTile(
                  title: Text('App Version'),
                  subtitle: Text(_appInfo != null
                      ? "${_appInfo!.appName} ${_appInfo!.version}+${_appInfo!.buildNumber}"
                      : 'Unknown'),
                ),
                ListTile(
                  title: Text('Package Name'),
                  subtitle: Text(_appInfo?.packageName ?? 'Unknown'),
                ),
                ListTile(
                  title: Text('Build Signature'),
                  subtitle: Text(_appInfo?.buildSignature ?? 'Unknown'),
                ),
                ListTile(
                  title: Text('Installer Store'),
                  subtitle: Text(_appInfo?.installerStore ?? 'Unknown'),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    'Device Info',
                    style: TextStyle(
                      color:
                          WpyTheme.of(context).get(WpyColorKey.basicTextColor),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  title: Text('$osType Version'),
                  subtitle: Text("$osType $_osVersion"),
                  trailing: Icon(
                    Theme.of(context).platform == TargetPlatform.iOS
                        ? Icons.apple
                        : Icons.android,
                    size: 30,
                    color: WpyTheme.of(context)
                        .get(WpyColorKey.primaryActionColor),
                  ),
                ),
                ListTile(
                  title: Text('Device Model'),
                  subtitle: Text(_deviceModel),
                ),
                ListTile(
                  title: Text('Device ID'),
                  subtitle: Text(
                      Theme.of(context).platform == TargetPlatform.iOS
                          ? _iosDeviceInfo?.identifierForVendor ?? 'Unknown'
                          : _androidDeviceInfo?.fingerprint ?? 'Unknown'),
                ),
                ListTile(
                  title: Text('Device Name'),
                  subtitle: Text(
                      Theme.of(context).platform == TargetPlatform.iOS
                          ? _iosDeviceInfo?.name ?? 'Unknown'
                          : _androidDeviceInfo?.device ?? 'Unknown'),
                ),
                ListTile(
                  title: Text('Device Brand'),
                  subtitle: Text(
                      Theme.of(context).platform == TargetPlatform.iOS
                          ? _iosDeviceInfo?.name ?? 'Unknown'
                          : _androidDeviceInfo?.brand ?? 'Unknown'),
                ),
                ListTile(
                  title: Text('Device Manufacturer'),
                  subtitle: Text(
                      Theme.of(context).platform == TargetPlatform.iOS
                          ? _iosDeviceInfo?.name ?? 'Unknown'
                          : _androidDeviceInfo?.manufacturer ?? 'Unknown'),
                ),
                ListTile(
                  title: Text('Device Type'),
                  subtitle: Text(
                      Theme.of(context).platform == TargetPlatform.iOS
                          ? _iosDeviceInfo?.name ?? 'Unknown'
                          : _androidDeviceInfo?.type ?? 'Unknown'),
                ),
                ListTile(
                  title: Text('Device System Name'),
                  subtitle: Text(
                      Theme.of(context).platform == TargetPlatform.iOS
                          ? _iosDeviceInfo?.systemName ?? 'Unknown'
                          : _androidDeviceInfo?.host ?? 'Unknown'),
                ),
                if (Theme.of(context).platform == TargetPlatform.android) ...[
                  ListTile(
                    title: Text('Supported ABIs'),
                    subtitle: Text(
                        _androidDeviceInfo?.supportedAbis.join("\n") ??
                            'Unknown'),
                  ),
                  // is real device
                  ListTile(
                    title: Text('Is Real Device'),
                    subtitle: Text(
                        _androidDeviceInfo?.isPhysicalDevice.toString() ??
                            'Unknown'),
                  ),
                  ListTile(
                    title: Text('Android Serial Number'),
                    subtitle:
                        Text(_androidDeviceInfo?.serialNumber ?? 'Unknown'),
                  ),
                  ListTile(
                    title: Text('Display Resolution'),
                    subtitle: Text(
                      _androidDeviceInfo != null
                          ? "${_androidDeviceInfo!.displayMetrics.widthPx} x ${_androidDeviceInfo!.displayMetrics.heightPx}"
                          : "Unknown",
                    ),
                  ),
                ],
                Divider(),
                ListTile(
                  title: Text(
                    'Screen Info',
                    style: TextStyle(
                      color:
                          WpyTheme.of(context).get(WpyColorKey.basicTextColor),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  title: Text('Screen Size'),
                  subtitle: Text(
                      "${MediaQuery.of(context).size.width} x ${MediaQuery.of(context).size.height}"),
                ),
                ListTile(
                  title: Text('Screen Pixel Ratio'),
                  subtitle:
                      Text(MediaQuery.of(context).devicePixelRatio.toString()),
                ),
                ListTile(
                  title: Text('Text Scale Factor'),
                  subtitle:
                      Text(MediaQuery.of(context).textScaleFactor.toString()),
                ),
                ListTile(
                  title: Text('Platform Brightness'),
                  subtitle: Text(
                      MediaQuery.of(context).platformBrightness.toString()),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
