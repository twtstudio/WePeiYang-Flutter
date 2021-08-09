import 'package:flutter/material.dart' show Widget;
import 'package:we_pei_yang_flutter/auth/view/login/login_page.dart';
import 'package:we_pei_yang_flutter/home/view/home_page.dart';
import 'package:we_pei_yang_flutter/home/view/drawer_page.dart';

class HomeRouter {
  static String home = 'home/home';
  static String more = 'home/more';
  static String telNum = 'home/telNum';
  static String learning = 'home/learning';
  static String library = 'home/library';
  static String cards = 'home/cards';
  static String classroom = 'home/classroom';
  static String coffee = 'home/coffee';
  static String byBus = 'home/byBus';

  static final Map<String, Widget Function(Object arguments)> routers = {
    home: (_) => HomePage(),
    more: (_) => DrawerPage(),
    telNum: (_) => LoginHomeWidget(),
    learning: (_) => LoginHomeWidget(),
    library: (_) => LoginHomeWidget(),
    cards: (_) => LoginHomeWidget(),
    classroom: (_) => LoginHomeWidget(),
    coffee: (_) => LoginHomeWidget(),
    byBus: (_) => LoginHomeWidget()
  };
}
