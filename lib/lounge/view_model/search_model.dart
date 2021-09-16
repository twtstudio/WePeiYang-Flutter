import 'package:we_pei_yang_flutter/lounge/provider/view_state_model.dart';
import 'package:we_pei_yang_flutter/lounge/service/data_factory.dart';
import 'package:we_pei_yang_flutter/lounge/service/hive_manager.dart';

const String kSearchHistory = 'kSearchHistory';

class SearchHistoryModel extends ViewStateListModel<String> {
  clearHistory() async {
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