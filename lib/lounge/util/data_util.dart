// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/lounge/model/classroom.dart';
import 'package:we_pei_yang_flutter/lounge/model/search_entry.dart';
import 'package:we_pei_yang_flutter/lounge/util/time_util.dart';

class DataFactory {
  static List<String> splitPlan(String plan) {
    var result1 = plan.split(RegExp(r'0+'));
    var result2 = plan.split(RegExp(r'1+'));
    if (result1.first == '') {
      var r = result1;
      result1 = result2;
      result2 = r;
    }
    int length = (result1.length + result2.length - 1) ~/ 2 * 2;

    List<String> preResult = [];
    for (var i = 0; i < length; i++) {
      switch (i % 2) {
        case 1:
          if (result2[(i + 1) ~/ 2] != '') preResult.add(result2[(i + 1) ~/ 2]);
          break;
        case 0:
          preResult.add(result1[i ~/ 2]);
          break;
      }
    }
    List<String> result = [];

    for (var r in preResult) {
      if (r.startsWith('1')) {
        result.addAll(splitBusyRange(r));
      } else {
        result.add(r);
      }
    }
    return result;
  }

  static List<String> splitBusyRange(String s) {
    List<String> busyRange = [];
    var index = 0;
    if (s.length > 3) {
      do {
        var str = s.substring(index, index + 2);
        busyRange.add(str);
        index += 2;
      } while (index < s.length - 3);
    }
    busyRange.add(s.substring(index, s.length));
    return busyRange;
  }

  static Map<String, String> formatQuery(String query) {
    List<String> queries = [];

    var q1 = query.split(RegExp(r'[\u4e00-\u9fa5\s]'));
    for (var q in q1) {
      if (q.contains(RegExp(r'[A-Za-z]'))) {
        var area =
            RegExp(r'[A-Za-z]').allMatches(q).map((e) => e.group(0)!).toList();
        queries.addAll(area);
        var q2 = q.split(RegExp(r'[A-Za-z]'));
        for (var w in q2) {
          if (w.isNotEmpty) {
            if (w.length > 3) {
              var i1 = w.substring(0, 2);
              var i2 = w.substring(2, 5);
              queries.add(i1);
              queries.add(i2);
            } else {
              queries.add(w);
            }
          }
        }
      } else if (q.isNotEmpty) {
        if (q.length > 3) {
          var i1 = q.substring(0, 2);
          var i2 = q.substring(2, q.length);
          queries.add(i1);
          queries.add(i2);
        } else {
          queries.add(q);
        }
      }
    }

    Map<String, String> orderedQueries = {};

    for (var q in queries) {
      if (RegExp(r'[A-Za-z]').hasMatch(q)) {
        if (orderedQueries['aName'] == null) {
          orderedQueries['aName'] = q.toUpperCase();
        } else {
          debugPrint('教学楼具体区域不明确');
        }
      }
      if (RegExp(r'^[1-9][0-9]{0,1}$').hasMatch(q)) {
        if (orderedQueries['bName'] == null) {
          orderedQueries['bName'] = q;
        } else if (orderedQueries['bName'] != null &&
            orderedQueries['cName'] == null) {
          debugPrint('教学楼不明确,猜测是教室开头（楼层）');
          orderedQueries['cName'] = q;
        } else {
          debugPrint('教学楼不明确');
        }
      }
      if (RegExp(r'^[1-9][0-9]{2}$').hasMatch(q)) {
        if (orderedQueries['cName'] == null) {
          orderedQueries['cName'] = q;
        } else {
          debugPrint('具体教室不明确');
        }
      }
    }
    return orderedQueries;
  }

  static bool roomIsIdle(
    Map<int, String> plan,
    List<ClassTime> schedule,
    int currentDay,
  ) {
    final currentPlan = plan[currentDay - 1];
    if (currentPlan != null) {
      return Time.availableNow(currentPlan, schedule);
    } else {
      return false;
    }
  }

  static ResultType getResultType(ResultEntry first) {
    var aExist = first.area != null;
    var cExist = first.room != null;

    if (cExist) {
      return ResultType.room;
    } else if (aExist) {
      return ResultType.area;
    } else {
      return ResultType.building;
    }
  }

  static String getRoomTitle(Classroom room) {
    var title = '${room.bName}教 ';
    if (room.aId != '-1') {
      title += room.aId;
    }
    title += room.name;
    return title;
  }
}
