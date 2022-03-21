import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';

class NewPostProvider {
  String title = "";
  String content = "";
  int type = 1;
  Department department;
  Tag tag = Tag();

  List<File> images = [];

  bool get check =>
      title.isNotEmpty &&
      content.isNotEmpty && ((type == 1 && department != null) || (type != 1));

  void clear() {
    title = "";
    content = "";
    type = 1;
    images = [];
    tag = Tag();
    department = null;
  }
}

class NewFloorProvider extends ChangeNotifier {
  int locate;
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
