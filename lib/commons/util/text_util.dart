import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextUtil {
  static TextStyle base;

  static init(BuildContext context) {
    base = Theme.of(context).textTheme.bodyText2;
  }
}

extension TextStyleAttr on TextStyle {
  /// 粗细
  TextStyle get w100 => this.copyWith(fontWeight: FontWeight.w100); // Thin, the least thick
  TextStyle get w200 => this.copyWith(fontWeight: FontWeight.w200); // Extra-light
  TextStyle get w300 => this.copyWith(fontWeight: FontWeight.w300); // Light
  TextStyle get w400 => this.copyWith(fontWeight: FontWeight.w400); // Normal / regular / plain
  TextStyle get w500 => this.copyWith(fontWeight: FontWeight.w500); // Medium
  TextStyle get w600 => this.copyWith(fontWeight: FontWeight.w600); // Semi-bold
  TextStyle get w700 => this.copyWith(fontWeight: FontWeight.w700); // Bold
  TextStyle get w800 => this.copyWith(fontWeight: FontWeight.w800); // Extra-bold
  TextStyle get w900 => this.copyWith(fontWeight: FontWeight.w900); // Black, the most thick
  TextStyle get regular => w400;
  TextStyle get normal => w400;
  TextStyle get medium => w500;
  TextStyle get bold => w700;

  /// 颜色
  TextStyle customColor(Color c) => this.copyWith(color: c);
  TextStyle get white => this.copyWith(color: Colors.white);
  TextStyle get whiteFD => this.copyWith(color: const Color(0xFFFDFDFE));
  TextStyle get mainOrange => this.copyWith(color: const Color(0xFFFF6F48));
  TextStyle get dangerousRed => this.copyWith(color: const Color(0xFFFF0000));
  TextStyle get textButtonBlue => this.copyWith(color: const Color(0xFF2D4E9A));
  TextStyle get begoniaPink => this.copyWith(color: const Color(0xFFF3C9D9));
  TextStyle get biliPink => this.copyWith(color: const Color(0xFFF97198));
  TextStyle get linkBlue => this.copyWith(color: const Color(0xFF302280));
  TextStyle get mainYellow => this.copyWith(color: const Color(0xFFFABC35));
  TextStyle get mainGrey => this.copyWith(color: const Color(0xFFB6B2AF));
  TextStyle get mainPurple => this.copyWith(color: const Color(0xFF6A63E1));
  TextStyle get greyEB => this.copyWith(color: const Color(0xFFEBEBEB));
  TextStyle get greyAA => this.copyWith(color: const Color(0xFFAAAAAA));
  TextStyle get greyA8 => this.copyWith(color: const Color(0xFFA8A8A8));
  TextStyle get greyA6 => this.copyWith(color: const Color(0xFFA6A6A6));
  TextStyle get greyB2 => this.copyWith(color: const Color(0xFFB2B6BB));
  TextStyle get grey97 => this.copyWith(color: const Color(0xFF979797));
  TextStyle get grey6C => this.copyWith(color: const Color(0xFF6C6C6C));
  TextStyle get blue363C => this.copyWith(color: const Color(0xFF363C54));
  TextStyle get black00 => this.copyWith(color: const Color(0xFF000000));
  TextStyle get black4E => this.copyWith(color: const Color(0xFF4E4E4E));
  TextStyle get black2A => this.copyWith(color: const Color(0xFF2A2A2A));
  TextStyle get green1B => this.copyWith(color: const Color(0xFF1B7457));
  TextStyle get yellowD9 => this.copyWith(color: const Color(0xFFD9621F));
  TextStyle get mainColor => this.copyWith(color: const Color.fromARGB(255, 54, 60, 84));

  /// 字体
  TextStyle get NotoSansSC => this.copyWith(fontFamily: 'NotoSansSC');
  TextStyle get ProductSans => this.copyWith(fontFamily: 'ProductSans');

  /// 以下为非枚举属性
  TextStyle sp(double s) => this.copyWith(fontSize: s.sp);

  TextStyle h(double h) => this.copyWith(height: h);

  TextStyle space({double wordSpacing, double letterSpacing}) =>
      this.copyWith(wordSpacing: wordSpacing, letterSpacing: letterSpacing);
}