import 'dart:io';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplitUtil {
  static bool needHorizontalView = 1.sw > 1.sh;

  SplitUtil._();

  static late double w = needHorizontalView ? 0.5.w : 1.w;
  static late double h = 1.h;
  static late double r = 1.r;
  static late double sw = needHorizontalView ? 0.5.sw : 1.sw;
  static late double sh = 1.sh;
  static late double toolbarWidth = Platform.isWindows ? needHorizontalView ? 25 : 50 : 0;
}
