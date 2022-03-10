// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/lounge/util/theme_util.dart';

class ClearHistoryDialog extends Dialog {
  const ClearHistoryDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ok = TextButton(
      onPressed: () {
        Navigator.pop(context, true);
      },
      child: Text(
        '确定',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).searchClearHistoryDialogTextColor,
        ),
      ),
    );

    final cancel = TextButton(
      onPressed: () {
        Navigator.pop(context, false);
      },
      child: Text(
        '取消',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).searchClearHistoryDialogTextColor,
        ),
      ),
    );

    final text = Text(
      '是否要清除历史记录',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Theme.of(context).searchClearHistoryDialogTextColor,
        fontSize: 15.sp,
        fontWeight: FontWeight.normal,
        decoration: TextDecoration.none,
      ),
    );

    Widget body = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        text,
        Padding(
          padding: EdgeInsets.only(top: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [cancel, SizedBox(width: 40.w), ok],
          ),
        ),
      ],
    );

    body = Center(
      child: UnconstrainedBox(
        child: Container(
          height: 120.w,
          width: 300.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.w),
            color: Theme.of(context).searchClearHistoryDialogBackground,
          ),
          child: body,
        ),
      ),
    );

    return body;
  }
}
