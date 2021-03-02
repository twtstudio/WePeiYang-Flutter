import 'view_state_model.dart';

// refresh左边的向下箭头点不了

/// 基于
abstract class ViewStateListModel<T> extends ViewStateModel {
  /// 页面数据
  final List<T> list = [];

  /// 第一次进入页面loading skeleton
  initData() async {
    await refresh();
  }

  // 下拉刷新
  refresh() async {
    try {
      setBusy();
      List<T> data = await loadData();
      if (data.isEmpty) {
        list.clear();
        setEmpty();
      } else {
        await onCompleted(data);
        list.clear();
        list.addAll(data);
        setIdle();
      }
    } catch (e, s) {
      list.clear();
      setError(e, s);
    }
  }

  ///具体实现类中按照需求实现这两个方法
  // 加载数据
  Future<List<T>> loadData();
  // 加载完成操作
  onCompleted(List<T> data) async {}
}
