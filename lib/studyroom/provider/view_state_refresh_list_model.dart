import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'view_state_list_model.dart';

/// 基于
abstract class ViewStateRefreshListModel<T> extends ViewStateListModel<T> {

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  RefreshController get refreshController => _refreshController;

  /// 当前页码
  // int _currentPageNum = pageNumFirst;

  /// 下拉刷新
  ///
  /// [init] 是否是第一次加载
  /// true:  Error时,需要跳转页面
  /// false: Error时,不需要跳转页面,直接给出提示
  Future<List<T>> refresh({bool init = false}) async {
    try {
      // _currentPageNum = pageNumFirst;
      var data = await loadData();
      if (data.isEmpty) {
        refreshController.refreshCompleted(resetFooterState: true);
        list.clear();
        setEmpty();
      } else {
        onCompleted(data);
        list.clear();
        list.addAll(data);
        refreshController.refreshCompleted();
        // 小于分页的数量,禁止上拉加载更多
        // if (data.length < pageSize) {
        //   refreshController.loadNoData();
        // } else {
        //   //防止上次上拉加载更多失败,需要重置状态
        //   refreshController.loadComplete();
        // }
        setIdle();
      }
      return data;
    } catch (e, s) {
      /// 页面已经加载了数据,如果刷新报错,不应该直接跳转错误页面
      /// 而是显示之前的页面数据.给出错误提示
      if (init) list.clear();
      refreshController.refreshFailed();
      setError(e, s);
      return null;
    }
  }

  // 加载数据
  Future<List<T>> loadData();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
