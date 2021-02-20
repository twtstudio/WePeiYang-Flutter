import 'package:flutter/foundation.dart';
import 'package:wei_pei_yang_demo/lounge/provider/view_state_list_model.dart';
import 'package:wei_pei_yang_demo/lounge/service/hive_manager.dart';

const String kSearchHistory = 'kSearchHistory';

class SearchHistoryModel extends ViewStateListModel<String> {
  clearHistory() async {
    debugPrint('clearHistory');
    await HiveManager.instance.clearHistory();
    list.clear();
    setEmpty();
  }

  addHistory(String keyword) async {
    await HiveManager.instance.addSearchHistory(query: keyword);
    notifyListeners();
  }

  @override
  Future<List<String>> loadData() async {
    return await HiveManager.instance.searchHistory;
  }
}

class SearchResultModel extends ViewStateListModel {
  final String keyword;
  final SearchHistoryModel searchHistoryModel;

  SearchResultModel({this.keyword, this.searchHistoryModel});

  @override
  Future<List> loadData({int pageNum}) async {
    if (keyword.isEmpty) return [];
    searchHistoryModel.addHistory(keyword);
    return [];
  }
}