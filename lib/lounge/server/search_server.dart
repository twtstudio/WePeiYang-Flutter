// @dart = 2.12
import 'package:flutter/foundation.dart';
import 'package:we_pei_yang_flutter/lounge/model/area.dart';
import 'package:we_pei_yang_flutter/lounge/model/building.dart';
import 'package:we_pei_yang_flutter/lounge/model/classroom.dart';

List<Query> formatQuery(String text) {
  // 支持逗号或空格分隔
  final splitQueries = text.split(RegExp(r'[,\s]'));

  List<Query> queries = [];

  // sort queries
  {
    for (var query in splitQueries) {
      for (var type in QueryType.values) {
        for (var match in type.regExp.allMatches(query)) {
          queries.add(Query(type, match.group(0) ?? ''));
        }
      }
    }
  }

  //combine same type query
  //ie. [45, b, a, 301, 404] -> [45, ba, 301404]
  {
    final iterator = queries.iterator;
    if (iterator.moveNext()) {
      List<Query> combineQueries = [];
      Query combineQuery = iterator.current;
      while (iterator.moveNext()) {
        final type = iterator.current.type;
        if (type.isBase && type == combineQuery.type) {
          combineQuery += iterator.current;
          continue;
        } else {
          combineQueries.add(combineQuery);
          combineQuery = iterator.current;
        }
      }
      combineQueries.add(combineQuery);
      queries.clear();
      queries.addAll(combineQueries);
    }
  }

  //combine consecutive query
  //ie. [44a115, 45, a, 46114, 33, 102] -> [44a115, 45a, 46114, 33102]
  {
    List<Query> combineQueries = [];
    int index = 0;
    while (index < queries.length) {
      switch (queries[index].type) {
        case QueryType.ba:
          if (index <= queries.length - 2 &&
              queries[index + 1].type == QueryType.c) {
            final combineQuery = queries[index] + queries[index + 1];
            combineQueries.add(combineQuery);
            index += 2;
            break;
          }
          combineQueries.add(queries[index]);
          index++;
          break;
        case QueryType.b:
          if (index <= queries.length - 2) {
            if (queries[index + 1].type == QueryType.ac) {
              final combineQuery = queries[index] + queries[index + 1];
              combineQueries.add(combineQuery);
              index += 2;
              break;
            } else if (queries[index + 1].type == QueryType.a) {
              Query conbineQuery = queries[index] + queries[index + 1];
              if (index <= queries.length - 3 &&
                  queries[index + 2].type == QueryType.c) {
                conbineQuery += queries[index + 2];
                combineQueries.add(conbineQuery);
                index += 3;
                break;
              }
              combineQueries.add(conbineQuery);
              index += 2;
              break;
            } else if (queries[index + 1].type == QueryType.c) {
              final combineQuery = queries[index] + queries[index + 1];
              combineQueries.add(combineQuery);
              index += 2;
              break;
            }
          }
          combineQueries.add(queries[index]);
          index++;
          break;
        case QueryType.a:
          if (index <= queries.length - 2 &&
              queries[index + 1].type == QueryType.c) {
            final combineQuery = queries[index] + queries[index + 1];
            combineQueries.add(combineQuery);
            index += 2;
            break;
          }
          combineQueries.add(queries[index]);
          index++;
          break;
        default:
          combineQueries.add(queries[index]);
          index++;
          break;
      }
    }

    queries.clear();
    queries.addAll(combineQueries);
  }
  return queries;
}

enum QueryType { bac, bc, ac, ba, b, c, a }

extension QueryTypeExt on QueryType {
  RegExp get regExp => [
        RegExp(
          r'(?<![\w\u4e00-\u9fa5])[1-9][0-9][\u4e00-\u9fa5]*[A-Za-z]+[\u4e00-\u9fa5]*[1-9][0-9]{0,2}[\u4e00-\u9fa5]*(?=\s|\f|\r|\t|\n|$)',
        ),
        RegExp(
          r'(?<![\w\u4e00-\u9fa5])[1-9][0-9][\u4e00-\u9fa5]*[1-9][0-9]{1,2}[\u4e00-\u9fa5]*(?=\s|\f|\r|\t|\n|$)',
        ),
        RegExp(
          r'(?<![\w\u4e00-\u9fa5])[A-Za-z]+[\u4e00-\u9fa5]*[1-9][0-9]{0,2}[\u4e00-\u9fa5]*(?=\s|\f|\r|\t|\n|$)',
        ),
        RegExp(
          r'(?<![\w\u4e00-\u9fa5])[1-9][0-9][\u4e00-\u9fa5]*[A-Za-z]+[\u4e00-\u9fa5]*(?=\s|\f|\r|\t|\n|$)',
        ),
        RegExp(
          r'(?<![\w\u4e00-\u9fa5])[1-9][0-9]?[\u4e00-\u9fa5]*(?=\s|\f|\r|\t|\n|$)',
        ),
        RegExp(
          r'(?<![\w\u4e00-\u9fa5])[1-9][0-9]{2}[\u4e00-\u9fa5]*(?=\s|\f|\r|\t|\n|$)',
        ),
        RegExp(
          r'(?<![\w\u4e00-\u9fa5])[a-zA-Z]+[\u4e00-\u9fa5]*(?=\s|\f|\r|\t|\n|$)',
        ),
      ][index];

