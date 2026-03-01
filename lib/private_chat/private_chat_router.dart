import 'package:flutter/material.dart' show Widget;
import 'package:we_pei_yang_flutter/private_chat/view/page/private_message_center_page.dart';
import 'package:we_pei_yang_flutter/private_chat/view/page/private_chat_conversation_page.dart';
import 'package:we_pei_yang_flutter/private_chat/view/page/private_chat_settings_page.dart';
import 'package:we_pei_yang_flutter/private_chat/view/page/private_chat_log_page.dart';
import 'package:we_pei_yang_flutter/private_chat/view/page/private_chat_api_test_page.dart';

class PrivateChatRouter {
  static String home = 'private_chat/home';
  static String conversation = 'private_chat/conversation';
  static String settings = 'private_chat/settings';
  static String log = 'private_chat/log';
  static String apiTest = 'private_chat/api_test';

  static final Map<String, Widget Function(dynamic arguments)> routers = {
    home: (_) => const PrivateMessageCenterPage(),
    conversation: (args) => PrivateChatConversationPage(contact: args),
    settings: (_) => const PrivateChatSettingsPage(),
    log: (_) => const PrivateChatLogPage(),
    apiTest: (_) => const PrivateChatApiTestPage(),
  };
}
