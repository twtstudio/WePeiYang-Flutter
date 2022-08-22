// @dart = 2.12
class GPABean {
  Total total;
  List<GPAStat> stats;

  GPABean(this.total, this.stats);

  GPABean.fromJson(Map<String, dynamic> map)
      : total = Total.fromJson(map['total']),
        stats = []
          ..addAll((map['stats'] as List).map((e) => GPAStat.fromJson(e)));

  Map<String, dynamic> toJson() => {
        'total': total.toJson(),
        'stats': stats.map((e) => e.toJson()).toList(),
      };
}

class Total {
  double weighted; // 总加权
  double gpa; // 总绩点
  double credits; // 总学分

  Total(this.weighted, this.gpa, this.credits);

  Total.fromJson(Map<String, dynamic> map)
      : weighted = map['weighted'],
        gpa = map['gpa'],
        credits = map['credits'];

  Map<String, dynamic> toJson() =>
      {'weighted': weighted, 'gpa': gpa, 'credits': credits};
}

class GPAStat {
  String term; // 学期名，1H22、2H22代表22年第1、2学期
  double weighted; // 每学期加权
  double gpa; // 每学期绩点
  double credits; // 每学期学分
  List<GPACourse> courses;

  GPAStat(this.term, this.weighted, this.gpa, this.credits, this.courses);

  GPAStat.fromJson(Map<String, dynamic> map)
      : term = map['term'],
        weighted = map['weighted'],
        gpa = map['gpa'],
        credits = map['credits'],
        courses = []
          ..addAll((map['courses'] as List).map((e) => GPACourse.fromJson(e)));

  Map<String, dynamic> toJson() => {
        'term': term,
        'weighted': weighted,
        'gpa': gpa,
        'credits': credits,
        'courses': courses.map((e) => e.toJson()).toList(),
      };
}

class GPACourse {
  String name; // 课程名称
  String classType; // 课程类别 （必修/选修/...）
  double score; // 课程成绩
  String rawScore;
  double credit; // 课程学分
  double gpa; // 课程绩点

  GPACourse(this.name, this.classType, this.score, this.rawScore, this.credit,
      this.gpa);

  GPACourse.fromJson(Map<String, dynamic> map)
      : name = map['name'],
        classType = map['classType'],
        score = map['score'],
        rawScore = map['rawScore'],
        credit = map['credit'],
        gpa = map['gpa'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'classType': classType,
        'score': score,
        'rawScore': rawScore,
        'credit': credit,
        'gpa': gpa
      };
}
