import 'package:flutter/material.dart';

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

class CommonBody {
  int error_code;
  String message;
  Map data;

  CommonBody.fromJson(dynamic jsonData) {
    error_code = jsonData['error_code'];
    message = jsonData['message'];
    data = jsonData['data'];
  }
}

class GlobalModel {
  GlobalModel._();

  double screenWidth;
  double screenHeight;

  static GlobalModel _instance;

  static GlobalModel getInstance() {
    if (_instance == null) _instance = GlobalModel._();
    return _instance;
  }
}
