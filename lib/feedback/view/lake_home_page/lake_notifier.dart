import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/we_ko_dialog.dart';

class FbDepartmentsProvider {
  List<Department> departmentList = [];

  Future<void> initDepartments() async {
    await FeedbackService.getDepartments(
      CommonPreferences.lakeToken.value,
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

class LakeArea {
  final WPYTab tab;
  Map<int, Post> dataList;
  RefreshController refreshController;
  ScrollController controller;
  LakePageStatus status;
  int currentPage = 1;

  LakeArea.empty()
      : this.tab = WPYTab(),
        this.dataList = {},
        this.refreshController = RefreshController(),
        this.controller = ScrollController(),
        this.status = LakePageStatus.unload;

  clear() {
    this.dataList = {};
    this.refreshController = RefreshController();
    this.controller = ScrollController();
    this.status = LakePageStatus.unload;
  }
}

class LakeModel extends ChangeNotifier {
  LakePageStatus mainStatus = LakePageStatus.unload;
  Map<int, LakeArea> lakeAreas = {};
  List<WPYTab> tabList = [];
  List<WPYTab> backupList = [WPYTab()];
  int currentTab = 0;
  bool openFeedbackList = false, tabControllerLoaded = false, scroll = false;
  bool barExtended = true;
  double opacity = 0;
  late TabController tabController;
  int sortSeq = 1;

  clearAll() {
    mainStatus = LakePageStatus.unload;
    lakeAreas.clear();
    tabList.clear();
    backupList = [WPYTab()];
    currentTab = 0;
    openFeedbackList = false;
    tabControllerLoaded = false;
    scroll = false;
    barExtended = true;
    opacity = 0;
    tabController.dispose();
    sortSeq = 1;
  }

  Future<void> initTabList() async {
    if (mainStatus == LakePageStatus.error ||
        mainStatus == LakePageStatus.unload)
      mainStatus = LakePageStatus.loading;
    notifyListeners();
    WPYTab oTab = WPYTab(id: 0, shortname: '精华', name: '精华');
    tabList.clear();
    tabList.add(oTab);
    await FeedbackService.getTabList().then((list) {
      tabList.addAll(list);
      lakeAreas.addAll({0: LakeArea.empty()});
      list.forEach((element) {
        lakeAreas.addAll({element.id: LakeArea.empty()});
      });
      mainStatus = LakePageStatus.idle;
      notifyListeners();
    }, onError: (e) {
      mainStatus = LakePageStatus.error;
      ToastProvider.error(e.error.toString());
      notifyListeners();
    });
  }

  void onFeedbackOpen() {
    barExtended = true;
    notifyListeners();
  }

  void onFeedbackClose() {
    barExtended = false;
    notifyListeners();
  }

  void initLakeArea(int index, WPYTab tab, RefreshController rController,
      ScrollController sController) {
    // LakeArea lakeArea = new LakeArea._(
    //     WPYTab(), {}, rController, sController, LakePageStatus.unload);
    // lakeAreas[index] = lakeArea;
  }

  void fillLakeAreaAndInitPostList(
      int index, RefreshController rController, ScrollController sController) {
    lakeAreas[index]?.clear();
    initPostList(index, success: () {}, failure: (e) {
      ToastProvider.error(e.error.toString());
    });
  }

  void quietUpdateItem(Post post, WPYTab tab) {
    lakeAreas[tab]?.dataList.update(
      post.id,
      (value) {
        value.isLike = post.isLike;
        value.isFav = post.isFav;
        value.likeCount = post.likeCount;
        value.favCount = post.favCount;
        return value;
      },
      ifAbsent: () => post,
    );
  }

  // 列表去重
  void _addOrUpdateItems(List<Post> data, int index) {
    data.forEach((element) {
      lakeAreas[index]
          ?.dataList
          .update(element.id, (value) => element, ifAbsent: () => element);
    });
  }

  Future<void> getNextPage(int index,
      {required OnSuccess success, required OnFailure failure}) async {
    await FeedbackService.getPosts(
      type: '${index}',
      searchMode: sortSeq,
      etag: index == 0 ? 'recommend' : '',
      page: lakeAreas[index]!.currentPage + 1,
      onSuccess: (postList, page) {
        _addOrUpdateItems(postList, index);
        lakeAreas[index]!.currentPage += 1;
        success.call();
        notifyListeners();
      },
      onFailure: (e) {
        FeedbackService.getToken();
        failure.call(e);
      },
    );
  }

  checkTokenAndGetTabList(FbDepartmentsProvider provider,
      {OnSuccess? success}) async {
    await FeedbackService.getToken(
      onResult: (token) {
        provider.initDepartments();
        initTabList();
        success?.call();
      },
      onFailure: (e) {
        ToastProvider.error('获取分区失败');
        notifyListeners();
      },
    );
  }

  checkTokenAndInitPostList(int index) async {
    await FeedbackService.getToken(
      onResult: (_) {
        initPostList(index);
      },
      onFailure: (e) {
        ToastProvider.error('获取分区失败');
        notifyListeners();
      },
    );
  }

  Future<void> initPostList(int index,
      {OnSuccess? success, OnFailure? failure, bool reset = false}) async {
    if (reset) {
      lakeAreas[index]?.status = LakePageStatus.loading;
      notifyListeners();
    }
    await FeedbackService.getPosts(
      type: '$index',
      searchMode: sortSeq,
      page: '1',
      etag: index == 0 ? 'recommend' : '',
      onSuccess: (postList, totalPage) {
        tabControllerLoaded = true;
        lakeAreas[index]?.dataList.clear();
        _addOrUpdateItems(postList, index);
        lakeAreas[index]!.currentPage = 1;
        lakeAreas[index]!.status = LakePageStatus.idle;
        notifyListeners();
        success?.call();
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
        checkTokenAndInitPostList(index);
        lakeAreas[index]!.status = LakePageStatus.error;
        notifyListeners();
        failure?.call(e);
      },
    );
  }

  getClipboardWeKoContents(BuildContext context) async {
    ClipboardData? clipboardData =
        await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null &&
        clipboardData.text != null &&
        clipboardData.text!.trim() != '') {
      String text = clipboardData.text!.trim();

      final id = text.find(r"wpy://school_project/(\d*)");
      if (id.isNotEmpty) {
        if (CommonPreferences.feedbackLastWeCo.value != id &&
            CommonPreferences.lakeToken.value != "")
          FeedbackService.getPostById(
              id: int.parse(id),
              onResult: (post) {
                showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return WeKoDialog(
                      post: post,
                      onConfirm: () => Navigator.pop(context, true),
                      onCancel: () => Navigator.pop(context, true),
                    );
                  },
                ).then((confirm) {
                  if (confirm != null && confirm) {
                    Navigator.pushNamed(context, FeedbackRouter.detail,
                        arguments: post);
                    CommonPreferences.feedbackLastWeCo.value = id;
                  } else {
                    CommonPreferences.feedbackLastWeCo.value = id;
                  }
                });
              },
              onFailure: (e) {
                // ToastProvider.error(e.error.toString());
              });
      }
    }
  }
}

class FestivalProvider extends ChangeNotifier {
  List<Festival> festivalList = [];
  List<Festival> nonePopupList = [];

  Future<void> initFestivalList() async {
    await FeedbackService.getFestCards(
      onSuccess: (list) {
        festivalList.clear();
        festivalList.addAll(list);

        nonePopupList.clear();
        for (Festival f in list) {
          if (f.name != 'popup') {
            nonePopupList.add(f);
          }
        }
        notifyListeners();
      },
      onFailure: (e) {
        notifyListeners();
      },
    );
  }

  int popUpIndex () {
    for (int i = 0; i < festivalList.length; i++) {
      if (festivalList[i].name == 'popup') return i;
    }
    return -1;
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
