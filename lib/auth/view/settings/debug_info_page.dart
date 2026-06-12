import 'dart:io' show HttpClient, Platform;
import 'dart:ui' show ImageByteFormat;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kProfileMode, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/schedule/page/course_page.dart' show saveImageToPath;

class _EndpointDef {
  final String url;
  final String label;
  final String method;
  const _EndpointDef(this.label, this.url, {this.method = 'GET'});
}

const _kTjuEndpoints = [
  _EndpointDef('教务网', 'https://classes.tju.edu.cn/eams/courseTableForStd!index.action'),
  _EndpointDef('单点登录', 'https://sso.tju.edu.cn/cas/login'),
  _EndpointDef('办公网', 'https://f.tju.edu.cn/tp_up/up/mobile/ifs/getAccountQRcodeInfo'),
  _EndpointDef('图书馆', 'https://ic.lib.tju.edu.cn/ic-web/auth/address'),
  _EndpointDef('图书馆用户', 'https://user.lib.tju.edu.cn'),
  _EndpointDef('小天 AI', 'https://student.tju.edu.cn/ai'),
];

const _kTwtEndpoints = [
  _EndpointDef('微北洋 API', 'https://api.twt.edu.cn/api/semester'),
  _EndpointDef('课程学习后端', 'https://learning.twt.edu.cn/get_classes'),
  _EndpointDef('自习室', 'https://selfstudy.twt.edu.cn/campus'),
  _EndpointDef('青年湖底', 'https://qnhd.twt.edu.cn/api/v1/f/banners'),
  _EndpointDef('图片 CDN', 'https://qnhdpic.twt.edu.cn/download/'),
  _EndpointDef('海棠', 'https://haitang.twt.edu.cn/api/v1/banner'),
  _EndpointDef('自定义课表', 'https://activity.twt.edu.cn/api/v1/user/auth/fromClient/login', method: 'POST'),
  _EndpointDef('升级服务', 'https://upgrade.twt.edu.cn/androidupdate/check/1'),
  _EndpointDef('年度总结', 'https://areas.twt.edu.cn/api/'),
];

const _kEndpointDefs = [..._kTjuEndpoints, ..._kTwtEndpoints];

