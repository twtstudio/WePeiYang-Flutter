import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';

class RefreshHeader extends MaterialClassicHeader {
  /// 刷新指示器下拉到页面高度的 2/5 处
  static const _offsetFraction = 0.4;

  final double _offset;

  @override
  double get offset => _offset;

  @override
  double get distance => 10.w;

  RefreshHeader(BuildContext context)
      : _offset = MediaQuery.sizeOf(context).height * _offsetFraction,
        super(
          color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
          backgroundColor:
              WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
        );
}
