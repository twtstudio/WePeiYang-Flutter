import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/feedback/view/detail_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/game_web_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/image_view_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/new_post_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/official_comment_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/profile_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/search_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/search_result_page.dart';
import 'package:we_pei_yang_flutter/message/feedback_message_page.dart';

import '../../home/view/home_page.dart';

class FeedbackRouter {
  static String home = 'feedback/home';
  static String profile = 'feedback/profile';
  static String detail = 'feedback/detail';
  static String newPost = 'feedback/new_post';
  static String officialComment = 'feedback/official_comment';
  static String search = 'feedback/search';
  static String searchResult = 'feedback/search_result';
  static String mailbox = 'feedback/mailbox';
  static String imageView = 'feedback/image_view';
  static String web = 'feedback/web_view';

  static final Map<String, Widget Function(Object arguments)> routers = {
    home: (_) => HomePage(),
    profile: (_) => ProfilePage(),
    detail: (args) => DetailPage(args),
    newPost: (_) => NewPostPage(),
    officialComment: (args) => OfficialCommentPage(args),
    search: (_) => SearchPage(),
    searchResult: (args) => SearchResultPage(args),
    imageView: (_) => ImageViewPage(),
    mailbox: (_) => FeedbackMessagePage(),
    web: (_) => GameWebPage(),
  };
}
