import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/util/router_manager.dart';

class CardBean {
  IconData icon;
  String label;
  String route;

  CardBean(this.icon, this.label, this.route);
}

class GlobalModel {
  GlobalModel._() {
    cards.add(CardBean(Icons.event, '课程表', ScheduleRouter.schedule));
    cards.add(CardBean(Icons.timeline, 'GPA', GPARouter.gpa));
    // cards.add(CardBean(Icons.call, '黄页', HomeRouter.telNum));
    // !!! 别改变自习室的位置，确定在3，不然请去wpy_page最下面改一下index
    cards
        .add(CardBean(Icons.calendar_today_outlined, "自习室", LoungeRouter.main));
  }

  static final _instance = GlobalModel._();

  factory GlobalModel() => _instance;

  double screenWidth;
  double screenHeight;
  int captchaIndex = 0;
  final List<CardBean> cards = [];

  void increase() => captchaIndex++;
}