  bool get isBase =>
      this == QueryType.a || this == QueryType.b || this == QueryType.c;

  Map<String, List<String>> split(String query) {
    final Map<String, String> querySplit = {};
    switch (this) {
      case QueryType.bac:
        final areaReg = RegExp(r'[A-Za-z]+');
        final area = areaReg.firstMatch(query)!.group(0)!;
        final splitList = query.split(area);
        querySplit['b'] = splitList.first;
        querySplit['a'] = area;
        querySplit['c'] = splitList.last;
        break;
      case QueryType.bc:
        // TODO: 还没处理 4455教101201
        final building = query.substring(0, 2);
        final room = query.substring(2);
        querySplit['b'] = building;
        querySplit['c'] = room;
        break;
      case QueryType.ac:
        final areaReg = RegExp(r'[A-Za-z]+');
        final area = areaReg.firstMatch(query)!.group(0)!;
        final room = query.substring(area.length);
        querySplit['a'] = area;
        querySplit['c'] = room;
        break;
      case QueryType.ba:
        final areaReg = RegExp(r'[A-Za-z]+');
        final area = areaReg.firstMatch(query)!.group(0)!;
        final building = query.substring(0, query.length - area.length);
        querySplit['a'] = area;
        querySplit['b'] = building;
        break;
      case QueryType.b:
        querySplit['b'] = query;
        break;
      case QueryType.c:
        querySplit['c'] = query;
        break;
      case QueryType.a:
        querySplit['a'] = query;
        break;
    }

    final Map<String, List<String>> resultQuery = {};

    final b = querySplit['b'];
    if (b != null) {
      resultQuery['b'] = splitByLength(b, 2);
    }

    final a = querySplit['a'];
    if (a != null) {
      resultQuery['a'] = splitByLength(a, 1);
    }

    final c = querySplit['c'];
    if (c != null) {
      resultQuery['c'] = splitByLength(c, 3);
    }

    return resultQuery;
  }

  List<String> splitByLength(String query, int length) {
    final List<String> list = [];
    for (var i = 0; i < query.length; i += length) {
      final next = i + length - 1 < query.length ? i + length : query.length;
      final bi = query.substring(i, next);
      list.add(bi);
    }
    return list;
  }

  QueryType operator +(QueryType other) {
    if (this == QueryType.b) {
      if (other == QueryType.a) {
        return QueryType.ba;
      } else if (other == QueryType.c) {
        return QueryType.bc;
      } else if (other == QueryType.ac) {
        return QueryType.bac;
      }
    } else if (this == QueryType.ba) {
      if (other == QueryType.c) {
        return QueryType.bac;
      }
    } else if (this == QueryType.a) {
      if (other == QueryType.c) {
        return QueryType.ac;
      }
    }

    throw Exception('can not add $other to $this');
  }
}

class Query {
  final QueryType type;
  final Map<String, List<String>> query;

  Query._(this.type, this.query);

  factory Query(QueryType type, String query) {
    query = query.replaceAll(RegExp(r'[\u4e00-\u9fa5]'), '').toUpperCase();
    final formQuery = type.split(query);
    return Query._(type, formQuery);
  }

  factory Query.complete(Map<String, List<String>> query) {
    QueryType? type;
    if (query.containsKey('b')) {
      type = QueryType.b;
    }
    if (query.containsKey('a')) {
      type = type != null ? type + QueryType.a : QueryType.a;
    }
    if (query.containsKey('c')) {
      type = type != null ? type + QueryType.c : QueryType.c;
    }
    if (type == null) {
      throw Exception('no type query!');
    }
    return Query._(type, query);
  }

  Query operator +(Query other) {
    if (type == other.type) {
      // combine same type
      for (var entry in query.entries) {
        final otherQuery = other.query[entry.key];
        if (otherQuery != null) {
          entry.value.addAll(otherQuery);
        }
      }
    } else {
      if (query['b'] != null || other.query['b'] != null) {
        query['b'] = [...(query['b'] ?? []), ...(other.query['b'] ?? [])];
      }

      if (query['a'] != null || other.query['a'] != null) {
        query['a'] = [...(query['a'] ?? []), ...(other.query['a'] ?? [])];
      }

      if (query['c'] != null || other.query['c'] != null) {
        query['c'] = [...(query['c'] ?? []), ...(other.query['c'] ?? [])];
      }
    }

    return Query.complete(query);
  }

