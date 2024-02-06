import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../themes/color_util.dart';
import '../themes/template/wpy_theme_data.dart';
import '../themes/wpy_theme.dart';

class TextUtil {
  TextUtil._();

  static late TextStyle base;

  static init(BuildContext context) {
    base = Theme.of(context).textTheme.bodyMedium ?? TextStyle();
    base = base.Swis;
  }
}

extension TextStyleAttr on TextStyle {
  /// 粗细
  TextStyle get w100 =>
      this.copyWith(fontWeight: FontWeight.w100); // Thin, the least thick
  TextStyle get w200 =>
      this.copyWith(fontWeight: FontWeight.w200); // Extra-light
  TextStyle get w300 => this.copyWith(fontWeight: FontWeight.w300); // Light
  TextStyle get w400 =>
      this.copyWith(fontWeight: FontWeight.w400); // Normal / regular / plain
  TextStyle get w500 => this.copyWith(fontWeight: FontWeight.w500); // Medium
  TextStyle get w600 => this.copyWith(fontWeight: FontWeight.w600); // Semi-bold
  TextStyle get w700 => this.copyWith(fontWeight: FontWeight.w700); // Bold
  TextStyle get w800 =>
      this.copyWith(fontWeight: FontWeight.w800); // Extra-bold
  TextStyle get w900 =>
      this.copyWith(fontWeight: FontWeight.w900); // Black, the most thick
  TextStyle get regular => w400;

  TextStyle get normal => w400;

  TextStyle get medium => w500;

  TextStyle get bold => w700;

  /// 颜色
  TextStyle customColor(Color c) => this.copyWith(color: c);

  TextStyle reverse(context) => this
      .copyWith(color: WpyTheme.of(context).get(WpyThemeKeys.reverseTextColor));

  TextStyle secondary(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyThemeKeys.secondaryTextColor));

  TextStyle label(context) => this
      .copyWith(color: WpyTheme.of(context).get(WpyThemeKeys.labelTextColor));

  TextStyle unlabeled(context) => this
      .copyWith(color: WpyTheme.of(context).get(WpyThemeKeys.unlabeledColor));

  TextStyle textButtonPrimary(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyThemeKeys.primaryTextButtonColor));

  TextStyle oldActionColor(context) => this
      .copyWith(color: WpyTheme.of(context).get(WpyThemeKeys.oldActionColor));

  TextStyle oldSecondaryAction(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyThemeKeys.oldSecondaryActionColor));

  TextStyle oldThirdAction(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyThemeKeys.oldThirdActionColor));

  TextStyle oldFurthAction(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyThemeKeys.oldFurthActionColor));

  TextStyle linkBlue(context) =>
      this.copyWith(color: WpyTheme.of(context).get(WpyThemeKeys.linkBlue));

  TextStyle infoText(context) => this
      .copyWith(color: WpyTheme.of(context).get(WpyThemeKeys.infoTextColor));

  TextStyle oldHintWhite(context) =>
      this.copyWith(color: WpyTheme.of(context).get(WpyThemeKeys.oldHintColor));

  TextStyle oldHintDarker(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyThemeKeys.oldHintDarkerColor));

  //--------- unformatted --------

  TextStyle get grey90 => this.copyWith(color: ColorUtil.grey90);

  TextStyle get examRemain => this.copyWith(color: ColorUtil.examRemain);

  TextStyle dangerousRed(context) =>
      this.copyWith(color: WpyTheme.of(context).get(WpyThemeKeys.dangerousRed));

  TextStyle get biliPink => this.copyWith(color: ColorUtil.biliTextPink);

  TextStyle get greyHot => this.copyWith(color: ColorUtil.greyHotColor);

  TextStyle get greyAA => this.copyWith(color: ColorUtil.greyAA);

  TextStyle get greyA8 => this.copyWith(color: ColorUtil.greyA8);

  TextStyle get whiteO60 => this.copyWith(color: Colors.white.withOpacity(0.6));

  TextStyle secondaryInfo(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyThemeKeys.secondaryInfoTextColor));

  TextStyle get greyC8 => this.copyWith(color: ColorUtil.greyC8);

  TextStyle get blue303C => this.copyWith(color: ColorUtil.blue303C);

  TextStyle get blue363C => this.copyWith(color: ColorUtil.blue363C);

  TextStyle primary(context) => this.copyWith(
        color: WpyTheme.of(context).get(WpyThemeKeys.basicTextColor),
      );

  TextStyle get black42 => this.copyWith(color: ColorUtil.black42);

  TextStyle get grey126 => this.copyWith(color: ColorUtil.grey126);

  TextStyle get green5C => this.copyWith(color: ColorUtil.green5CColor);

  TextStyle get redD9 => this.copyWith(color: ColorUtil.redD9);

  TextStyle get orange6B => this.copyWith(color: ColorUtil.orange6B);

  TextStyle infoColor(context) => this
      .copyWith(color: WpyTheme.of(context).get(WpyThemeKeys.infoStatusColor));

  TextStyle get grey89 => this.copyWith(color: ColorUtil.grey89);

  TextStyle get blue52hz => this.copyWith(color: ColorUtil.blue52hz);

  TextStyle get blue89 => this.copyWith(color: const Color(0xFF5189DC));

  TextStyle oldListAction(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyThemeKeys.oldListActionColor));

  TextStyle get whiteb1b2 => this.copyWith(color: ColorUtil.whiteb1b2Color);

  TextStyle get grey6267 => this.copyWith(color: ColorUtil.grey6267Color);

  TextStyle get blue98Opacity061 =>
      this.copyWith(color: ColorUtil.blue98Opacity061);

  TextStyle oldListGroupTitle(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyThemeKeys.oldListGroupTitleColor));

  TextStyle gpaHintColor(context) =>
      this.copyWith(color: ColorUtil.gpaHintColor);

  TextStyle get grey145 => this.copyWith(color: ColorUtil.grey145);

  TextStyle get grey4146 => this.copyWith(color: ColorUtil.grey4146Color);

  TextStyle mainTextColor(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyThemeKeys.defaultActionColor));

  TextStyle primaryAction(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyThemeKeys.primaryActionColor));

  TextStyle get transParent => this.copyWith(color: ColorUtil.transparent);

  /// 字体
  TextStyle get Swis => this.copyWith(fontFamily: 'Swis');

  TextStyle get NotoSansSC => this.copyWith(fontFamily: 'NotoSansSC');

  TextStyle get PingFangSC => this.copyWith(fontFamily: 'PingFangSC');

  TextStyle get ProductSans => this.copyWith(fontFamily: 'ProductSans');

  TextStyle get Fourche => this.copyWith(fontFamily: 'Fourche');

  /// 装饰
  TextStyle get lineThrough =>
      this.copyWith(decoration: TextDecoration.lineThrough);

  TextStyle get overLine => this.copyWith(decoration: TextDecoration.overline);

  TextStyle get underLine =>
      this.copyWith(decoration: TextDecoration.underline);

  TextStyle get noLine => this.copyWith(decoration: TextDecoration.none);

  TextStyle get italic => this.copyWith(fontStyle: FontStyle.italic);

  /// 以下为非枚举属性
  TextStyle sp(double s) => this.copyWith(fontSize: s.sp);

  TextStyle h(double h) => this.copyWith(height: h);

  TextStyle space({double? wordSpacing, double? letterSpacing}) =>
      this.copyWith(wordSpacing: wordSpacing, letterSpacing: letterSpacing);
}
