class DataFactory {
  static List<String> splitPlan(String plan) {
    // print('plan: ' + plan);
    var result1 = plan.split(RegExp(r'0+'));
    // print(result1);
    var result2 = plan.split(RegExp(r'1+'));
    // print(result2);
    // print(result1.length == result2.length);
    if (result1.first == '') {
      var r = result1;
      result1 = result2;
      result2 = r;
    }
    // print(result1);
    // print(result2);
    int length = (result1.length + result2.length - 1) ~/ 2 * 2;

    List<String> result = [];
    for (var i = 0; i < length; i++) {
      switch (i % 2) {
        case 1:
          if (result2[(i + 1) ~/ 2] != '') result.add(result2[(i + 1) ~/ 2]);
          break;
        case 0:
          result.add(result1[i ~/ 2]);
          break;
      }
    }
    // print(result);
    return result;
  }


  static Map<String, String> formatQuery(String query) {
    List<String> querys = [];

    var q1 = query.split(RegExp(r'[\u4e00-\u9fa5\s]'));
    for (var q in q1) {
      if (q.contains(RegExp(r'[A-Za-z]'))) {
        var area =
        RegExp(r'[A-Za-z]').allMatches(q).map((e) => e.group(0)).toList();
        querys.addAll(area);
        var q2 = q.split(RegExp(r'[A-Za-z]'));
        for (var w in q2) {
          if (w.isNotEmpty) {
            if (w.length > 3) {
              var i1 = w.substring(0, 2);
              var i2 = w.substring(2, 5);
              querys.add(i1);
              querys.add(i2);
            } else {
              querys.add(w);
            }
          }
        }
      } else if (q.isNotEmpty) {
        if (q.length > 3) {
          var i1 = q.substring(0, 2);
          var i2 = q.substring(2, 5);
          querys.add(i1);
          querys.add(i2);
        } else {
          querys.add(q);
        }
      }
    }

    Map<String, String> orderedQuerys = {};

    for (var q in querys) {
      print('q: ' + q + '=' + RegExp(r'^[1-9][0-9]$').hasMatch(q).toString());
      if (RegExp(r'[A-Za-z]').hasMatch(q)) {
        if (orderedQuerys['aName'] == null) {
          orderedQuerys['aName'] = q;
        } else {
          print('教学楼具体区域不明确');
        }
      }
      if (RegExp(r'^[1-9][0-9]{0,1}$').hasMatch(q)) {
        if (orderedQuerys['bName'] == null) {
          orderedQuerys['bName'] = q;
        } else if (orderedQuerys['bName'] != null && q.length == 1) {
          print('教学楼不明确,猜测是教室开头（楼层）');
          orderedQuerys['cName'] = q;
        } else {
          print('教学楼不明确');
        }
      }
      if (RegExp(r'^[1-9][0-9]{2}$').hasMatch(q)) {
        if (orderedQuerys['cName'] == null) {
          orderedQuerys['cName'] = q;
        } else {
          print('具体教室不明确');
        }
      }
    }

    print('querys : ' + querys.toString());
    print('orderedQuerys : ' + orderedQuerys.toString());

    return orderedQuerys;
  }

}
