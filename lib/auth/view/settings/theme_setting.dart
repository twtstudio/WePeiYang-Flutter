import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/colored_icon.dart';
import 'package:we_pei_yang_flutter/commons/widgets/schedule_background.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/home/view/map_calendar_page.dart';

import '../../../commons/util/toast_provider.dart';

class ThemeSetting extends StatefulWidget {
  const ThemeSetting({super.key});

  @override
  State<ThemeSetting> createState() => _ThemeSettingState();
}

class _ThemeSettingState extends State<ThemeSetting>
    with SingleTickerProviderStateMixin {
  static const _channel = MethodChannel('icon_switch');
  static final _appIconThemes = WpyThemeData.brightThemeList;

  late AnimationController _animController;
  late Animation<double> _clipAnim;

  bool get _canSwitchAppIcon => defaultTargetPlatform == TargetPlatform.android;

  static Future<void> switchIcon(String alias) async {
    await _channel.invokeMethod('switchIcon', {
      "target": alias,
    });
  }

  static Future<String?> getCurrentIcon() async {
    return _channel.invokeMethod<String>('getCurrentIcon');
  }

  static Future<void> restartApp() async {
    await _channel.invokeMethod('restartApp');
  }

  Future<void> _selectAppIcon(WpyThemeData theme) async {
    if (!_canSwitchAppIcon) return;

    final alias = theme.meta.address;
    if (alias == CommonPreferences.appIconAlias.value) return;

    await _showRestartDialog(alias);
  }

  Future<void> _loadCurrentAppIcon() async {
    if (!_canSwitchAppIcon) return;

    try {
      final alias = await getCurrentIcon();
      if (!mounted || alias == null || alias.isEmpty) return;
      setState(() => CommonPreferences.appIconAlias.value = alias);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _showRestartDialog(String alias) async {
    await showDialog(
      context: context,
      builder: (context) {
        return LakeDialogWidget(
          title: '重启应用',
          titleTextStyle:
              TextUtil.base.normal.infoText(context).NotoSansSC.sp(22).w600,
          content: Text(
            '应用图标需要重启后才会完成切换，是否现在重启？',
            style: TextStyle(
              color: WpyTheme.of(context).get(WpyColorKey.basicTextColor),
            ),
          ),
          cancelText: '稍后',
          cancelTextStyle:
              TextUtil.base.normal.label(context).NotoSansSC.sp(16).w400,
          cancelFun: () => Navigator.pop(context),
          confirmText: '立即重启',
          confirmTextStyle:
              TextUtil.base.normal.bright(context).NotoSansSC.sp(16).w600,
          confirmButtonColor:
              WpyTheme.of(context).get(WpyColorKey.primaryTextButtonColor),
          confirmFun: () async {
            try {
              await switchIcon(alias);
              CommonPreferences.appIconAlias.value = alias;
              await restartApp();
            } catch (e) {
              if (context.mounted) Navigator.pop(context);
              ToastProvider.error('请手动重启应用');
              print(e);
            }
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentAppIcon();

    _animController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    double initialValue;
    if (CommonPreferences.autoDarkTheme.value) {
      initialValue = 0.5;
    } else if (globalTheme.value.meta.brightness == Brightness.light) {
      initialValue = 1.0;
    } else {
      initialValue = 0.0;
    }
    _animController.value = initialValue;
    _clipAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _applyBrightness(Brightness brightness) {
    CommonPreferences.autoDarkTheme.value = false;
    WpyTheme.applyStoredTheme(brightness: brightness);
    _animController.animateTo(brightness == Brightness.light ? 1.0 : 0.0);
    setState(() {});
  }

  void _applyAutoMode() {
    CommonPreferences.autoDarkTheme.value = true;
    final brightness = MediaQuery.platformBrightnessOf(context);
    WpyTheme.applyStoredTheme(brightness: brightness);
    _animController.animateTo(0.5);
    setState(() {});
  }

  void _selectLightTheme(WpyThemeData theme) {
    CommonPreferences.appThemeId.value = theme.meta.themeId;
    if (globalTheme.value.meta.brightness == Brightness.light) {
      globalTheme.value = theme;
    }
    setState(() {});
  }

  void _selectDarkTheme(WpyThemeData theme) {
    CommonPreferences.appDarkThemeId.value = theme.meta.themeId;
    if (globalTheme.value.meta.brightness == Brightness.dark) {
      globalTheme.value = theme;
    }
    setState(() {});
  }

  Widget _buildPreviewSection(BuildContext context) {
    final lightTheme = WpyThemeData.themeList.firstWhere(
      (e) => e.meta.themeId == CommonPreferences.appThemeId.value &&
          e.meta.brightness == Brightness.light,
      orElse: () => WpyThemeData.brightThemeList[0],
    );
    final darkTheme = WpyThemeData.themeList.firstWhere(
      (e) => e.meta.themeId == CommonPreferences.appDarkThemeId.value &&
          e.meta.brightness == Brightness.dark,
      orElse: () => WpyThemeData.darkThemeList[0],
    );

    Widget exampleCard(String iconAsset, BuildContext ctx) => AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 150.w,
          height: 80.h,
          margin: EdgeInsets.fromLTRB(18.h, 2.h, 0, 0),
          decoration: MapAndCalenderState().cardDecoration(ctx),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 12.w),
              Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.2,
                    child: Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: WpyTheme.of(ctx)
                            .get(WpyColorKey.beanLightColor),
                      ),
                    ),
                  ),
                  ColoredIcon(
                    iconAsset,
                    width: 21.w,
                    color: WpyTheme.of(ctx).primary,
                  ),
                ],
              ),
              SizedBox(width: 14.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 10.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      color: WpyTheme.of(ctx)
                          .get(WpyColorKey.labelTextColor),
                      borderRadius:
                          BorderRadius.all(Radius.circular(30.w)),
                    ),
                  ),
                  SizedBox(height: 4.5.h),
                  Container(
                    height: 6.h,
                    width: 50.w,
                    decoration: BoxDecoration(
                      color: WpyTheme.of(ctx)
                          .get(WpyColorKey.unlabeledColor),
                      borderRadius:
                          BorderRadius.all(Radius.circular(30.w)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

    Widget exampleCard2(String iconAsset, BuildContext ctx) => AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 150.w,
          height: 80.h,
          margin: EdgeInsets.fromLTRB(18.h, 2.h, 0, 0),
          decoration: MapAndCalenderState().cardDecoration(ctx),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 12.w),
              Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.2,
                    child: Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: WpyTheme.of(ctx)
                            .get(WpyColorKey.beanLightColor),
                      ),
                    ),
                  ),
                  ColoredIcon(
                    iconAsset,
                    width: 21.w,
                    color: WpyTheme.of(ctx).primary,
                  ),
                ],
              ),
              SizedBox(width: 14.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 10.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      color: WpyTheme.of(ctx)
                          .get(WpyColorKey.labelTextColor),
                      borderRadius:
                          BorderRadius.all(Radius.circular(30.w)),
                    ),
                  ),
                  SizedBox(height: 4.5.h),
                  Container(
                    height: 6.h,
                    width: 50.w,
                    decoration: BoxDecoration(
                      color: WpyTheme.of(ctx)
                          .get(WpyColorKey.unlabeledColor),
                      borderRadius:
                          BorderRadius.all(Radius.circular(30.w)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

    String greeting = 'HELLO';
    if (CommonPreferences.lakeNickname.value.isNotEmpty) {
      greeting += ', ${CommonPreferences.lakeNickname.value}';
    }

    Widget buildLayout(WpyThemeData theme) {
      final isLight = theme.meta.brightness == Brightness.light;
      final watermarkText = theme.meta.name;
      return WpyTheme(
        themeData: theme,
        child: Builder(
          builder: (ctx) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: isLight ? 0.9 : 0.5,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      color: theme.meta.representativeColor,
                    ),
                  ),
                ),
                Positioned.fill(
                  top: 30.h,
                  child: IgnorePointer(child: ScheduleBackground()),
                ),
                Positioned(
                  left: isLight ? 10 : null,
                  right: isLight ? null : 10,
                  top: -10.h,
                  child: Text(
                      watermarkText,
                      overflow: TextOverflow.clip,
                      textAlign: isLight ? TextAlign.left : TextAlign.right,
                      style: TextUtil.base.w900
                          .sp(35)
                          .copyWith(color: Colors.white30),
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 30.h),
                      Container(
                        margin: EdgeInsets.only(
                            left: 30.w, top: 5.h, bottom: 10.h),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          greeting,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextUtil.base.bright(ctx).w400.sp(22),
                        ),
                      ),
                      Expanded(
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.fromLTRB(0, 2.h, 0, 10.h),
                          decoration: BoxDecoration(
                            color: WpyTheme.of(ctx).get(
                                WpyColorKey.primaryBackgroundColor),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40.r),
                              topRight: Radius.circular(40.r),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              exampleCard(
                                  "assets/svg_pics/lake_butt_icons/daily.png",
                                  ctx),
                              exampleCard2(
                                  "assets/svg_pics/lake_butt_icons/lost_and_found.png",
                                  ctx),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return AnimatedBuilder(
      animation: _clipAnim,
      builder: (context, child) {
        final clipValue = _clipAnim.value;
        return Container(
          height: 0.45.sw,
          margin: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Stack(
              children: [
                Positioned.fill(child: buildLayout(darkTheme)),
                Positioned.fill(
                  child: ClipPath(
                    clipper: _AnimatedVerticalClipper(clipValue: clipValue),
                    child: buildLayout(lightTheme),
                  ),
                ),
                if (clipValue > 0.01 && clipValue < 0.99)
                  CustomPaint(
                    size: Size.infinite,
                    painter: _AnimatedVerticalLinePainter(
                      clipValue: clipValue,
                      dividerColor: Colors.white30,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget previewSection = _buildPreviewSection(context);

    Widget modeSelect = Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      margin: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
      decoration: BoxDecoration(
        color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('外观模式', style: TextUtil.base.w600.sp(15).copyWith(
              color: WpyTheme.of(context).get(WpyColorKey.labelTextColor))),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ThemeModeButton(
                  title: '浅色',
                  icon: Icons.light_mode,
                  selected: !CommonPreferences.autoDarkTheme.value &&
                      globalTheme.value.meta.brightness == Brightness.light,
                  onTap: () => _applyBrightness(Brightness.light),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ThemeModeButton(
                  title: '深色',
                  icon: Icons.dark_mode,
                  selected: !CommonPreferences.autoDarkTheme.value &&
                      globalTheme.value.meta.brightness == Brightness.dark,
                  onTap: () => _applyBrightness(Brightness.dark),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ThemeModeButton(
                  title: '跟随系统',
                  icon: Icons.brightness_auto,
                  selected: CommonPreferences.autoDarkTheme.value,
                  onTap: _applyAutoMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    Widget lightThemeGrid = ThemeSection(
      title: '浅色主题',
      children: [
        for (final theme in WpyThemeData.brightThemeList)
          GestureDetector(
            onTap: () => _selectLightTheme(theme),
            child: WpyThemeCard(
              name: theme.meta.name,
              primaryColor: theme.meta.representativeColor,
              hintTextColor: theme.meta.hintTextColor,
              selected:
                  theme.meta.themeId == CommonPreferences.appThemeId.value,
            ),
          ),
      ],
    );

    Widget darkThemeGrid = ThemeSection(
      title: '深色主题',
      children: [
        for (final theme in WpyThemeData.darkThemeList)
          GestureDetector(
            onTap: () => _selectDarkTheme(theme),
            child: WpyThemeCard(
              name: theme.meta.name,
              primaryColor: theme.meta.representativeColor,
              hintTextColor: theme.meta.hintTextColor,
              selected:
                  theme.meta.themeId == CommonPreferences.appDarkThemeId.value,
            ),
          ),
      ],
    );

    Widget appIconSelect = Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 16.h),
      margin: EdgeInsets.only(top: 3.h),
      decoration: BoxDecoration(
        color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '应用图标',
            style: TextUtil.base.w600.sp(15).copyWith(
                color: WpyTheme.of(context).get(WpyColorKey.labelTextColor)),
          ),
          SizedBox(height: 3.h),
          Text(
            '切换后请稍等片刻',
            style: TextUtil.base.sp(12).copyWith(
                color: WpyTheme.of(context).get(WpyColorKey.oldHintColor)),
          ),
          SizedBox(height: 12.h),
          GridView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.78,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 12.h,
            ),
            children: [
              for (final theme in _appIconThemes)
                GestureDetector(
                  onTap: () => _selectAppIcon(theme),
                  child: AppIconChoiceCard(
                    name: theme.meta.name,
                    assetPath: _appIconAssetPath(theme.meta.address),
                    selected: CommonPreferences.appIconAlias.value ==
                        theme.meta.address,
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    return Scaffold(
        appBar: AppBar(
          title: Text("主题设置",
              style: TextUtil.base.bold.sp(16).oldActionColor(context)),
          elevation: 0,
          centerTitle: true,
          backgroundColor:
              WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          leading: Padding(
            padding: EdgeInsets.only(left: 15.w),
            child: WButton(
              child: Icon(Icons.arrow_back,
                  color: WpyTheme.of(context).get(WpyColorKey.oldActionColor),
                  size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
        body: Column(
          children: [
            previewSection,
            modeSelect,
            Expanded(
              child: ListView(
                children: [
                  AnimatedSize(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: (CommonPreferences.autoDarkTheme.value ||
                            globalTheme.value.meta.brightness ==
                                Brightness.light)
                        ? lightThemeGrid
                        : SizedBox.shrink(),
                  ),
                  AnimatedSize(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: (CommonPreferences.autoDarkTheme.value ||
                            globalTheme.value.meta.brightness ==
                                Brightness.dark)
                        ? darkThemeGrid
                        : SizedBox.shrink(),
                  ),
                  if (_canSwitchAppIcon) appIconSelect,
                ],
              ),
            ),
          ],
        ));
  }
}

class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final action = WpyTheme.of(context).get(WpyColorKey.primaryActionColor);
    final background =
        WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor);
    return WButton(
      onPressed: onTap,
        child: Container(
          height: 40.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: selected
                  ? action
                  : WpyTheme.of(context).get(WpyColorKey.lightBorderColor),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16.r,
                color: selected
                    ? action
                    : WpyTheme.of(context).get(WpyColorKey.secondaryTextColor),
              ),
              SizedBox(width: 4.w),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              style: TextUtil.base.sp(12).copyWith(
                    color: selected
                        ? action
                        : WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeSection extends StatelessWidget {
  const ThemeSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
      margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
      decoration: BoxDecoration(
        color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextUtil.base.w600.sp(15).copyWith(
              color: WpyTheme.of(context).get(WpyColorKey.labelTextColor))),
          SizedBox(height: 12.h),
          GridView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.5,
              crossAxisSpacing: 6.w,
              mainAxisSpacing: 6.h,
            ),
            children: children,
          ),
        ],
      ),
    );
  }
}

class AppIconChoiceCard extends StatelessWidget {
  const AppIconChoiceCard({
    super.key,
    required this.name,
    required this.assetPath,
    this.selected = false,
  });

  final String name;
  final String assetPath;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? WpyTheme.of(context).get(WpyColorKey.oldSecondaryActionColor)
        : WpyTheme.of(context).get(WpyColorKey.oldHintColor).withOpacity(0.25);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: borderColor, width: selected ? 2 : 1),
      ),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Image.asset(
                    assetPath,
                    width: 42.w,
                    height: 42.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              if (selected)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(
                    Icons.check_circle,
                    color: WpyTheme.of(context).get(WpyColorKey.oldActionColor),
                    size: 16.w,
                  ),
                ),
            ],
          ),
          SizedBox(height: 7.h),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextUtil.base.sp(12).copyWith(
                color: WpyTheme.of(context).get(WpyColorKey.labelTextColor)),
          ),
        ],
      ),
    );
  }
}

String _appIconAssetPath(String alias) {
  return switch (alias) {
    'com.twt.service.ICONCyan' =>
      'assets/images/app_icons/ic_launcher_cyan.png',
    'com.twt.service.ICONGold' =>
      'assets/images/app_icons/ic_launcher_gold.png',
    'com.twt.service.ICONPink' =>
      'assets/images/app_icons/ic_launcher_pink.png',
    'com.twt.service.ICONPurple' =>
      'assets/images/app_icons/ic_launcher_purple.png',
    'com.twt.service.ICONRed' => 'assets/images/app_icons/ic_launcher_red.png',
    'com.twt.service.ICONYellow' =>
      'assets/images/app_icons/ic_launcher_yellow.png',
    'com.twt.service.ICONSpring' =>
      'assets/images/app_icons/ic_launcher_spring.png',
    _ => 'assets/images/app_icons/ic_launcher.png',
  };
}

class _AnimatedVerticalClipper extends CustomClipper<Path> {
  final double clipValue;

  const _AnimatedVerticalClipper({required this.clipValue});

  @override
  Path getClip(Size size) {
    final path = Path();
    final x = size.width * clipValue;
    path.moveTo(0, 0);
    path.lineTo(x, 0);
    path.lineTo(x, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _AnimatedVerticalClipper oldClipper) =>
      oldClipper.clipValue != clipValue;
}

class _AnimatedVerticalLinePainter extends CustomPainter {
  final double clipValue;
  final Color dividerColor;

  const _AnimatedVerticalLinePainter({
    required this.clipValue,
    required this.dividerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dividerColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final x = size.width * clipValue;
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _AnimatedVerticalLinePainter oldDelegate) =>
      oldDelegate.clipValue != clipValue;
}

class WpyThemeCard extends StatelessWidget {
  WpyThemeCard({
    super.key,
    required this.name,
    required this.primaryColor,
    required this.hintTextColor,
    this.selected = false,
  });

  final String name;
  final Color primaryColor;
  final Color hintTextColor;
  final bool selected;

  BorderSide getBorder(context) {
    if (!selected) return BorderSide.none;

    return BorderSide(
      color: hintTextColor,
      width: 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(10.w);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: getBorder(context),
      ),
      elevation: 0,
      shadowColor: WpyTheme.of(context).get(WpyColorKey.basicTextColor),
      margin: EdgeInsets.all(5.w),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            color: primaryColor,
            width: double.infinity,
            height: double.infinity,
          ),
          Column(
            children: [
              Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.reverseBackgroundColor)
                      .withOpacity(0.3),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                alignment: Alignment.centerLeft,
                width: double.infinity,
                child: Text(
                  name,
                  style: TextStyle(
                    color: hintTextColor,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          if (selected)
            Center(
              child: Icon(
                Icons.check_circle,
                color: hintTextColor,
                size: 30.w,
              ),
            )
        ],
      ),
    );
  }
}