const _cpuNameMap = <String, String>{
  'mt6899': '天玑 9300',
  'mt6897': '天玑 9200+',
  'mt6896': '天玑 9200',
  'mt6895': '天玑 9000+/天玑 9200',
  'mt6893': '天玑 9000',
  'mt6891': '天玑 1100/1200',
  'mt6889': '天玑 1000+',
  'mt6885': '天玑 1000L',
  'mt6877': '天玑 900/920',
  'mt6875': '天玑 820',
  'mt6873': '天玑 800/820',
  'mt6855': '天玑 930',
  'mt6853': '天玑 720/800U',
  'mt6833': '天玑 700/810/6080',
  'mt6789': 'Helio G99',
  'mt6785': 'Helio G90T',
  'mt6779': 'Helio P90',
  'mt6771': 'Helio P70',
  'mt6799': 'Helio X30',
  'mt6797': 'Helio X20/X25',
  'mt6768': 'Helio P65/G85',
  'mt6765': 'Helio P35/G35',
  'mt6762': 'Helio P22/G25',
  'mt6761': 'Helio A22',
  'sm8650': '骁龙 8 Gen 3',
  'sm8550': '骁龙 8 Gen 2',
  'sm8475': '骁龙 8+ Gen 1',
  'sm8450': '骁龙 8 Gen 1',
  'sm8350': '骁龙 888',
  'sm8325': '骁龙 8cx Gen 2',
  'sm8250': '骁龙 865/870',
  'sm8150': '骁龙 855/860',
  'sm7450': '骁龙 7 Gen 3',
  'sm7550': '骁龙 7 Gen 3',
  'sm7475': '骁龙 7+ Gen 2',
  'sm7350': '骁龙 780G',
  'sm7325': '骁龙 778G',
  'sm7250': '骁龙 765G',
  'sm7150': '骁龙 730/730G',
  'sm7125': '骁龙 720G',
  'sm6375': '骁龙 695',
  'sm6225': '骁龙 680',
  'sm4450': '骁龙 4 Gen 1',
  's5e9945': 'Exynos 2400',
  's5e9935': 'Exynos 2300',
  's5e9925': 'Exynos 2200',
  's5e9840': 'Exynos 2100',
  's5e9830': 'Exynos 990',
  's5e9825': 'Exynos 9825',
  's5e9820': 'Exynos 9820',
  's5e9810': 'Exynos 9810',
  's5e8895': 'Exynos 8895',
  's5e8890': 'Exynos 8890',
  'universal9925': 'Exynos 2200',
  'universal9840': 'Exynos 2100',
  'universal9830': 'Exynos 990',
  'universal9825': 'Exynos 9825',
  'universal9820': 'Exynos 9820',
  'universal9810': 'Exynos 9810',
  'universal8895': 'Exynos 8895',
  'universal8890': 'Exynos 8890',
  'exynos9925': 'Exynos 2200',
  'exynos9840': 'Exynos 2100',
  'exynos9830': 'Exynos 990',
  'exynos9825': 'Exynos 9825',
  'exynos9820': 'Exynos 9820',
  'exynos9810': 'Exynos 9810',
  'exynos8895': 'Exynos 8895',
  'exynos8890': 'Exynos 8890',
  'kirin9000': '麒麟 9000',
  'kirin990': '麒麟 990',
  'kirin980': '麒麟 980',
  'kirin970': '麒麟 970',
  'kirin960': '麒麟 960',
  't8120': 'Apple A18 Pro',
  't8112': 'Apple A16',
  't8110': 'Apple A15',
  't8101': 'Apple A14',
  't8030': 'Apple A13',
  't8020': 'Apple A12',
  't8015': 'Apple A11',
  't8010': 'Apple A10',
};

String _cpuDisplayName(String raw) {
  final lower = raw.toLowerCase().trim();
  final known = _cpuNameMap[lower] ?? _cpuNameMap[raw.trim()];
  if (known != null) return '$known ($raw)';
  return raw;
}

class DebugInfoPage extends StatefulWidget {
  const DebugInfoPage({super.key});

  @override
  State<DebugInfoPage> createState() => _DebugInfoPageState();
}

class _DebugInfoPageState extends State<DebugInfoPage> with SingleTickerProviderStateMixin {
  static const _deviceChannel = MethodChannel('com.twt.service/device_info');

  PackageInfo? _appInfo;
  String _osVersion = 'Unknown';
  String _dartVersion = 'Unknown';
  String _connectivity = '检测中…';
  final Map<String, String> _endpointStatus = {};
  Map<String, dynamic> _nativeInfo = {};
  bool _loading = true;

  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnim;

  String get _buildMode {
    if (kReleaseMode) return 'Release';
    if (kProfileMode) return 'Profile';
    return 'Debug';
  }

  Color get _buildModeColor {
    final theme = WpyTheme.of(context);
    if (kReleaseMode) return theme.get(WpyColorKey.successGreen);
    if (kProfileMode) return theme.get(WpyColorKey.warningColor);
    return theme.get(WpyColorKey.linkBlue);
  }

  String _connectivityLabel(String raw) {
    return raw
        .replaceAll('wifi', 'WiFi')
        .replaceAll('mobile', '蜂窝')
        .replaceAll('ethernet', '以太网')
        .replaceAll('bluetooth', '蓝牙')
        .replaceAll('vpn', 'VPN')
        .replaceAll('none', '无');
  }

