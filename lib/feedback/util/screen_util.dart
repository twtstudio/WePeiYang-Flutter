import 'dart:ui';

import 'package:flutter/material.dart';

class ScreenUtil {
  static ScreenUtil instance = ScreenUtil();
  static MediaQueryData mediaQueryData = MediaQueryData.fromWindow(window);
  static double screenWidth = mediaQueryData.size.width;
  static double screenHeight = mediaQueryData.size.height;
  static double paddingBottom = mediaQueryData.padding.bottom;
  static double paddingTop = mediaQueryData.padding.top;
}
