// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';

class EditProvider with ChangeNotifier {
  /// 新建课程前读取保存记录（记录可能为默认值）
  void init() {
    arrangeList = _arrangeListSave;
    _totalCount = _totalCountSave;
    _initIndexList = _initIndexListSave;
  }

  /// 编辑课程前初始化
  void load(Course course) {
    arrangeList = course.arrangeList;
    _totalCount = arrangeList.length;
    _initIndexList = List.generate(_totalCount, (index) => index);
  }

  /// time frames
  List<Arrange> arrangeList = [Arrange.empty()];

  /// 添加的time frame的总数量
  int _totalCount = 1;

  /// 保存每个time frame最开始被分配的index
  /// 用这个index生成ValueKey，可以在build的时候不丢失输入框中的内容
  List<int> _initIndexList = [0];

  int initIndex(int index) => _initIndexList[index];

  void add() {
    arrangeList.add(Arrange.empty());
    _initIndexList.add(_totalCount);
    _totalCount += 1;
    notifyListeners();
  }

  void remove(int index) {
    arrangeList.removeAt(index);
    _initIndexList.removeAt(index);
    notifyListeners();
  }

  /// 检查所有arrange的必填项是否均已填
  int check() {
    for (int i = 0; i < arrangeList.length; i++) {
      if (arrangeList[i].weekList.isEmpty ||
          arrangeList[i].unitList.every((e) => e == 0)) {
        return i;
      }
    }
    return -1;
  }

  /// arrange中unitList默认值为[0, 0]，代表没有设置过节数
  /// UnitPicker打开前将unitList设置为[1, 1]
  void initUnitList(int index) {
    if (arrangeList[index].unitList.every((e) => e == 0)) {
      arrangeList[index].unitList = [1, 1];
    }
  }

  /// arrange中weekList默认值为[]，代表没有设置过星期
  /// WeekPicker打开前将weekList设置为[1, 1]
  void initWeekList(int index) {
    if (arrangeList[index].weekList.isEmpty) {
      arrangeList[index].weekList = [1, 1];
    }
  }

  /// UnitPicker & WeekPicker关闭后刷新各time frame
  void notify() {
    notifyListeners();
  }

  /// 以下变量用于保存新建课程信息
  String nameSave = '';
  String creditSave = '';
  List<Arrange> _arrangeListSave = [Arrange.empty()];
  int _totalCountSave = 1;
  List<int> _initIndexListSave = [0];

  /// EditBottomSheet返回时存储记录
  void save(String name, String credit) {
    nameSave = name;
    creditSave = credit;
    _arrangeListSave = arrangeList;
    _totalCountSave = _totalCount;
    _initIndexListSave = _initIndexList;
  }

  /// EditBottomSheet成功清空记录至默认值
  void clear() {
    nameSave = '';
    creditSave = '';
    _arrangeListSave = [Arrange.empty()];
    _totalCountSave = 1;
    _initIndexListSave = [0];
  }
}
