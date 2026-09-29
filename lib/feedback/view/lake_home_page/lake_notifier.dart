import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/token/lake_token_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/we_ko_dialog.dart';

class FbDepartmentsProvider {
  List<Department> departmentList = [];

  Future<void> initDepartments() async {
    await FeedbackService.getDepartments(
      await LakeTokenManager().token,
      onResult: (list) {
        departmentList.clear();
        departmentList.addAll(list);
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
      },
    );
  }
}

///用于在断网情况下过四秒显示重连按钮
class ChangeHintTextProvider extends ChangeNotifier {
  bool timeEnded = false;

  void resetTimer() {
    timeEnded = false;
    notifyListeners();
    calculateTime();
  }

  void calculateTime() {
    if (!timeEnded) {
      Future.delayed(Duration(seconds: 6), () {
        timeEnded = true;
        notifyListeners();
      });
    }
  }
}

class FbHotTagsProvider extends ChangeNotifier {
  List<Tag> hotTagsList = [];

  /// 0：未加载 1：加载中 2：加载完成 3：加载失败 4：加载成功但无数据
  int hotTagCardState = 0;
  Tag? recTag;

  Future<void> initHotTags({OnSuccess? success, OnFailure? failure}) async {
    hotTagCardState = 1;
    await FeedbackService.getHotTags(onSuccess: (list) {
      hotTagsList.clear();
      if (list.length == 0) {
        hotTagCardState = 4;
      } else {
        hotTagCardState = 2;
        hotTagsList.addAll(list);
      }
      notifyListeners();
    }, onFailure: (e) {
      hotTagCardState = 3;
      failure?.call(e);
      ToastProvider.error(e.error.toString());
    });
  }

  Future<void> initRecTag({required OnFailure failure}) async {
    await FeedbackService.getRecTag(onSuccess: (tag) {
      recTag = tag;
      notifyListeners();
    }, onFailure: (e) {
      failure.call(e);
      ToastProvider.error(e.error.toString());
    });
  }
}

enum LakePageStatus {
  unload,
  loading,
  idle,
  error,
}

class ChangeablePost {
  Post post = Post.empty();
  int changeId = 0;

  ChangeablePost(Post p, int cId)
      : post = p,
        changeId = cId;
}

class LakeUtil {
  // tabs
  static List<WPYTab> tabList = [];
  static final List<WPYTab> _serverTabList = [];

  /// 后端下发的默认分区顺序，不包含客户端生成的“精华”。
  static List<WPYTab> get defaultTabList =>
      List<WPYTab>.unmodifiable(_serverTabList);

  /// 分区列表或顺序变化时递增，通知已缓存的论坛首页重建 TabController。
  static final ValueNotifier<int> tabListRevision = ValueNotifier(0);
  static int? _tabIdToRestore;

  /// 列表更新后，论坛首页应继续展示的分区 id。
  static int? get tabIdToRestore => _tabIdToRestore;

  // 当前tab 的index
  static final ValueNotifier<int> currentTab = ValueNotifier(1);
  static final ValueNotifier<bool> showSearch = ValueNotifier(true);
  static final ValueNotifier<int> sortSeq = ValueNotifier(1);

  /// 已折叠置顶帖的分区 id 集合（分区级，折叠后整组置顶帖隐藏）
  static final ValueNotifier<Set<String>> collapsedTopTabs = ValueNotifier({});

  static void toggleCollapsedTop(int tabId) {
    final key = '$tabId';
    final s = Set<String>.from(collapsedTopTabs.value);
    s.contains(key) ? s.remove(key) : s.add(key);
    collapsedTopTabs.value = s;
    CommonPreferences.collapsedTopTabs.value = s.toList();
  }

  static void loadCollapsedTopTabs() =>
      collapsedTopTabs.value =
          Set.from(CommonPreferences.collapsedTopTabs.value);

  static final Map<int, LakePageController> lakePageControllers = {};

  static int get currentTabId => tabList[currentTab.value].id;

  static LakePageController get currentController =>
      lakePageControllers[currentTabId]!;

  static void _addDefaultTab() {
    WPYTab oTab = WPYTab(id: 0, shortname: '精华', name: '精华');
    tabList.clear();
    tabList.add(oTab);
    lakePageControllers.putIfAbsent(0, () => LakePageController.empty(0, 0));
  }

