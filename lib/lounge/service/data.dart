import 'package:wei_pei_yang_demo/lounge/model/area.dart';
import 'package:wei_pei_yang_demo/lounge/model/building.dart';
import 'package:wei_pei_yang_demo/lounge/model/classroom.dart';

class Data {
  static List<Building> getBuildings() {
    var l_44 = Building()
      ..id = "1"
      ..name = "44"
      ..campus = "1"
      ..areas = {
        "A": Area()
          ..area_id = "A"
          ..classrooms = {
            "00 ": Classroom()
              ..id = "00"
              ..name = "101"
              ..capacity = "20",
            "01": Classroom()
              ..id = "01"
              ..name = "102"
              ..capacity = "15",
            "02": Classroom()
              ..id = "02"
              ..name = "103"
              ..capacity = "35",
            "03": Classroom()
              ..id = "03"
              ..name = "201"
              ..capacity = "40",
            "04": Classroom()
              ..id = "04"
              ..name = "202"
              ..capacity = "30",
            "05": Classroom()
              ..id = "05"
              ..name = "301"
              ..capacity = "20",
          },
        "B": Area()
          ..area_id = "B"
          ..classrooms = {
            "06": Classroom()
              ..id = "06"
              ..name = "105"
              ..capacity = "20",
            "07": Classroom()
              ..id = "07"
              ..name = "106"
              ..capacity = "30",
            "08": Classroom()
              ..id = "08"
              ..name = "301"
              ..capacity = "20",
          },
        "C": Area()
          ..area_id = "C"
          ..classrooms = {
            "09": Classroom()
              ..id = "09"
              ..name = "101"
              ..capacity = "20",
            "10": Classroom()
              ..id = "10"
              ..name = "201"
              ..capacity = "30",
            "11": Classroom()
              ..id = "11"
              ..name = "202"
              ..capacity = "20",
          }
      };

    var l_45 = Building()
      ..id = "2"
      ..name = "45"
      ..campus = "1"
      ..areas = {
        "": Area()
          ..area_id = ""
          ..classrooms = {
            "12": Classroom()
              ..id = "12"
              ..name = "101"
              ..capacity = "20",
            "13": Classroom()
              ..id = "13"
              ..name = "102"
              ..capacity = "15",
            "14": Classroom()
              ..id = "14"
              ..name = "103"
              ..capacity = "35",
          }
      };

    var l_35 = Building()
      ..id = "3"
      ..name = "35"
      ..campus = "2"
      ..areas = {
        "A": Area()
          ..area_id = "A"
          ..classrooms = {
            "15": Classroom()
              ..id = "15"
              ..name = "101"
              ..capacity = "20",
            "16": Classroom()
              ..id = "16"
              ..name = "102"
              ..capacity = "15",
            "17": Classroom()
              ..id = "17"
              ..name = "103"
              ..capacity = "35",
          },
        "B": Area()
          ..area_id = "B"
          ..classrooms = {
            "18": Classroom()
              ..id = "18"
              ..name = "105"
              ..capacity = "20",
            "19": Classroom()
              ..id = "19"
              ..name = "106"
              ..capacity = "30",
          }
      };

    return [l_44, l_45, l_35];
  }

