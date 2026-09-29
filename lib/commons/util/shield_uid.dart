import 'package:flutter/foundation.dart';

import '../preferences/common_prefs.dart';

/// 被屏蔽用户 UID 的本地缓存。
///
/// 黑名单的唯一事实来源是服务端（`/api/v1/f/blocklist`）：设置页每次进入都会
/// 拉取完整名单并调用 [replaceAll] 覆盖本地。
/// 这份本地缓存存在的意义是「列表渲染需要同步判断」——`getPosts` / `getComments`
/// 等过滤点不可能为每条数据发一次网络请求，所以用本地 Set 兜住。
///
/// 存储方式与「屏蔽评论词」（[CommonPreferences.shieldComment]）保持一致：
/// 同样是 [CommonPreferences] 里的一个 `PrefsBean<List<String>>`，落盘到
/// SharedPreferences 的字符串列表，App 重启后依然有效、离线也可用。
///
/// UID 在内存与对外接口中统一用 int，仅在落盘时转成 String，
/// 以适配 SharedPreferences 只支持 `List<String>` 的限制。
class ShieldUid {
  ShieldUid._();

  /// 解析结果的缓存，避免每次渲染列表都重复解析字符串
  static Set<int>? _cache;

  /// 当前被屏蔽的全部 UID
  static Set<int> get blocked => _cache ??= _read();

  /// 屏蔽名单（升序，供设置页展示）
  static List<int> get list => blocked.toList()..sort();

  static bool get isEmpty => blocked.isEmpty;

  /// 判断该 UID 是否已被屏蔽
  static bool isBlocked(int? uid) => uid != null && blocked.contains(uid);

  /// 判断字符串形式的 UID 是否已被屏蔽
  /// （失物招领等模块的 uid 字段是 String）
  static bool isBlockedStr(String? uid) {
    if (uid == null) return false;
    final parsed = int.tryParse(uid.trim());
    return parsed != null && blocked.contains(parsed);
  }

  /// 该 UID 是否已在屏蔽名单中
  static bool contains(int uid) => blocked.contains(uid);

  /// 加入屏蔽名单。返回 true 表示新增成功，false 表示 UID 非法或已存在。
  static bool block(int? uid) {
    if (uid == null || uid <= 0) return false;
    if (!blocked.add(uid)) return false;
    _save();
    return true;
  }

  /// 移出屏蔽名单。返回 true 表示确实移除了一项。
  static bool unblock(int uid) {
    if (!blocked.remove(uid)) return false;
    _save();
    return true;
  }

  /// 清空屏蔽名单
  static void clear() {
    blocked.clear();
    _save();
  }

  /// 用服务端返回的黑名单覆盖本地缓存。
  /// 服务端是唯一事实来源，本地仅用于列表过滤与离线兜底。
  static void replaceAll(Iterable<int> uids) {
    blocked
      ..clear()
      ..addAll(uids.where((uid) => uid > 0));
    _save();
  }

  /// 清除解析缓存。仅供测试模拟「App 重启后重新读取」的场景。
  @visibleForTesting
  static void resetCache() => _cache = null;

  static Set<int> _read() {
    final result = <int>{};
    for (final raw in CommonPreferences.shieldUid.value) {
      final uid = int.tryParse(raw.trim());
      if (uid != null && uid > 0) result.add(uid);
    }
    return result;
  }

  static void _save() {
    CommonPreferences.shieldUid
        .value = blocked.map((uid) => uid.toString()).toList();
  }
}