  Future<void> _refreshConnectivity() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      for (final e in _kEndpointDefs) {
        _endpointStatus[e.label] = '检测中…';
      }
    });

    Connectivity().checkConnectivity().then((c) {
      if (!mounted) return;
      setState(() => _connectivity = c.map((e) => e.name).join(', '));
    });

    final futures = <Future<void>>[];
    for (final e in _kEndpointDefs) {
      futures.add(_checkUrl(e).then((s) {
        if (!mounted) return;
        setState(() => _endpointStatus[e.label] = s);
      }));
    }

    Future.wait(futures).then((_) {
      if (!mounted) return;
      setState(() => _loading = false);
    });
  }

  Color _statusColor(String status) {
    final theme = WpyTheme.of(context);
    if (status == '检测中…') return theme.get(WpyColorKey.secondaryTextColor);
    if (status == '不可达') return theme.get(WpyColorKey.dangerousRed);
    return theme.get(WpyColorKey.successGreen);
  }

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _shimmerAnim = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    _shimmerController.repeat(reverse: true);
    _initDeviceInfo();
  }

  Future<String> _checkUrl(_EndpointDef ep) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);
      final uri = Uri.parse(ep.url);
      final sw = Stopwatch()..start();
      final request = ep.method == 'POST'
          ? await client.postUrl(uri)
          : await client.getUrl(uri);
      await request.close().timeout(const Duration(seconds: 3));
      sw.stop();
      return '${sw.elapsedMilliseconds}ms';
    } catch (_) {
      return '不可达';
    }
  }

  Future<void> _initDeviceInfo() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      for (final e in _kEndpointDefs) {
        _endpointStatus[e.label] = '检测中…';
      }
    });

    Connectivity().checkConnectivity().then((c) {
      if (!mounted) return;
      setState(() => _connectivity = c.map((e) => e.name).join(', '));
    });

    final futures = <Future<void>>[];
    for (final e in _kEndpointDefs) {
      futures.add(_checkUrl(e).then((s) {
        if (!mounted) return;
        setState(() => _endpointStatus[e.label] = s);
      }));
    }

    final results = await Future.wait([
      PackageInfo.fromPlatform(),
      _deviceChannel.invokeMethod<Map>('getDeviceInfo'),
    ]);
    await Future.wait(futures);

    if (!mounted) return;

    final appInfo = results[0] as PackageInfo;
    final rawNative = results[1];
    final nativeInfo = <String, dynamic>{};
    if (rawNative is Map) {
      for (final entry in (rawNative).entries) {
        final v = entry.value;
        nativeInfo[entry.key.toString()] = v is Map ? Map<String, dynamic>.from(v) : v;
      }
    }

    _osVersion = '${nativeInfo['versionRelease'] ?? Platform.operatingSystemVersion} (API ${nativeInfo['sdkInt'] ?? '?'})';

    setState(() {
      _appInfo = appInfo;
      _nativeInfo = nativeInfo;
      _dartVersion = Platform.version.split(' ').first;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  final screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final accentColor = WpyTheme.of(context).get(WpyColorKey.primaryActionColor);

    return Scaffold(
      backgroundColor: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      appBar: _buildAppBar(accentColor),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Screenshot(
            controller: screenshotController,
            child: ColoredBox(
              color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 8),
                  _buildSectionCard(
                    context,
                    icon: Icons.inventory_2_outlined,
                    title: '应用信息',
                    accentColor: accentColor,
                    children: [
                      _buildInfoRow('环境标识', '${EnvConfig.ENVIRONMENT} ${EnvConfig.VERSION}+${EnvConfig.VERSIONCODE}'),
                      _buildDivider(),
                      _buildInfoRow('应用版本', _appInfo != null ? '${_appInfo!.appName} ${_appInfo!.version}+${_appInfo!.buildNumber}' : 'Unknown', monospace: true),
                      _buildDivider(),
                      _buildInfoRow('包名', _appInfo?.packageName ?? 'Unknown', monospace: true),
                      _buildDivider(),
                      _buildInfoRow('构建签名', _appInfo?.buildSignature ?? 'Unknown', monospace: true),
                      _buildDivider(),
                      _buildInfoRow('安装来源', _appInfo?.installerStore ?? 'Unknown'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    context,
                    icon: Icons.phone_android_outlined,
                    title: '设备信息',
                    accentColor: accentColor,
                    children: [
                      _buildInfoRow('系统版本', _osVersion),
                      _buildDivider(),
                      _buildInfoRow('固件版本', () {
                        final hyper = (_nativeInfo['hyperosVersion'] ?? '').toString();
                        if (hyper.isNotEmpty) return hyper;
                        final miui = (_nativeInfo['miuiVersion'] ?? '').toString();
                        if (miui.isNotEmpty && miui != '非 MIUI') return miui;
                        return _nativeInfo['display']?.toString() ?? '';
                      }()),
                      _buildDivider(),
                      _buildInfoRow('厂商', _nativeInfo['manufacturer']?.toString() ?? 'Unknown'),
                      _buildDivider(),
                      _buildInfoRow('品牌', _nativeInfo['brand']?.toString() ?? 'Unknown'),
                      _buildDivider(),
                      _buildInfoRow('型号', _nativeInfo['model']?.toString() ?? 'Unknown'),
                      _buildDivider(),
                      _buildInfoRow('硬件', _cpuDisplayName(_nativeInfo['hardware']?.toString() ?? 'Unknown')),
                      _buildDivider(),
                      _buildInfoRow('构建类型', '${_nativeInfo['type']} / ${_nativeInfo['tags']}'),
                      _buildDivider(),
                      _buildInfoRow('增量版本', _nativeInfo['incremental']?.toString() ?? ''),
                      _buildDivider(),
                      _buildInfoRow('CPU ABI', _nativeInfo['supportedAbis']?.toString() ?? ''),
                      _buildDivider(),
                      _buildInfoRow('指纹', _nativeInfo['fingerprint']?.toString() ?? '', monospace: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    context,
                    icon: Icons.memory_outlined,
                    title: '内存 & 存储',
                    accentColor: accentColor,
                    children: [
                      _buildRamStorageRow(_nativeInfo['ram'], _nativeInfo['storage']),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    context,
                    icon: Icons.screenshot_monitor_outlined,
                    title: '屏幕信息',
                    accentColor: accentColor,
                    children: [
                      _buildInfoRow('分辨率', '${MediaQuery.of(context).size.width.round()} × ${MediaQuery.of(context).size.height.round()}'),
                      _buildDivider(),
                      _buildInfoRow('像素比', MediaQuery.of(context).devicePixelRatio.toStringAsFixed(2)),
                      _buildDivider(),
                      _buildInfoRow('亮度模式', MediaQuery.of(context).platformBrightness.name == 'dark' ? '深色' : '浅色'),
                      _buildDivider(),
                      _buildDensityRow(_nativeInfo['density'], _nativeInfo['battery']),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    context,
                    icon: Icons.info_outline,
                    title: '运行环境',
                    accentColor: accentColor,
                    children: [
                      _buildInfoRow('Dart 版本', _dartVersion, monospace: true),
                      _buildDivider(),
                      _buildLabeledRow('编译模式', _buildMode, _buildModeColor),
                      _buildDivider(),
                      _buildInfoRow('系统语言', Platform.localeName),
                      _buildDivider(),
                      _buildInfoRow('CPU 核心数', Platform.numberOfProcessors.toString()),
                      _buildDivider(),
                      _buildInfoRow('字体缩放', MediaQuery.textScalerOf(context).textScaleFactor.toStringAsFixed(2)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    context,
                    icon: Icons.wifi_outlined,
                    title: '网络连通性',
                    accentColor: accentColor,
                    trailing: IconButton(
                      onPressed: _loading ? null : _refreshConnectivity,
                      icon: Icon(Icons.refresh, size: 20, color: accentColor),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    children: [
                      _buildLabeledRow(
                        '网络类型',
                        _connectivityLabel(_connectivity),
                        _statusColor(_connectivity),
                      ),
                      _buildDivider(),
                      _buildSubHeader('天津大学'),
                      ..._kTjuEndpoints.map((e) => _buildEndpointRow(e)),
                      _buildDivider(),
                      _buildSubHeader('天外天'),
                      ..._kTwtEndpoints.map((e) => _buildEndpointRow(e)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color accentColor) {
    return AppBar(
      title: const Text('设备信息'),
      centerTitle: true,
      titleTextStyle: TextUtil.base.sp(18).primary(context),
      backgroundColor: WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: WpyTheme.of(context).get(WpyColorKey.basicTextColor)),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          onPressed: _initDeviceInfo,
          icon: _loading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: accentColor),
                )
              : Icon(Icons.refresh, size: 26, color: accentColor),
        ),
        IconButton(
          onPressed: _captureScreenshot,
          icon: Icon(Icons.camera_alt_outlined, size: 26, color: accentColor),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.all(Radius.circular(22)),
              boxShadow: [
                BoxShadow(
                  color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor).withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipPath(
              clipper: ShapeBorderClipper(
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(34),
                ),
              ),
              child: Image.asset('assets/app_icon.png', width: 88, height: 88),
            ),
          ),
          const SizedBox(height: 16),
          Text('微北洋 Flutter', style: TextUtil.base.sp(22).bold.primary(context)),
          const SizedBox(height: 4),
          Text(
            'Powered By TWT Studio',
            style: TextStyle(
              color: WpyTheme.of(context).get(WpyColorKey.secondaryTextColor).withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color accentColor,
    required List<Widget> children,
    Widget? trailing,
  }) {
    final cardColor = WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: accentColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: WpyTheme.of(context).get(WpyColorKey.basicTextColor),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing,
                ],
              ),
            ),
            ...children,
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool monospace = false}) {
    return _buildLabeledRow(label, value, null, monospace: monospace);
  }

  Widget _buildLabeledRow(String label, String value, Color? valueColor, {bool monospace = false}) {
    final color = WpyTheme.of(context).get(WpyColorKey.basicTextColor);
    final subColor = WpyTheme.of(context).get(WpyColorKey.secondaryTextColor).withValues(alpha: 0.7);
    final isLoading = _loading && (value == '检测中…' || value == 'Unknown');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: subColor, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: value));
                ToastProvider.success('已复制: $label');
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isLoading
                    ? Align(key: const ValueKey('s'), alignment: Alignment.centerRight, child: _buildShimmerPlaceholder())
                    : Row(
                        key: ValueKey(value),
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (valueColor != null) ...[
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 5, right: 6),
                              decoration: BoxDecoration(shape: BoxShape.circle, color: valueColor),
                            ),
                          ],
                          Flexible(
                            child: SelectableText(
                              value,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 13,
                                color: color,
                                fontWeight: FontWeight.w600,
                                fontFamily: monospace ? 'monospace' : null,
                                letterSpacing: monospace ? -0.2 : null,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return FadeTransition(
      opacity: _shimmerAnim,
      child: Container(
        height: 14,
        width: 160,
        decoration: BoxDecoration(
          color: WpyTheme.of(context).get(WpyColorKey.secondaryTextColor).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildSubHeader(String text) {
    final subColor = WpyTheme.of(context).get(WpyColorKey.secondaryTextColor).withValues(alpha: 0.6);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Text(text, style: TextStyle(fontSize: 11, color: subColor, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
    );
  }

  Widget _buildEndpointRow(_EndpointDef ep) {
    final status = _endpointStatus[ep.label] ?? '检测中…';
    final isLoading = status == '检测中…';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 85,
                child: Text(ep.label, style: TextStyle(fontSize: 13, color: WpyTheme.of(context).get(WpyColorKey.secondaryTextColor).withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isLoading
                      ? Align(key: const ValueKey('s'), alignment: Alignment.centerRight, child: _buildShimmerPlaceholder())
                      : Row(
                          key: ValueKey(status),
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 5, right: 6), decoration: BoxDecoration(shape: BoxShape.circle, color: _statusColor(status))),
                            SelectableText(status, style: TextStyle(fontSize: 13, color: WpyTheme.of(context).get(WpyColorKey.basicTextColor), fontWeight: FontWeight.w600)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
        _buildDivider(),
      ],
    );
  }

  Widget _buildRamStorageRow(dynamic ramRaw, dynamic storageRaw) {
    final ram = ramRaw is Map<String, dynamic> ? ramRaw : <String, dynamic>{};
    final storage = storageRaw is Map<String, dynamic> ? storageRaw : <String, dynamic>{};
    final ramTotal = ram['totalRam'] ?? '?';
    final ramAvail = ram['availRam'] ?? '?';
    final lowMem = ram['lowMemory']?.toString() == 'true';
    final storageTotal = storage['storageTotal'] ?? '?';
    final storageAvail = storage['storageAvail'] ?? '?';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _memItem(Icons.memory, 'RAM', '$ramAvail / $ramTotal GB', lowMem ? '低' : '', lowMem ? const Color(0xFFE53935) : null),
          const SizedBox(width: 12),
          _memItem(Icons.sd_storage_outlined, '存储', '$storageAvail / $storageTotal GB', '', null),
        ],
      ),
    );
  }

  Widget _memItem(IconData icon, String label, String value, String badge, Color? badgeColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: WpyTheme.of(context).get(WpyColorKey.secondaryTextColor).withValues(alpha: 0.6)),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(label, style: TextStyle(fontSize: 10, color: WpyTheme.of(context).get(WpyColorKey.secondaryTextColor).withValues(alpha: 0.6), fontWeight: FontWeight.w600)),
                      if (badge.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: badgeColor?.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(3)), child: Text(badge, style: TextStyle(fontSize: 8, color: badgeColor, fontWeight: FontWeight.w700))),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(value, style: TextStyle(fontSize: 11, color: WpyTheme.of(context).get(WpyColorKey.basicTextColor), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDensityRow(dynamic densityRaw, dynamic batteryRaw) {
    final density = densityRaw is Map<String, dynamic> ? densityRaw : <String, dynamic>{};
    final battery = batteryRaw is Map<String, dynamic> ? batteryRaw : <String, dynamic>{};
    final dpi = density['densityDpi']?.toString() ?? '?';
    final refreshRaw = density['refreshRate'];
    final refresh = refreshRaw is num ? refreshRaw.round().toString() : '?';
    final battPct = int.tryParse(battery['batteryPct']?.toString() ?? '-1');
    final battStr = battPct != null && battPct > 0 ? '$battPct%' : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _memItem(Icons.grid_4x4, 'DPI', dpi, '', null),
          const SizedBox(width: 12),
          _memItem(Icons.refresh, '刷新率', '$refresh Hz', '', null),
          if (battStr.isNotEmpty) ...[
            const SizedBox(width: 12),
            _memItem(Icons.battery_5_bar, '电量', battStr, '', null),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: WpyTheme.of(context).get(WpyColorKey.secondaryTextColor).withValues(alpha: 0.1),
    );
  }

  void _captureScreenshot() {
    screenshotController.captureAsUiImage().then((value) async {
      if (value == null) {
        ToastProvider.error("图片保存失败");
        return;
      }
      final fullPath = await saveImageToPath(
          (await value.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List());
      GallerySaver.saveImage(fullPath!, albumName: "微北洋");
      ToastProvider.success("图片保存成功");
    }).onError((error, stackTrace) {
      ToastProvider.error("图片保存失败");
    });
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color)),
    );
  }
}
