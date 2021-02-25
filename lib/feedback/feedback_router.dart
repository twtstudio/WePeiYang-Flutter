import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/feedback/view/detail_page.dart';
import 'package:wei_pei_yang_demo/feedback/view/profile_page.dart';
import 'package:wei_pei_yang_demo/feedback/view/search_page.dart';

import '../home/view/home_page.dart';

class FeedbackRouter {
  static String home = 'feedback/home';
  static String profile = 'feedback/profile';
  static String detail = 'feedback/detail';
  static String search = 'feedback/search';

  static final Map<String, Widget Function(Object arguments)> routers = {
    home: (_) => HomePage(),
    profile: (_) => ProfilePage(),
    detail: (post) => DetailPage(post),
    search:(_) => DetailSearchPage(),
  };
}
