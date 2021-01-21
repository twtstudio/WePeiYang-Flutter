import 'package:flutter/material.dart';

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
  GlobalModel._(){
    cards.add(CardBean(Icons.event, 'Schedule', '/schedule'));
    cards.add(CardBean(Icons.timeline, 'GPA', '/gpa'));
    cards.add(CardBean(Icons.import_contacts, 'Learning', '/learning'));
    cards.add(CardBean(Icons.call, 'Tel Num', '/telNum'));
    cards.add(CardBean(Icons.clear_all, 'Library', '/library'));
    cards.add(CardBean(Icons.card_giftcard, 'Cards', '/cards'));
    cards.add(CardBean(Icons.business, 'Classroom', '/classroom'));
    cards.add(CardBean(Icons.free_breakfast, 'Coffee', '/coffee'));
    cards.add(CardBean(Icons.directions_bus, 'By bus', '/byBus'));
  }

  static final _instance = GlobalModel._();

  factory GlobalModel.getInstance() => _instance;

  double screenWidth;
  double screenHeight;
  List<CardBean> cards = [];
}
