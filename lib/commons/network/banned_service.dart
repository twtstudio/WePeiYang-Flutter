import 'package:dio/dio.dart';
import 'wpy_dio.dart';
import '../environment/config.dart';

class BannedService extends DioAbstract {
  @override
  String get baseUrl => '${EnvConfig.QNHD}';

  BannedService() {
    super.interceptors = [];
  }

  Future<List<int>> getBannedList() async {
    try {
      final response = await get('/api/v1/b/banned');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is List) {
          return (data['data'] as List).map((e) => e as int).toList();
        }
        if (data is List) {
          return data.map((e) => e as int).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> addBanned(int uid, {String? reason}) async {
    try {
      final response = await post(
        '/api/v1/b/banned',
        data: {
          'uid': uid,
          if (reason != null) 'reason': reason,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBanned(int uid) async {
    try {
      final response = await get(
        '/api/v1/b/banned/delete',
        queryParameters: {'uid': uid},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isBanned(int uid) async {
    final list = await getBannedList();
    return list.contains(uid);
  }
}