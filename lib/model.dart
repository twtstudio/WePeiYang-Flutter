import 'dart:convert';
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
  String data;

  CommonBody.fromJson(String data) {
    Map<String, String> tmp = json.decode(data);
    error_code = tmp['error_code'] as int;
    message = tmp['message'];
    data = tmp['data'];
  }
}

class Token {
  String token;

  Token(this.token);

  Token.fromJson(String data) {
    Map<String, String> tmp = json.decode(data);
    token = tmp['token'];
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
