import 'package:flutter/material.dart' show Widget;
import "package:flutter/src/widgets/basic.dart";
import 'package:we_pei_yang_flutter/home/view/cas_qr_page.dart';

import 'view/home_page.dart';
import 'view/lost_and_found_home_page.dart';
import 'view/map_calendar_page.dart';
import 'view/web_views/fifty_two_hz_page.dart';
import 'view/web_views/game_page.dart';
import 'view/web_views/news_page.dart';
import 'view/web_views/notices_page.dart';
import 'view/web_views/wiki_page.dart';

class HomeRouter {
  static String home = 'home/home';
  static String wiki = 'home/wiki';
  static String hz = 'home/52hz';
  static String mapCalenderPage = 'home/mapCalenderPage';
  static String restartGame = 'home/restartGame';
  static String notice = 'home/notice';
  static String laf = ''; //'home/laf' 现在还不能上线
  static String news = 'home/news';
  static String casQR = 'home/casQR';
  static String game = ''; //'home/game'(虚空索引一下.jpg
  static final Map<String, Widget Function(dynamic arguments)> routers = {
    home: (args) => HomePage(args),
    wiki: (_) => WikiPage(),
    mapCalenderPage: (_) => MapCalendarPage(),
    hz: (_) => FiftyTwoHzPage(),
    notice: (_) => Builder(builder: (context) => NoticesPage(context: context)),
    laf: (_) => LostAndFoundHomePage(),
    news: (_) => NewsPage(),
    game: (_) => GamePage(),
    casQR: (_) => CasQRPage(),
  };
}
