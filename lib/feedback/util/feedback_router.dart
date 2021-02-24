import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/feedback/view/detail_page.dart';
import 'package:wei_pei_yang_demo/feedback/view/new_post_page.dart';
import 'package:wei_pei_yang_demo/feedback/view/official_comment_page.dart';
import 'package:wei_pei_yang_demo/feedback/view/profile_page.dart';

import '../../home/view/home_page.dart';

class FeedbackRouter {
  static String home = 'feedback/home';
  static String profile = 'feedback/profile';
  static String detail = 'feedback/detail';
  static String newPost = 'feedback/new_post';
  static String officialComment = 'feedback/official_comment';

  static final Map<String, Widget Function(Object arguments)> routers = {
    home: (_) => HomePage(),
    profile: (_) => ProfilePage(),
    detail: (args) => DetailPage(args),
    newPost: (_) => NewPostPage(),
    officialComment: (args) => OfficialCommentPage(args),
  };
}
