import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      .copyWith(color: WpyTheme.of(context).get(WpyColorKey.reverseTextColor));

  TextStyle secondary(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyColorKey.secondaryTextColor));

  TextStyle label(context) => this
      .copyWith(color: WpyTheme.of(context).get(WpyColorKey.labelTextColor));

  TextStyle unlabeled(context) => this
      .copyWith(color: WpyTheme.of(context).get(WpyColorKey.unlabeledColor));

  TextStyle textButtonPrimary(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyColorKey.primaryTextButtonColor));

  TextStyle oldActionColor(context) => this
      .copyWith(color: WpyTheme.of(context).get(WpyColorKey.oldActionColor));

  TextStyle oldSecondaryAction(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyColorKey.oldSecondaryActionColor));

  TextStyle oldThirdAction(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyColorKey.oldThirdActionColor));

  TextStyle oldFurthAction(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyColorKey.oldFurthActionColor));

  TextStyle link(context) =>
      this.copyWith(color: WpyTheme.of(context).get(WpyColorKey.linkBlue));

  TextStyle infoText(context) =>
      this.copyWith(color: WpyTheme.of(context).get(WpyColorKey.infoTextColor));

  TextStyle oldHint(context) =>
      this.copyWith(color: WpyTheme.of(context).get(WpyColorKey.oldHintColor));

  TextStyle oldHintDarker(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyColorKey.oldHintDarkerColor));

  TextStyle favorRoomColor(context) => this
      .copyWith(color: WpyTheme.of(context).get(WpyColorKey.favorRoomColor));

  //--------- unformatted --------

  TextStyle examRemain(context) =>
      this.copyWith(color: WpyTheme.of(context).get(WpyColorKey.examRemain));

  TextStyle dangerousRed(context) =>
      this.copyWith(color: WpyTheme.of(context).get(WpyColorKey.dangerousRed));

  TextStyle biliPink(context) =>
      this.copyWith(color: WpyTheme.of(context).get(WpyColorKey.biliTextPink));

  TextStyle replySuffix(context) => this
      .copyWith(color: WpyTheme.of(context).get(WpyColorKey.replySuffixColor));

  TextStyle get whiteO60 => this.copyWith(color: Colors.white.withOpacity(0.6));

  TextStyle secondaryInfo(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyColorKey.secondaryInfoTextColor));

  TextStyle primary(context) => this.copyWith(
        color: WpyTheme.of(context).get(WpyColorKey.basicTextColor),
      );

  TextStyle bright(context) => this.copyWith(
        color: WpyTheme.of(context).get(WpyColorKey.brightTextColor),
      );

  TextStyle courseGradientStop(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyColorKey.courseGradientStopColor));

  TextStyle roomFree(context) =>
      this.copyWith(color: WpyTheme.of(context).get(WpyColorKey.roomFreeColor));

  TextStyle roomOccupied(context) => this
      .copyWith(color: WpyTheme.of(context).get(WpyColorKey.roomOccupiedColor));

  TextStyle infoColor(context) => this
      .copyWith(color: WpyTheme.of(context).get(WpyColorKey.infoStatusColor));

  TextStyle blue52hz(context) =>
      this.copyWith(color: WpyTheme.of(context).get(WpyColorKey.blue52hz));

  TextStyle get blue89 => this.copyWith(color: const Color(0xFF5189DC));

  TextStyle oldListAction(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyColorKey.oldListActionColor));

  TextStyle oldHintDarkest(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyColorKey.oldHintDarkestColor));

  TextStyle oldListGroupTitle(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyColorKey.oldListGroupTitleColor));

  TextStyle gpaHintColor(context) =>
      this.copyWith(color: WpyTheme.of(context).get(WpyColorKey.gpaHintColor));

  TextStyle mainTextColor(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyColorKey.defaultActionColor));

  TextStyle primaryAction(context) => this.copyWith(
      color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor));

  TextStyle get transParent => this.copyWith(color: Colors.transparent);

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
