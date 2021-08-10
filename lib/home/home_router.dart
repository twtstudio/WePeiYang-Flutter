import 'package:flutter/material.dart' show Widget;
import 'package:we_pei_yang_flutter/home/view/home_page.dart';
import 'package:we_pei_yang_flutter/home/view/drawer_page.dart';
import 'package:we_pei_yang_flutter/home/view/wiki_page.dart';

class HomeRouter {
  static String home = 'home/home';
  static String more = 'home/more';
  static String wiki = 'home/wiki';

  static final Map<String, Widget Function(Object arguments)> routers = {
    home: (_) => HomePage(),
    more: (_) => DrawerPage(),
    wiki: (_) => WikiPage()
  };
}
