import 'package:flutter/cupertino.dart';

class AnimationProvider extends ChangeNotifier {
  bool _animation = false;

  bool get animation => _animation;

  set animation(bool value) {
    _animation = value;
    notifyListeners();
  }

  double _speed = 1;

  double get speed => _speed;

  int _speedIndex = 2;

  int get speedIndex => _speedIndex;

  set speedIndex(int value) {
    _speedIndex = value;
    notifyListeners();
  }

  set speed(double value) {
    _speed = value;
    notifyListeners();
  }
}
