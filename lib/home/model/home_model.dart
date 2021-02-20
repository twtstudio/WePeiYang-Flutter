import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/lounge/config/lounge_router.dart';

// TODO 这里迟早得改
class CardBean {
  IconData icon;
  String label;
  String route;

  CardBean(this.icon, this.label, this.route);
}

class LibraryBean {
  String book;
  String time;

  LibraryBean(this.book, this.time);
}

class GPABean {
  List<double> gpaList;
  double weighted;
  double grade;

  GPABean(this.gpaList, this.weighted, this.grade);
}

class GlobalModel {
  GlobalModel._() {
    cards.add(CardBean(Icons.event, '课程表', '/schedule'));
    cards.add(CardBean(Icons.timeline, 'GPA', '/gpa'));
    cards.add(
        CardBean(Icons.calendar_today_outlined, "自习室", LoungeRouter.main));
    cards.add(CardBean(Icons.call, '黄页', '/telNum'));
    cards.add(CardBean(Icons.clear_all, '图书馆', '/library'));
    cards.add(CardBean(Icons.import_contacts, '凑数的1', '/learning'));
    cards.add(CardBean(Icons.card_giftcard, '凑数的2', '/cards'));
    cards.add(CardBean(Icons.free_breakfast, '凑数的3', '/coffee'));
    cards.add(CardBean(Icons.directions_bus, '凑数的4', '/byBus'));
  }

  static final _instance = GlobalModel._();

  factory GlobalModel() => _instance;

  double screenWidth;
  double screenHeight;
  int captchaIndex = 0;
  List<CardBean> cards = [];

  void increase() => captchaIndex++;
}
