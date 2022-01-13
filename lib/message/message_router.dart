import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/message/user_mails_page.dart';

class MessageRouter {
  static String htmlMailPage = 'feedback/html_page';
  static final Map<String, Widget Function(Object arguments)> routers = {
    htmlMailPage: (args) {
      final data = args as Map;
      final url = data["url"];
      final title = data["title"];
      return MailPage(title: title, url: url);
    },
  };
}
