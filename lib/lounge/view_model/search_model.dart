import 'package:flutter/foundation.dart';
import 'package:wei_pei_yang_demo/lounge/provider/view_state_model.dart';
import 'package:wei_pei_yang_demo/lounge/service/data_factory.dart';
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
  final String query;
  final SearchHistoryModel searchHistoryModel;

  SearchResultModel({this.query, this.searchHistoryModel});

  @override
  refresh() {
    debugPrint('++++++++++++++++ search model get data +++++++++++++++++++');
    super.refresh();
  }

  @override
  Future<List> loadData() async {
    // await Future.delayed(Duration(seconds: 1));

    if (query.isEmpty) return [];
    searchHistoryModel.addHistory(query);
    var formatQueries = DataFactory.formatQuery(query);
    var result = await HiveManager.instance.search(formatQueries).toList();
    return result;
  }
}