  @override
  bool operator ==(Object other) =>
      other is Query &&
      other.runtimeType == runtimeType &&
      other.type == type &&
      other.query.keys.fold(
        true,
        (previous, key) => previous && listEquals(query[key], other.query[key]),
      );

  @override
  int get hashCode => query.hashCode;

  @override
  String toString() => '$type : $query';
}

Stream<SearchResult> querySearch(
  String base,
  Map<String, Building> buildings,
) async* {
  for (var format in formatQuery(base)) {
    var aName = format.query['a'] ?? [];
    var bName = format.query['b'] ?? [];
    var cName = format.query['c'] ?? [];

    switch (format.type) {
      case QueryType.bac:
        final bList = buildings.values.where((b) => _includeBuilding(b, bName));
        final aList = <Area>[];
        final cList = <Classroom>[];
        for (var b in bList) {
          for (var a in b.areas.values) {
            if (_includeArea(a, aName)) {
              aList.add(a);
            }
          }
        }
        for (var a in aList) {
          for (var room in a.classrooms.values) {
            if (_includeRoom(room, cName)) {
              cList.add(room);
            }
          }
        }
        yield SearchResult(cList, format);
        break;

      case QueryType.bc:
        final bList = buildings.values.where((b) => _includeBuilding(b, bName));
        final cList = <Classroom>[];
        for (var b in bList) {
          for (var a in b.areas.values) {
            for (var room in a.classrooms.values) {
              if (_includeRoom(room, cName)) {
                cList.add(room);
              }
            }
          }
        }
        yield SearchResult(cList, format);
        break;

      case QueryType.ac:
        final aList = <Area>[];
        final cList = <Classroom>[];
        for (var b in buildings.values) {
          for (var a in b.areas.values) {
            if (_includeArea(a, aName)) {
              aList.add(a);
            }
          }
        }
        for (var a in aList) {
          for (var room in a.classrooms.values) {
            if (_includeRoom(room, cName)) {
              cList.add(room);
            }
          }
        }
        yield SearchResult(cList, format);
        break;

      case QueryType.ba:
        final bList = buildings.values.where((b) => _includeBuilding(b, bName));
        final aList = <Area>[];
        for (var b in bList) {
          for (var a in b.areas.values) {
            if (_includeArea(a, aName)) {
              aList.add(a);
            }
          }
        }
        yield SearchResult(aList, format);
        break;

      case QueryType.b:
        final bList = buildings.values
            .where(
              (b) => _includeBuilding(b, bName),
            )
            .toList();
        yield SearchResult(bList, format);
        break;

      case QueryType.c:
        final cList = <Classroom>[];
        for (var b in buildings.values) {
          for (var a in b.areas.values) {
            for (var room in a.classrooms.values) {
              if (_includeRoom(room, cName)) {
                cList.add(room);
              }
            }
          }
        }
        yield SearchResult(cList, format);
        break;

      case QueryType.a:
        final aList = <Area>[];
        for (var b in buildings.values) {
          for (var a in b.areas.values) {
            if (_includeArea(a, aName)) {
              aList.add(a);
            }
          }
        }
        yield SearchResult(aList, format);
        break;
    }
  }
}

bool _includeRoom(Classroom room, List<String> list) => list.fold(
      false,
      (previous, element) => room.name.contains(element) || previous,
    );

bool _includeArea(Area area, List<String> list) => list.fold(
      false,
      (previous, element) => area.id.contains(element) || previous,
    );

bool _includeBuilding(Building building, List<String> list) => list.fold(
      false,
      (previous, element) => building.name.contains(element) || previous,
    );

class SearchResult {
  final SearchResultType type;
  final Query query;
  final dynamic data;

  SearchResult._(this.type, this.data, this.query);

  factory SearchResult(dynamic _data, Query _query) {
    late SearchResultType type;
    switch (_data.runtimeType.toString()) {
      case 'List<Classroom>':
        type = SearchResultType.room;
        break;
      case 'List<Building>':
        type = SearchResultType.building;
        break;
      case 'List<Area>':
        type = SearchResultType.area;
        break;
      default:
        throw Exception('no this type');
    }

    return SearchResult._(type, _data, _query);
  }

  @override
  String toString() {
    return '$type : $data';
  }
}

enum SearchResultType {
  building,
  area,
  room,
}
