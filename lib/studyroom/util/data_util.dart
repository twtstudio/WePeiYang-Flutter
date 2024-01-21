import '../model/studyroom_models.dart';

class StudyRoomDataUtil {
  String extractPrefix(String input) {
    // 正则表达式：匹配从字符串开始到 "楼"、"区"、"教" 或大写字母，后跟数字（忽略前导0）的整个部分
    var regex = RegExp(r'^.*?(\D)+0*(\d)');
    var match = regex.firstMatch(input);
    if (match != null) {
      return match.group(0)!.replaceAll("0", "");
    } else {
      return input;
    }
  }

  static Map<String, List<Room>> prefixBasedSplit(List<Room> rooms) {
    Map<String, List<Room>> result = {};
    for (var room in rooms) {
      var prefix = StudyRoomDataUtil().extractPrefix(room.name).splitMapJoin(
            RegExp(r'[A-Z](?!区)'),
            onMatch: (m) => '${m.group(0)}区',
            onNonMatch: (n) => n,
          );
      room.name = room.name.replaceAll(RegExp(r"^.*?(\D)+0*"), '');

      if (result[prefix] == null) {
        result[prefix] = [];
      }
      result[prefix]!.add(room);
    }

    return result;
  }
}