  /// 将用户保存的分区 id 顺序合并到后端列表。
  ///
  /// 无效、重复、已下线的 id 会被忽略；后端新增的分区按后端顺序追加。
  static List<WPYTab> mergeTabOrder(
    List<WPYTab> serverTabs,
    List<String> savedOrder,
  ) {
    final tabsById = <int, WPYTab>{};
    for (final tab in serverTabs) {
      tabsById.putIfAbsent(tab.id, () => tab);
    }

    final ordered = <WPYTab>[];
    final addedIds = <int>{};
    for (final rawId in savedOrder) {
      final id = int.tryParse(rawId);
      if (id == null || id == 0 || !addedIds.add(id)) continue;
      final tab = tabsById[id];
      if (tab != null) ordered.add(tab);
    }

    for (final tab in serverTabs) {
      if (tab.id != 0 && addedIds.add(tab.id)) ordered.add(tab);
    }
    return ordered;
  }

  /// 依据当前本地配置重建展示列表，保留各分区原有对象和内容控制器。
  static void applySavedTabOrder() {
    _addDefaultTab();
    tabList.addAll(
      mergeTabOrder(_serverTabList, CommonPreferences.feedbackTabOrder.value),
    );
  }

  static int? _selectedTabId() {
    if (tabList.isEmpty) return null;
    final index = currentTab.value.clamp(0, tabList.length - 1);
    return tabList[index].id;
  }

  static void _notifyTabListChanged(int? selectedTabId) {
    _tabIdToRestore = selectedTabId;
    final newIndex = selectedTabId == null
        ? -1
        : tabList.indexWhere((tab) => tab.id == selectedTabId);
    currentTab.value = newIndex < 0 ? 0 : newIndex;
    tabListRevision.value++;
  }

  static void _reconcilePageControllers() {
    final activeIds = tabList.map((tab) => tab.id).toSet();
    lakePageControllers.removeWhere((id, _) => !activeIds.contains(id));
    for (int i = 0; i < tabList.length; i++) {
      final tab = tabList[i];
      lakePageControllers.putIfAbsent(
        tab.id,
        () => LakePageController.empty(i, tab.id),
      );
    }
  }

  /// 保存用户顺序并立即更新已缓存的论坛首页。
  static void setCustomTabOrder(Iterable<int> tabIds) {
    final selectedTabId = _selectedTabId();
    final normalized = <String>[];
    final seen = <int>{};
    for (final id in tabIds) {
      if (id != 0 && seen.add(id)) normalized.add('$id');
    }
    CommonPreferences.feedbackTabOrder.value = normalized;
    applySavedTabOrder();
    _reconcilePageControllers();
    _notifyTabListChanged(selectedTabId);
  }

  static void resetCustomTabOrder() => setCustomTabOrder(const []);

  static Future<void> initTabList({bool forceRefresh = false}) async {
    if (tabList.isNotEmpty && !forceRefresh) return;
    final selectedTabId = _selectedTabId();
    final hadTabs = tabList.isNotEmpty;
    final List<WPYTab> list = await FeedbackService.getTabList();
    _serverTabList
      ..clear()
      ..addAll(list);
    applySavedTabOrder();
    _reconcilePageControllers();
    loadCollapsedTopTabs();
    if (hadTabs) _notifyTabListChanged(selectedTabId);
  }

  static Future<void> initPostList(int index, {forced = false}) async {
    if (!forced &&
        LakeUtil.lakePageControllers[index]?.postHolder.postsList.isNotEmpty) {
      return;
    }
    final result = await FeedbackService.getPosts(
        type: '$index',
        searchMode: sortSeq.value,
        page: '1',
        eTag: index == 0 ? 'recommend' : '');
    final postList = result.item1;

    final controller = LakeUtil.lakePageControllers[index]!;
    // 调用初始化在PageView里面，渲染PageView时tab已经初始化，可以断言非空
    controller.currentPage.value = 1;
    controller.postHolder.resetPosts(postList);
  }

  static Future<void> getNextPage(int index) async {
    final result = await FeedbackService.getPosts(
      type: '${index}',
      searchMode: sortSeq.value,
      eTag: index == 0 ? 'recommend' : '',
      page: LakeUtil.lakePageControllers[index]!.currentPage.value + 1,
    );
    final postList = result.item1;
    final controller = LakeUtil.lakePageControllers[index]!;
    controller.postHolder.addPosts(postList);
    controller.currentPage.value += 1;
  }

  static void quietUpdateItem(Post post, WPYTab tab) {
    LakeUtil.lakePageControllers[tab.id]?.postHolder.update(post);
  }

