import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../themes/color_util.dart';

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

  TextStyle get reverse => this.copyWith(color: ColorUtil.reverseTextColor);

  TextStyle get secondary => this.copyWith(color: ColorUtil.secondaryTextColor);

  TextStyle get label => this.copyWith(color: ColorUtil.labelTextColor);

  TextStyle get textButtonPrimary =>
      this.copyWith(color: ColorUtil.primaryTextButtonColor);

  TextStyle get oldActionColor =>
      this.copyWith(color: ColorUtil.oldActionColor);

  TextStyle get oldSecondaryAction =>
      this.copyWith(color: ColorUtil.oldSecondaryActionColor);

  TextStyle get oldThirdAction =>
      this.copyWith(color: ColorUtil.oldThirdActionColor);

  TextStyle get oldFurthAction =>
      this.copyWith(color: ColorUtil.oldFurthActionColor);

  TextStyle get linkBlue => this.copyWith(color: ColorUtil.linkBlue);

  TextStyle get infoText => this.copyWith(color: ColorUtil.infoTextColor);

  TextStyle get oldHintWhite => this.copyWith(color: ColorUtil.oldHintColor);

  TextStyle get oldHintDarker =>
      this.copyWith(color: ColorUtil.oldHintDarkerColor);

  //--------- unformatted --------

  TextStyle get grey90 => this.copyWith(color: ColorUtil.grey90);

  TextStyle get white38 => this.copyWith(color: ColorUtil.white38);

  TextStyle get dangerousRed => this.copyWith(color: ColorUtil.dangerousRed);

  TextStyle get biliPink => this.copyWith(color: ColorUtil.biliTextPink);

  TextStyle get greyHot => this.copyWith(color: ColorUtil.greyHotColor);

  TextStyle get greyEB => this.copyWith(color: ColorUtil.whiteEBColor);

  TextStyle get greyAA => this.copyWith(color: ColorUtil.greyAA);

  TextStyle get greyA8 => this.copyWith(color: ColorUtil.greyA8);

  TextStyle get greyA6 => this.copyWith(color: ColorUtil.greyA6);

  TextStyle get whiteO60 => this.copyWith(color: Colors.white.withOpacity(0.6));

  TextStyle get secondaryInfo =>
      this.copyWith(color: ColorUtil.secondaryInfoTextColor);

  TextStyle get grey6C => this.copyWith(color: ColorUtil.grey6C);

  TextStyle get greyC8 => this.copyWith(color: ColorUtil.greyC8);

  TextStyle get blue303C => this.copyWith(color: ColorUtil.blue303C);

  TextStyle get blue363C => this.copyWith(color: ColorUtil.blue363C);

  TextStyle get primary => this.copyWith(color: ColorUtil.basicTextColor);

  TextStyle get black42 => this.copyWith(color: ColorUtil.black42);

  TextStyle get grey126 => this.copyWith(color: ColorUtil.grey126);

  TextStyle get green5C => this.copyWith(color: ColorUtil.green5CColor);

  TextStyle get redD9 => this.copyWith(color: ColorUtil.redD9);

  TextStyle get orange6B => this.copyWith(color: ColorUtil.orange6B);

  TextStyle get yellowF0 => this.copyWith(color: ColorUtil.yellowF0);

  TextStyle get grey89 => this.copyWith(color: ColorUtil.grey89);

  TextStyle get blue52hz => this.copyWith(color: ColorUtil.blue52hz);

  TextStyle get blue89 => this.copyWith(color: const Color(0xFF5189DC));

  TextStyle get grey => this.copyWith(color: ColorUtil.oldListActionColor);

  TextStyle get whiteb1b2 => this.copyWith(color: ColorUtil.whiteb1b2Color);

  TextStyle get white222 => this.copyWith(color: ColorUtil.white222);

  TextStyle get grey6267 => this.copyWith(color: ColorUtil.grey6267Color);

  TextStyle get blue98Opacity061 =>
      this.copyWith(color: ColorUtil.blue98Opacity061);

  TextStyle get oldListGroupTitle =>
      this.copyWith(color: ColorUtil.oldListGroupTitleColor);

  TextStyle get whiteCD => this.copyWith(color: ColorUtil.whiteCDColor);

  TextStyle get grey145 => this.copyWith(color: ColorUtil.grey145);

  TextStyle get grey4146 => this.copyWith(color: ColorUtil.grey4146Color);

  TextStyle get mainTextColor =>
      this.copyWith(color: ColorUtil.defaultActionColor);

  TextStyle get primaryAction =>
      this.copyWith(color: ColorUtil.primaryActionColor);

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
