import 'package:flutter/material.dart' show Widget;
import 'package:we_pei_yang_flutter/home/view/home_page.dart';
import 'package:we_pei_yang_flutter/home/view/web_views/wiki_page.dart';
import 'package:we_pei_yang_flutter/home/view/web_views/restart_school_days_game.dart';

class HomeRouter {
  static String home = 'home/home';
  static String wiki = 'home/wiki';
  static String restartGame = 'home/restartGame';

  static final Map<String, Widget Function(Object arguments)> routers = {
    home: (_) => HomePage(),
    wiki: (_) => WikiPage(),
    restartGame: (_) => RestartSchoolDaysGamePage()
  };
}
