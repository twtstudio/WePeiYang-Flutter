import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';

class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = WpyTheme.of(context);
    final background = theme.get(WpyColorKey.secondaryBackgroundColor);
    final overlay = theme.brightness.uiOverlay.copyWith(
      systemNavigationBarColor: background,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: Text(
            title,
            style: TextUtil.base.bold.sp(16).oldActionColor(context),
          ),
          centerTitle: true,
          foregroundColor: theme.get(WpyColorKey.oldActionColor),
          backgroundColor: theme.get(WpyColorKey.primaryBackgroundColor),
          surfaceTintColor: Colors.transparent,
          elevation: 1,
          scrolledUnderElevation: 1,
          shadowColor: Colors.black26,
          systemOverlayStyle: overlay,
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            children: children,
          ),
        ),
      ),
    );
  }
}

class AppSettingsSection extends StatelessWidget {
  const AppSettingsSection({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = WpyTheme.of(context);
    final headingColor = theme.get(
      theme.brightness == Brightness.dark
          ? WpyColorKey.oldHintDarkestColor
          : WpyColorKey.oldListGroupTitleColor,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title case final label?)
          Padding(
            padding: EdgeInsets.only(left: 1.w, bottom: 10.h),
            child: Semantics(
              header: true,
              child: Text(
                label,
                style: TextUtil.base.bold.sp(13).copyWith(color: headingColor),
              ),
            ),
          ),
        Material(
          color: theme.get(WpyColorKey.primaryBackgroundColor),
          borderRadius: BorderRadius.circular(10.r),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.get(WpyColorKey.secondaryBackgroundColor),
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

TextStyle _subtitleStyle(BuildContext context) =>
    TextUtil.base.regular.sp(13).oldHintDarkest(context);

class AppSettingsRow extends StatelessWidget {
  const AppSettingsRow({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 77.h),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextUtil.base.w600.sp(15).oldThirdAction(context),
                    ),
                    if (subtitle case final text?) ...[
                      SizedBox(height: 3.h),
                      Text(text, style: _subtitleStyle(context)),
                    ],
                  ],
                ),
              ),
              if (trailing case final accessory?) ...[
                SizedBox(width: 10.w),
                accessory,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppSettingsLink extends StatelessWidget {
  const AppSettingsLink({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppSettingsRow(
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value case final text?) ...[
            Text(text, style: _subtitleStyle(context)),
            SizedBox(width: 12.w),
          ],
          Icon(
            Icons.chevron_right,
            color: WpyTheme.of(context).get(WpyColorKey.oldListActionColor),
            size: 17.w,
          ),
        ],
      ),
    );
  }
}

class AppSettingsToggle extends StatelessWidget {
  const AppSettingsToggle({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = WpyTheme.of(context);
    return MergeSemantics(
      child: AppSettingsRow(
        title: title,
        subtitle: subtitle,
        trailing: SwitchTheme(
          data: SwitchThemeData(
            trackOutlineColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? Colors.transparent
                  : theme.get(WpyColorKey.oldHintColor),
            ),
          ),
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: theme.get(WpyColorKey.primaryBackgroundColor),
            activeTrackColor: theme.primary,
            inactiveThumbColor: theme.get(WpyColorKey.oldHintColor),
            inactiveTrackColor: theme.get(WpyColorKey.oldSwitchBarColor),
          ),
        ),
      ),
    );
  }
}