  static List<Building> getOneDayAvailable(int day) {
    var l_44 = Building()
      ..id = "1"
      ..name = "44"
      ..campus = "1"
      ..areas = {
        "A": Area()
          ..area_id = "A"
          ..classrooms = {
            "00": Classroom()
              ..id = "00"
              ..name = "101"
              ..capacity = "20"
              ..status = "000000000000"
          },
        "B": Area()
          ..area_id = "B"
          ..classrooms = {},
        "C": Area()
          ..area_id = "C"
          ..classrooms = {},
      };

    var l_45 = Building()
      ..id = "2"
      ..name = "45"
      ..campus = "1"
      ..areas = {
        "": Area()
          ..area_id = ""
          ..classrooms = {}
      };

    var l_35 = Building()
      ..id = "3"
      ..name = "35"
      ..campus = "2"
      ..areas = {
        "A": Area()
          ..area_id = "A"
          ..classrooms = {},
        "B": Area()
          ..area_id = "B"
          ..classrooms = {}
      };

    var l_44_1 = Building()
      ..id = "1"
      ..name = "44"
      ..campus = "1"
      ..areas = {
        "A": Area()
          ..area_id = "A"
          ..classrooms = {
            "00": Classroom()
              ..id = "00"
              ..name = "101"
              ..capacity = "20"
              ..status = "110011001100"
          },
        "B": Area()
          ..area_id = "B"
          ..classrooms = {},
        "C": Area()
          ..area_id = "C"
          ..classrooms = {},
      };

    var l_45_1 = Building()
      ..id = "2"
      ..name = "45"
      ..campus = "1"
      ..areas = {
        "": Area()
          ..area_id = ""
          ..classrooms = {
            "13": Classroom()
              ..id = "13"
              ..name = "102"
              ..capacity = "15"
              ..status = "000000000000"
          }
      };

    var l_44_2 = Building()
      ..id = "1"
      ..name = "44"
      ..campus = "1"
      ..areas = {
        "A": Area()
          ..area_id = "A"
          ..classrooms = {
            "00": Classroom()
              ..id = "00"
              ..name = "101"
              ..capacity = "20"
              ..status = "000011001100"
          },
        "B": Area()
          ..area_id = "B"
          ..classrooms = {},
        "C": Area()
          ..area_id = "C"
          ..classrooms = {},
      };

    var l_45_2 = Building()
      ..id = "2"
      ..name = "45"
      ..campus = "1"
      ..areas = {
        "": Area()
          ..area_id = ""
          ..classrooms = {
            "13": Classroom()
              ..id = "13"
              ..name = "102"
              ..capacity = "15"
              ..status = "001100000000"
          }
      };

    var l_44_3 = Building()
      ..id = "1"
      ..name = "44"
      ..campus = "1"
      ..areas = {
        "A": Area()
          ..area_id = "A"
          ..classrooms = {
            "00": Classroom()
              ..id = "00"
              ..name = "101"
              ..capacity = "20"
              ..status = "110011001100"
          },
        "B": Area()
          ..area_id = "B"
          ..classrooms = {},
        "C": Area()
          ..area_id = "C"
          ..classrooms = {},
      };

    var l_45_3 = Building()
      ..id = "2"
      ..name = "45"
      ..campus = "1"
      ..areas = {
        "": Area()
          ..area_id = ""
          ..classrooms = {
            "13": Classroom()
              ..id = "13"
              ..name = "102"
              ..capacity = "15"
              ..status = "000000000000"
          }
      };

    var l_44_4 = Building()
      ..id = "1"
      ..name = "44"
      ..campus = "1"
      ..areas = {
        "A": Area()
          ..area_id = "A"
          ..classrooms = {
            "00": Classroom()
              ..id = "00"
              ..name = "101"
              ..capacity = "20"
              ..status = "000000001100"
          },
        "B": Area()
          ..area_id = "B"
          ..classrooms = {},
        "C": Area()
          ..area_id = "C"
          ..classrooms = {},
      };

    var l_45_4 = Building()
      ..id = "2"
      ..name = "45"
      ..campus = "1"
      ..areas = {
        "": Area()
          ..area_id = ""
          ..classrooms = {
            "13": Classroom()
              ..id = "13"
              ..name = "102"
              ..capacity = "15"
              ..status = "000000001110"
          }
      };

    var l_44_5 = Building()
      ..id = "1"
      ..name = "44"
      ..campus = "1"
      ..areas = {
        "A": Area()
          ..area_id = "A"
          ..classrooms = {
            "00": Classroom()
              ..id = "00"
              ..name = "101"
              ..capacity = "20"
              ..status = "000000000000"
          },
        "B": Area()
          ..area_id = "B"
          ..classrooms = {},
        "C": Area()
          ..area_id = "C"
          ..classrooms = {},
      };

    var l_45_5 = Building()
      ..id = "2"
      ..name = "45"
      ..campus = "1"
      ..areas = {
        "": Area()
          ..area_id = ""
          ..classrooms = {
            "13": Classroom()
              ..id = "13"
              ..name = "102"
              ..capacity = "15"
              ..status = "000000001100"
          }
      };

    var l_44_6 = Building()
      ..id = "1"
      ..name = "44"
      ..campus = "1"
      ..areas = {
        "A": Area()
          ..area_id = "A"
          ..classrooms = {
            "00": Classroom()
              ..id = "00"
              ..name = "101"
              ..capacity = "20"
              ..status = "000000000000"
          },
        "B": Area()
          ..area_id = "B"
          ..classrooms = {},
        "C": Area()
          ..area_id = "C"
          ..classrooms = {},
      };

    var l_45_6 = Building()
      ..id = "2"
      ..name = "45"
      ..campus = "1"
      ..areas = {
        "": Area()
          ..area_id = ""
          ..classrooms = {
            "13": Classroom()
              ..id = "13"
              ..name = "102"
              ..capacity = "15"
              ..status = "000000000000"
          }
      };

    var l_44_7 = Building()
      ..id = "1"
      ..name = "44"
      ..campus = "1"
      ..areas = {
        "A": Area()
          ..area_id = "A"
          ..classrooms = {
            "00": Classroom()
              ..id = "00"
              ..name = "101"
              ..capacity = "20"
              ..status = "111100000000"
          },
        "B": Area()
          ..area_id = "B"
          ..classrooms = {},
        "C": Area()
          ..area_id = "C"
          ..classrooms = {},
      };

    var l_45_7 = Building()
      ..id = "2"
      ..name = "45"
      ..campus = "1"
      ..areas = {
        "": Area()
          ..area_id = ""
          ..classrooms = {
            "13": Classroom()
              ..id = "13"
              ..name = "102"
              ..capacity = "15"
              ..status = "000000000011"
          }
      };

    List<Building> d1 = [l_44_1, l_45_1, l_35];
    List<Building> d2 = [l_44_2, l_45_2, l_35];
    List<Building> d3 = [l_44_3, l_45_3, l_35];
    List<Building> d4 = [l_44_4, l_45_4, l_35];
    List<Building> d5 = [l_44_5, l_45_5, l_35];
    List<Building> d6 = [l_44_6, l_45_6, l_35];
    List<Building> d7 = [l_44_7, l_45_7, l_35];

    List<Building> dNEXT = [l_44, l_45, l_35];

    switch (day) {
      case 1:
        return d1;
      case 2:
        return d2;
      case 3:
        return d3;
      case 4:
        return d4;
      case 5:
        return d5;
      case 6:
        return d6;
      case 7:
        return d7;
      default:
        return dNEXT;
    }
  }
}