  static void _showWeKoDialog(BuildContext context, Post post, String id) {
    showDialog<bool>(
      context: context,
      builder: (context) => WeKoDialog(
        post: post,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, true),
      ),
    ).then((confirm) {
      if (confirm == true) {
        Navigator.pushNamed(context, FeedbackRouter.detail, arguments: post);
      }
      CommonPreferences.feedbackLastWeCo.value = id;
    });
  }

  static void _fetchPostById(BuildContext context, String id) {
    FeedbackService.getPostById(
      id: int.parse(id),
      onResult: (post) => _showWeKoDialog(context, post, id),
      onFailure: (e) {
        // Handle error if necessary
      },
    );
  }

  static Future<void> getClipboardWeKoContents(BuildContext context) async {
    final clipboardData = await _getValidClipboardData();
    if (clipboardData == null) return;

    final id = _extractIdFromText(clipboardData);
    if (id.isEmpty || !_shouldFetchPost(id)) return;

    _fetchPostById(context, id);
  }

  static Future<String?> _getValidClipboardData() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text?.trim().isNotEmpty ?? false) {
      return clipboardData!.text!.trim();
    }
    return null;
  }

  static String _extractIdFromText(String text) {
    return text.find(r"wpy://school_project/(\d*)");
  }

  static bool _shouldFetchPost(String id) {
    return CommonPreferences.feedbackLastWeCo.value != id &&
        CommonPreferences.lakeToken.value.isNotEmpty;
  }

  static void clearAll() {
    tabList.clear();
    _serverTabList.clear();
    _tabIdToRestore = null;
    lakePageControllers.clear();
    currentTab.value = 1;
    showSearch.value = true;
    sortSeq.value = 1;
  }
}

class LakePosts extends ChangeNotifier {
  // 使用post_id 获得Post
  final Map<int, Post> _posts = {};

  List<Post> _postsList = [];

  void addPosts(List<Post> postList) {
    postList.forEach((element) {
      _posts.update(element.id, (value) => element, ifAbsent: () => element);
    });
    _postsList = _posts.values.toList();
    notifyListeners();
  }

  void update(Post post) {
    _posts.update(post.id, (value) => post, ifAbsent: () => post);
    _postsList = _posts.values.toList();
    notifyListeners();
  }

  void resetPosts(List<Post> postList) {
    _posts.clear();
    addPosts(postList);
    _postsList = _posts.values.toList();
  }

  Map<int, Post> get posts => _posts;

  get postsList => _postsList;
}

class LakePageController {
  final int index;
  final int tabId;
  ScrollController? _scrollController;
  RefreshController? _refreshController;

  final ValueNotifier<int> currentPage = ValueNotifier(1);
  final LakePosts postHolder = LakePosts();

  LakePageController({
    required this.index,
    required this.tabId,
    ScrollController? scrollController,
    RefreshController? refreshController,
  })  : _scrollController = scrollController,
        _refreshController = refreshController;

  ScrollController? get scrollController => _scrollController;

  RefreshController? get refreshController => _refreshController;

  void attachControllers(
      ScrollController scrollController, RefreshController refreshController) {
    _scrollController = scrollController;
    _refreshController = refreshController;
  }

  void detachControllers(
      ScrollController scrollController, RefreshController refreshController) {
    if (identical(_scrollController, scrollController)) {
      _scrollController = null;
    }
    if (identical(_refreshController, refreshController)) {
      _refreshController = null;
    }
  }

  LakePageController.empty(idx, tabId)
      : index = idx,
        tabId = tabId;
}

class FestivalProvider extends ChangeNotifier {
  List<Festival> festivalList = [];
  List<Festival> nonePopupList = [];
  bool _notInit = true;

  int get nonePopupListLength {
    _initializeIfNeeded();
    return nonePopupList.length;
  }

  Future<void> initFestivalList() async {
    _notInit = false;
    await FeedbackService.getFestCards(
      onSuccess: (list) {
        _updateFestivalLists(list);
      },
      onFailure: (e) {
        notifyListeners();
      },
    );
  }

  void _initializeIfNeeded() {
    if (_notInit) {
      initFestivalList();
    }
  }

  void _updateFestivalLists(List<Festival> list) {
    festivalList = list;
    nonePopupList = list.where((f) => f.name != 'popup').toList();
    notifyListeners();
  }

  int popUpIndex() {
    return festivalList.indexWhere((f) => f.name == 'popup');
  }
}

class NoticeProvider extends ChangeNotifier {
  List<Notice> noticeList = [];

  Future<void> initNotices() async {
    await FeedbackService.getNotices(
      onResult: (notices) {
        noticeList.clear();
        noticeList.addAll(notices);
        notifyListeners();
      },
      onFailure: (e) {
        notifyListeners();
      },
    );
  }
}
