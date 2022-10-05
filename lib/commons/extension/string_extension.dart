// @dart =2.12
part of 'extensions.dart';

extension StringExtension on String {
  /// 获取[单个]正则表达式匹配(非捕获)结果，若未匹配到则返回空字符串
  String match(String form) {
    return RegExp(form).firstMatch(this)?.group(0) ?? '';
  }

  /// 获取[多个]正则表达式匹配(非捕获)结果，若未匹配到则返回空列表,
  List<String> matches(String form) {
    var list = <String>[];
    RegExp(form).allMatches(this).toList().forEach((e) {
      String? str = e.group(0);
      if (str != null) list.add(str);
    });
    return list;
  }

  ///获取[单个]正则表达式捕获结果，若未匹配到则返回空字符串
  String find(String form) {
    final matches = RegExp(form).allMatches(this);
    if (!matches.isEmpty) {
      return matches.first.group(1) ?? '';
    }
    return "";
  }

  ///获取[单个]正则表达式捕获的多个结果，若未匹配到则返回空字符串
  List<String> findArray(String form) {
    final matches = RegExp(form).allMatches(this);
    if (!matches.isEmpty) {
      final cnt = matches.first.groupCount;
      return matches.first
          .groups(List.generate(cnt, (index) => index + 1))
          .map((e) => e ?? '')
          .toList();
    }
    return [];
  }

  ///获取[多个]正则表达式捕获的多个结果，若未匹配到则返回空字符串
  List<List<String>> findArrays(String form) {
    final matches = RegExp(form).allMatches(this);
    if (!matches.isEmpty) {
      List<List<String>> res = [];
      matches.forEach((m) {
        final cnt = m.groupCount;
        res.add(m
            .groups(List.generate(cnt, (index) => index + 1))
            .map((e) => e ?? '')
            .toList());
      });
      return res;
    }
    return [];
  }
}
