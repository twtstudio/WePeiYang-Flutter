import 'dart:async';

import 'package:we_pei_yang_flutter/commons/util/shield_uid.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';

/// 「屏蔽用户 UID」功能的配套工具：让湖底帖子列表在屏蔽名单变化后立刻反映结果。
///
/// 背景（为什么需要这个文件）：湖底列表是**内存缓存**的，且
/// `normal_sub_page` 的 `wantKeepAlive = true`、`LakeUtil.initPostList` 在
/// 「缓存非空且非 forced」时直接 return。因此「屏蔽了某用户」之后回到湖底，
/// 看到的仍是屏蔽前拉取的旧列表，必须手动下拉刷新才会生效——这正是
/// “屏蔽了还能看见”的原因。
///
/// 这里只使用既有的公开 API（`LakePosts.resetPosts` / `LakeUtil.initPostList`），
/// 不改动任何既有逻辑，也不改变它们的默认行为。
class ShieldFeedSync {
  ShieldFeedSync._();

  /// 屏蔽成功后调用：把已被屏蔽用户的帖子从各 tab 已缓存的列表里摘掉。
  ///
  /// 不发网络请求，所以立刻生效，也不会重置分页（`currentPage` 不受影响）。
  /// `LakePosts.resetPosts` 内部会 `notifyListeners()`，列表随即重建。
  static void removeShieldedPosts() {
    for (final controller in LakeUtil.lakePageControllers.values) {
      final holder = controller.postHolder;
      final before = holder.postsList;
      final kept =
          before.where((post) => !ShieldUid.isBlocked(post.uid)).toList();
      if (kept.length != before.length) holder.resetPosts(kept);
    }
  }

  /// 解除屏蔽后调用：被剔除的帖子无法凭本地数据还原，因此让已经加载过内容的
  /// tab 重新拉取一次，让 TA 的内容重新出现。
  ///
  /// 走的是与下拉刷新完全相同的 `initPostList(forced: true)`，只作用于
  /// 「已经加载过」的 tab，不会为从未打开过的 tab 白跑请求。
  static void reloadLoadedPosts() {
    for (final entry in LakeUtil.lakePageControllers.entries) {
      if (entry.value.postHolder.postsList.isNotEmpty) {
        unawaited(LakeUtil.initPostList(entry.key, forced: true));
      }
    }
  }
}
