// @dart = 2.12
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';

class NewPostProvider {
  String title = "";
  String content = "";
  int type = 1;
  Department? department;
  Tag? tag;

  List<File> images = [];
  ///标题非空且内容非空为必要，非校务贴或者校务贴时部门不能为空
  bool get check =>
      title.isNotEmpty &&
      content.isNotEmpty && ((type == 1 && department != null) || (type != 1));

  void clear() {
    title = "";
    content = "";
    type = 1;
    images = [];
    tag = null;
    department = null;
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
