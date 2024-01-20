// @dart=2.12
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_models.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_service.dart';

import '../../commons/preferences/common_prefs.dart';

List<SingleChildWidget> studyroomProviders = [
  ChangeNotifierProvider(create: (_) => CampusProvider())
];

class CampusProvider with ChangeNotifier {
  List<Campus> _campusList = [];
  Map<Campus, bool> _buildingLoaded = {};

  Map<Campus, List<Building>> _buildingMaps = {};

  bool loadedCampus = false;

  void init() async {
    _campusList = await StudyroomService.getCampusList();
    loadedCampus = true;
    notifyListeners();
    _campusList.forEach((campus) async {
      final buildings = await StudyroomService.getBuildingList(campus.id);
      _buildingMaps[campus] = buildings;
      _buildingLoaded[campus] = true;
      notifyListeners();
    });
  }

  List<Building> get buildings => _buildingMaps[_campusList[_current]] ?? [];

  int _current = CommonPreferences.lastChoseCampus.value;

  void next() {
    if (_campusList.isEmpty) return;
    _current = (_current + 1) % _campusList.length;
    CommonPreferences.lastChoseCampus.value = _current;
    notifyListeners();
  }

  bool get buildingLoaded => _campusList.isEmpty
      ? false
      : _buildingLoaded[_campusList[_current]] ?? false;

  int get id => _campusList.isNotEmpty ? _campusList[_current].id : -1;

  String get name =>
      _campusList.isNotEmpty ? _campusList[_current].name : "加载中";
}
