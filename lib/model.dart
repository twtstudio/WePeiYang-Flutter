import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class MyColors {
  static final deepBlue = Color.fromRGBO(53, 59, 84, 1.0); //no.1
  static final darkGrey = Color.fromRGBO(105, 109, 126, 1.0); //Card label颜色(小图标下的文字,如Bicycle)
  static final darkGrey2 = Color.fromRGBO(116, 119, 138, 1.0); //no.2
  static final brightBlue = Color.fromRGBO(103, 110, 150, 1.0); //no.3
  static final dust = Color.fromRGBO(230, 230, 230, 1.0); //no.4
  static final lessDeepBlue = Color.fromRGBO(69, 91, 117, 1.0); //no.5
  static final myGrey = Color.fromRGBO(245, 245, 245, 1.0);
  static final deepDust = Color.fromRGBO(210, 210, 210, 1.0);
  static final colorList = [
    deepBlue,
    darkGrey2,
    brightBlue,
    dust,
    lessDeepBlue
  ];
}

class CardBean {
  IconData icon;
  String label;
  String route;

  CardBean(this.icon, this.label, this.route);
}

class CourseBean {
  String course;
  String duration;
  String classroom;

  CourseBean(this.course, this.duration, this.classroom);
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
  GlobalModel._();

  double screenWidth;
  double screenHeight;

  static GlobalModel _instance;

  static GlobalModel getInstance(){
    if(_instance == null) _instance = GlobalModel._();
    return _instance;
  }
}