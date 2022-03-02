import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/view/message/message_service.dart';
import 'user_mails_page.dart';

class MessageRouter {
  static String mailPage = 'feedback/html_page';
  static final Map<String, Widget Function(Object arguments)> routers = {
    mailPage: (args) {
      final data = args as UserMail;
      return MailPage(data: data);
    },
  };
}
