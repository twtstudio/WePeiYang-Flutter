class GlobalModel {
  GlobalModel._();

  static final _instance = GlobalModel._();

  factory GlobalModel() => _instance;

  int captchaIndex = 0;

  void increase() => captchaIndex++;
}
