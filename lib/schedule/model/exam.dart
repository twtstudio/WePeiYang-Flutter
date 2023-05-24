class ExamTable {
  List<Exam> exams;

  ExamTable(this.exams);

  ExamTable.fromJson(Map<String, dynamic> map)
      : exams = []..addAll((map['exams'] as List).map((e) => Exam.fromJson(e)));

  Map<String, dynamic> toJson() => {
        'exams': exams.map((e) => e.toJson()).toList(),
      };
}

class Exam {
  String id;
  String name;
  String type;
  String date;
  String arrange;
  String location;
  String seat;
  String state;
  String ext;

  Exam(this.id, this.name, this.type, this.date, this.arrange, this.location,
      this.seat, this.state, this.ext);

  Exam.fromJson(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        type = map['type'],
        date = map['date'],
        arrange = map['arrange'],
        location = map['location'],
        seat = map['seat'],
        state = map['state'],
        ext = map['ext'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'date': date,
        'arrange': arrange,
        'location': location,
        'seat': seat,
        'state': state,
        'ext': ext,
      };
}
