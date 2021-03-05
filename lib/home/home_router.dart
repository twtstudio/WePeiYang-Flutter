import 'package:flutter/material.dart' show Widget;
import 'package:wei_pei_yang_demo/auth/view/login/login_page.dart';
import 'package:wei_pei_yang_demo/home/view/home_page.dart';
import 'package:wei_pei_yang_demo/home/view/drawer_page.dart';

class HomeRouter {
  static String home = '/home';
  static String more = '/more';
  static String telNum = '/telNum';
  static String learning = '/learning';
  static String library = '/library';
  static String cards = '/cards';
  static String classroom = '/classroom';
  static String coffee = '/coffee';
  static String byBus = '/byBus';

  static final Map<String, Widget Function(Object arguments)> routers = {
    home:(_) => HomePage(),
    more:(_) => DrawerPage(),
    telNum: (_) => LoginHomeWidget(),
    learning: (_) => LoginHomeWidget(),
    library: (_) => LoginHomeWidget(),
    cards: (_) => LoginHomeWidget(),
    classroom: (_) => LoginHomeWidget(),
    coffee: (_) => LoginHomeWidget(),
    byBus: (_) => LoginHomeWidget()
  };
}
