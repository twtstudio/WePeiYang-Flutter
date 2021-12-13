import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class ClassesNeedVPNDialog extends Dialog {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color.fromRGBO(251, 251, 251, 1)),
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
                  color: Color.fromRGBO(98, 103, 123, 1),
                ),
                SizedBox(width: 3),
                Text('通知',
                    style: FontManager.YaQiHei.copyWith(
                        color: Color.fromRGBO(98, 103, 123, 1),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none))
              ],
            ),
            SizedBox(height: 10),
            Text(
                '应学校要求，校外使用教育教学信息管理系统需先登录天津大学VPN，'
                '故在校外访问微北洋课表、GPA功能也需登录VPN绑定办公网账号后使用。',
                style: FontManager.YaHeiRegular.copyWith(
                    color: Color.fromRGBO(98, 103, 124, 1),
                    fontSize: 14,
                    decoration: TextDecoration.none)),
            SizedBox(height: 15),
            Divider(height: 1, color: Color.fromRGBO(172, 174, 186, 1)),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(),
                padding: const EdgeInsets.all(12),
                child: Text(S.current.ok,
                    style: FontManager.YaQiHei.copyWith(
                        color: Color.fromRGBO(98, 103, 123, 1),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
