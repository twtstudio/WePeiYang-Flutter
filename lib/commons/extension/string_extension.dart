// @dart =2.12
part of 'extensions.dart';

extension StringExtension on String {
  String get time {
    var reg1 = RegExp(r"^[0-9]{4}-[0-9]{2}-[0-9]{2}");
    var date = reg1.firstMatch(this)?.group(0) ?? "";
    var reg2 = RegExp(r"[0-9]{2}:[0-9]{2}");
    var time = reg2.firstMatch(this)?.group(0) ?? "";
    return "$date  $time";
  }

  Size textSize(TextStyle style, BuildContext context) {
    final Size size = (TextPainter(
            text: TextSpan(text: this, style: style),
            maxLines: 1,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textDirection: TextDirection.ltr)
          ..layout())
        .size;
    return size;
  }

  /// 获取[单个]正则表达式匹配结果，若未匹配到则返回空字符串
  String match(String form) => RegExp(form).firstMatch(this)?.group(0) ?? '';

  /// 获取[多个]正则表达式匹配结果，若未匹配到则返回空列表
  List<String> matches(String form) {
    var list = <String>[];
    RegExp(form).allMatches(this).toList().forEach((e) {
      String? str = e.group(0);
      if (str != null) list.add(str);
    });
    return list;
  }
}
