import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'color_util.dart';

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

  TextStyle get white => this.copyWith(color: ColorUtil.whiteFFColor);

  TextStyle get white38 => this.copyWith(color: ColorUtil.white38);

  TextStyle get whiteFD => this.copyWith(color: ColorUtil.whiteFDFE);

  TextStyle get dangerousRed => this.copyWith(color: ColorUtil.dangerousRed);

  TextStyle get textButtonBlue =>
      this.copyWith(color: ColorUtil.selectionButtonColor);

  TextStyle get biliPink => this.copyWith(color: ColorUtil.biliTextPink);

  TextStyle get linkBlue => this.copyWith(color: ColorUtil.linkBlue);

  TextStyle get greyEB => this.copyWith(color: ColorUtil.whiteEBColor);

  TextStyle get greyAA => this.copyWith(color: ColorUtil.greyAA);

  TextStyle get greyA8 => this.copyWith(color: ColorUtil.greyA8);

  TextStyle get greyA6 => this.copyWith(color: ColorUtil.greyA6);

  TextStyle get whiteO60 => this.copyWith(color: Colors.white.withOpacity(0.6));

  TextStyle get whiteFD => this.copyWith(color: const Color(0xFFFDFDFE));

  TextStyle get grey97 => this.copyWith(color: ColorUtil.grey97);

  TextStyle get grey6C => this.copyWith(color: ColorUtil.grey6C);

  TextStyle get greyC8 => this.copyWith(color: ColorUtil.greyC8);

  TextStyle get blue303C => this.copyWith(color: ColorUtil.blue303C);

  TextStyle get blue363C => this.copyWith(color: ColorUtil.blue363C);

  TextStyle get black00 => this.copyWith(color: ColorUtil.black00Color);

  TextStyle get black4E => this.copyWith(color: ColorUtil.black4E);

  TextStyle get grey126 => this.copyWith(color: ColorUtil.grey126);

  TextStyle get black2A => this.copyWith(color: ColorUtil.black2A);

  TextStyle get green5C => this.copyWith(color: ColorUtil.green5CColor);

  TextStyle get redD9 => this.copyWith(color: ColorUtil.redD9);

  TextStyle get orange6B => this.copyWith(color: ColorUtil.orange6B);

  TextStyle get yellowF0 => this.copyWith(color: ColorUtil.yellowF0);

  TextStyle get whiteHint201 => this.copyWith(color: ColorUtil.hintWhite201);

  TextStyle get whiteHint205 => this.copyWith(color: ColorUtil.hintWhite205);

  TextStyle get blue79 => this.copyWith(color: ColorUtil.blue79);

  TextStyle get blue48 => this.copyWith(color: ColorUtil.blue48);

  TextStyle get blue53 => this.copyWith(color: ColorUtil.blue53);

  TextStyle get grey89 => this.copyWith(color: const Color(0xFF898989));

  TextStyle get blue303C => this.copyWith(color: const Color(0xFF303C66));

  TextStyle get blue98 => this.copyWith(color: ColorUtil.blue98);

  TextStyle get blue98122 => this.copyWith(color: ColorUtil.blue98122);

  TextStyle get blue52hz => this.copyWith(color: ColorUtil.blue52hz);

  TextStyle get grey => this.copyWith(color: ColorUtil.grey);

  TextStyle get whiteb1b2 => this.copyWith(color: ColorUtil.whiteb1b2Color);

  TextStyle get white202 => this.copyWith(color: ColorUtil.white202);

  TextStyle get white222 => this.copyWith(color: ColorUtil.white222);

  TextStyle get grey6267 => this.copyWith(color: ColorUtil.grey6267Color);

  TextStyle get blue98Opacity061 => this.copyWith(color: ColorUtil.blue98Opacity061);

  TextStyle get grey177 => this.copyWith(color: ColorUtil.grey177);

  TextStyle get whiteCD => this.copyWith(color: ColorUtil.whiteCDColor);

  TextStyle get grey145 => this.copyWith(color: ColorUtil.grey145);

  TextStyle get grey4146 => this.copyWith(color: ColorUtil.grey4146Color);

  TextStyle get mainColor => this.copyWith(color: ColorUtil.mainColor);

  TextStyle get blue2C => this.copyWith(color: ColorUtil.blue2CColor);

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
