import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/lost_and_found/view/lost_and_found_detail_page.dart';
import 'package:we_pei_yang_flutter/lost_and_found/view/lost_and_found_search_page.dart';
import 'package:we_pei_yang_flutter/lost_and_found/view/lost_and_found_search_result_page.dart';

class LostAndFoundRouter {
  static String lostAndFoundSearch = 'feedback/lost_and_found_search';
  static String lostAndFoundSearchResult =
      'feedback/lost_and_found_search_result';
  static String lostAndFoundDetailPage = 'feedback/lost_and_found_detail_page';
  static final Map<String, Widget Function(dynamic arguments)> routers = {
    lostAndFoundSearch: (_) => LostAndFoundSearchPage(),
    lostAndFoundSearchResult: (args) => LostAndFoundSearchResultPage(args),
    lostAndFoundDetailPage: (args) =>
        LostAndFoundDetailPage(postId: args.item1, findOwner: args.item2),
  };
}
