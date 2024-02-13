import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/main.dart';

class RefreshHeader extends MaterialClassicHeader {
  @override
  double get offset => 2 * WePeiYangApp.screenHeight / 5;

  @override
  double get distance => 10.w;

  RefreshHeader(BuildContext context)
      : super(
          color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
          backgroundColor:
              WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
        );
}
