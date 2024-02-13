import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';

class ThemeSetting extends StatelessWidget {
  const ThemeSetting({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
        ),
        children: [
          for (final theme in WpyThemeData.themeList)
            GestureDetector(
              onTap: () {
                globalTheme.value = theme;
                CommonPreferences.appThemeId.value = theme.meta.themeId;
              },
              child: WpyThemeCard(
                name: theme.meta.name,
                primaryColor: theme.meta.representativeColor,
                hintTextColor: theme.meta.hintTextColor,
                selected: theme.meta.themeId ==
                    WpyTheme.of(context).themeData.meta.themeId,
              ),
            ),
        ],
      ),
    );
  }
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
      color: Colors.blueAccent,
      width: 6,
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(20);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: getBorder(context),
      ),
      elevation: 4,
      shadowColor: WpyTheme.of(context).get(WpyColorKey.basicTextColor),
      margin: EdgeInsets.all(20.w),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            color: primaryColor,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            decoration: BoxDecoration(
              color: WpyTheme.of(context)
                  .get(WpyColorKey.reverseBackgroundColor)
                  .withOpacity(0.3),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            height: 35.h,
            width: double.infinity,
            child: Text(
              name,
              style: TextStyle(
                color: hintTextColor,
                fontSize: 20.sp,
              ),
            ),
          ),
          if (selected)
            Center(
              child: Icon(
                Icons.check_circle,
                color: Colors.blueAccent,
                size: 40.w,
              ),
            )
        ],
      ),
    );
  }
}
