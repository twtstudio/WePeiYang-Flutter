import 'dart:io';

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';

class NewPostProvider {
  String title = "";
  String content = "";
  int type = 1;
  Department? department;
  Tag? tag;
  ValueNotifier<int> postTypeNotifier = ValueNotifier(0);

  List<File> images = [];
  List<int> masked = [];

  ///标题非空且内容非空为必要，非校务贴或者校务贴时部门不能为空
  bool get check =>
      title.isNotEmpty &&
      content.isNotEmpty &&
      ((type == 1 && department != null) || (type != 1));

  void clear() {
    title = "";
    content = "";
    type = 1;
    images = [];
    tag = null;
    department = null;
    masked = [];
  }
}

class ScreenshotNotifier extends ChangeNotifier {
  List<int> screenshotList = [];

  List<int> get list => screenshotList;

  void empty() {
    screenshotList = [];
    notifyListeners();
  }

  void update() {
    notifyListeners();
  }
}

class NewFloorProvider extends ChangeNotifier {
  int replyTo = 0;
  List<File> images = [];
  String floorSentContent = '';
  bool inputFieldEnabled = false;
  FocusNode focusNode = FocusNode();

  void inputFieldOpenAndReplyTo(int rep) {
    inputFieldEnabled = true;
    replyTo = rep;
    notifyListeners();
  }

  void inputFieldClose() {
    inputFieldEnabled = false;
    notifyListeners();
  }

  void clearAndClose() {
    focusNode.unfocus();
    inputFieldEnabled = false;
    replyTo = 0;
    images = [];
    notifyListeners();
  }
}
