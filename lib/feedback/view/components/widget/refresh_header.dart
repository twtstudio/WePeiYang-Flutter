// @dart = 2.12
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/main.dart';

class RefreshHeader extends MaterialClassicHeader {
  @override
  double get offset => 2 * WePeiYangApp.screenHeight / 5;

  @override
  double get distance => 10.w;
}
