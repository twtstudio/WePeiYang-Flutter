// @dart=2.12

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:we_pei_yang_flutter/auth/model/nacid_info.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';

import '../../../commons/themes/wpy_theme.dart';

/// 核酸检测提醒弹窗
class AcidCheckDialog extends Dialog {
  AcidCheckDialog(this.acidInfo, this._now);
  final ValueNotifier<DateTime> _now;

  final Future<NAcidInfo> acidInfo;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: acidInfo,
      builder: (context, AsyncSnapshot<NAcidInfo> snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;

          final start = data.startTime ?? DateTime.now();
          final end = data.endTime ?? DateTime.now();

          return Column(
            children: [
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.w),
                width: 0.7.sw,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/schedule/notify.png',
                        height: 25.h,
                        width: 25.w,
                      ),
                    ),
                    SizedBox(height: 20.w),
                    Text(
                      '#${data.title}',
                      style: TextUtil.base.NotoSansSC.grey126.normal.sp(18),
                    ),
                    SizedBox(height: 20.w),
                    Text(
                      '${data.content}',
                      style: TextUtil.base.NotoSansSC.grey126.normal.sp(16),
                    ),
                    SizedBox(height: 10.w),
                    Text(
                      '${data.campus}校区',
                      style: TextUtil.base.NotoSansSC.grey126.normal.sp(16),
                    ),
                    SizedBox(height: 10.w),
                    Text(
                      '${DateFormat('HH:mm').format(start.toLocal())} - ${DateFormat('HH:mm').format(end.toLocal())}',
                      style: TextUtil.base.PingFangSC.primaryAction(context).w500.sp(20),
                    ),
                    SizedBox(height: 10.w),
                    ValueListenableBuilder(
                        valueListenable: _now,
                        builder: (_, DateTime time, __) {
                          final before = time.isBefore(start);
                          Duration dur = before
                              ? start.difference(time)
                              : end.difference(time);
                          final hr = dur.inHours.toString().padLeft(2, '0');
                          final min =
                              (dur.inMinutes % 60).toString().padLeft(2, '0');
                          return time.isBefore(end)
                              ? Text(
                                  '距检测${before ? '开始' : '结束'}还有$hr时$min分',
                                  style: TextUtil.base.PingFangSC.grey126.normal
                                      .sp(16),
                                )
                              : Text(
                                  '今日核酸已结束',
                                  style: TextUtil.base.PingFangSC.grey126.normal
                                      .sp(16),
                                );
                        }),
                    SizedBox(height: 20.w),
                  ],
                ),
              ),
              Spacer()
            ],
          );
        } else if (snapshot.hasError) {
          Navigator.pop(context);
          return SizedBox.shrink();
        } else {
          return Loading();
        }
      },
    );
  }
}
