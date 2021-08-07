import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';
import 'package:wei_pei_yang_demo/commons/util/router_manager.dart';
import 'package:wei_pei_yang_demo/lounge/service/images.dart';
import 'package:wei_pei_yang_demo/generated/l10n.dart';
import 'package:wei_pei_yang_demo/urgent_report/report_router.dart';

class CardBean {
  Widget icon;
  String label;
  String route;

  CardBean(this.icon, this.label, this.route);
}

class GlobalModel {
  GlobalModel._() {
    cards.add(CardBean(
        Icon(
          Icons.report,
          color: MyColors.darkGrey,
          size: 25.0,
        ),
        S.current.report,
        ReportRouter.main));
    cards.add(CardBean(
        Icon(
          Icons.event,
          color: MyColors.darkGrey,
          size: 25.0,
        ),
        S.current.schedule,
        ScheduleRouter.schedule));
    cards.add(CardBean(
        Icon(
          Icons.timeline,
          color: MyColors.darkGrey,
          size: 25.0,
        ),
        'GPA',
        GPARouter.gpa));

    /// 别改变自习室的位置，确定下标为3，不然请去wpy_page最下面改一下index
    cards.add(CardBean(
        ImageIcon(
          AssetImage(Images.building),
          size: 20,
          color: Color(0xffcecfd4),
        ),
        S.current.lounge,
        LoungeRouter.main));
  }

  static final _instance = GlobalModel._();

  factory GlobalModel() => _instance;

  init(BuildContext ctx) {
    var size = MediaQuery.of(ctx).size;
    var width = size.width;
    var height = size.height;
    screenWidth = width;
    screenHeight = height;
  }

  double screenWidth;
  double screenHeight;
  int captchaIndex = 0;
  final List<CardBean> cards = [];

  void increase() => captchaIndex++;
}
