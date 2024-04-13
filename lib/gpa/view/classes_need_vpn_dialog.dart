import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';

import '../../commons/themes/wpy_theme.dart';
import '../../commons/widgets/w_button.dart';

class ClassesNeedVPNDialog extends Dialog {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color:  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 23,
                  color: WpyTheme.of(context).get(WpyColorKey.oldThirdActionColor),
                ),
                SizedBox(width: 3),
                Text('通知', style: TextUtil.base.bold.noLine.sp(18).oldThirdAction(context))
              ],
            ),
            SizedBox(height: 10),
            Text(
                '应学校要求，校外使用教育教学信息管理系统需先登录天津大学VPN，'
                '故在校外访问微北洋课表、GPA功能也需登录VPN绑定办公网账号后使用。',
                style: TextUtil.base.regular.noLine.sp(14).oldThirdAction(context)),
            SizedBox(height: 15),
            Divider(height: 1, color: WpyTheme.of(context).get(WpyColorKey.lightBorderColor)),
            WButton(
              onPressed: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(),
                padding: const EdgeInsets.all(12),
                child: Text('ok',
                    style: TextUtil.base.bold.noLine.sp(16).oldThirdAction(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
