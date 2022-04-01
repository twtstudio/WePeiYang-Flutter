import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/we_ko_dialog.dart';

import '../../feedback_router.dart';

class FbDepartmentsProvider {
  List<Department> departmentList = [];

  Future<void> initDepartments() async {
    await FeedbackService.getDepartments(
      CommonPreferences().feedbackToken.value,
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

class FbHotTagsProvider extends ChangeNotifier {
  List<Tag> hotTagsList = [];
  Tag recTag;

  Future<void> initHotTags({OnSuccess success, OnFailure failure}) async {
    await FeedbackService.getHotTags(onSuccess: (list) {
      hotTagsList.clear();
      hotTagsList.addAll(list);
      notifyListeners();
      success?.call();
    }, onFailure: (e) {
      failure.call(e);
      ToastProvider.error(e.error.toString());
    });
  }

  Future<void> initRecTag({OnSuccess success, OnFailure failure}) async {
    await FeedbackService.getRecTag(onSuccess: (tag) {
      recTag = tag;
      notifyListeners();
      success?.call();
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
  final Map<int, Post> dataList;
  final RefreshController refreshController;
  final ScrollController controller;
  LakePageStatus status;
  int currentPage;

  LakeArea._(this.tab, this.dataList, this.refreshController, this.controller,
      LakePageStatus unload);

  factory LakeArea.empty() {
    return LakeArea._(WPYTab(), {}, RefreshController(), ScrollController(),
        LakePageStatus.unload);
  }
}

class LakeModel extends ChangeNotifier {
  LakePageStatus mainStatus = LakePageStatus.unload;
  Map<int, LakeArea> lakeAreas = {};
  List<WPYTab> tabList = [];
  List<WPYTab> backupList = [WPYTab()];
  int currentTab = 0;
  bool openFeedbackList = false, tabControllerLoaded = false, scroll = false;
  double opacity = 0;
  TabController tabController;
  ScrollController nController;
  int sortSeq = 1;

  Future<void> initTabList() async {
    if (mainStatus == LakePageStatus.error ||
        mainStatus == LakePageStatus.unload)
      mainStatus = LakePageStatus.loading;
    notifyListeners();
    await FeedbackService.getTabList().then((list) {
      WPYTab oTab = WPYTab(id: 0, shortname: '全部', name: '全部');
      tabList.clear();
      tabList.add(oTab);
      tabList.addAll(list);
      lakeAreas.addAll({0: LakeArea.empty()});
      initLakeArea(
          0, oTab, RefreshController(), ScrollController());
      list.forEach((element) {
        lakeAreas.addAll({element.id: LakeArea.empty()});
        initLakeArea(
            element.id, element, RefreshController(), ScrollController());
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
    if (!scroll && nController.offset != 0) {
      scroll = true;
      nController
          .animateTo(0,
              duration: Duration(milliseconds: 160), curve: Curves.decelerate)
          .then((value) => scroll = false);
    }
  }

  void onClose() {
    if (!scroll && nController.offset != nController.position.maxScrollExtent) {
      scroll = true;
      nController
          .animateTo(nController.position.maxScrollExtent,
              duration: Duration(milliseconds: 160), curve: Curves.decelerate)
          .then((value) => scroll = false);
    }
  }

  void initLakeArea(int index, WPYTab tab, RefreshController rController,
      ScrollController sController) {
    LakeArea lakeArea = new LakeArea._(
        WPYTab(), {}, rController, sController, LakePageStatus.unload);
    lakeAreas[index] = lakeArea;
  }

  void fillLakeArea(
      int index, RefreshController rController, ScrollController sController) {
    LakeArea lakeArea = new LakeArea._(lakeAreas[index].tab, {}, rController,
        sController, LakePageStatus.unload);
    lakeAreas[index] = lakeArea;
  }

  void quietUpdateItem(Post post, WPYTab tab) {
    lakeAreas[tab].dataList.update(
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
          .dataList
          .update(element.id, (value) => element, ifAbsent: () => element);
    });
  }

  Future<void> getNextPage(int index,
      {OnSuccess success, OnFailure failure}) async {
    await FeedbackService.getPosts(
      type: '${index}',
      mode: sortSeq,
      page: lakeAreas[index].currentPage + 1,
      onSuccess: (postList, page) {
        _addOrUpdateItems(postList, index);
        lakeAreas[index].currentPage += 1;
        success?.call();
        notifyListeners();
      },
      onFailure: (e) {
        failure?.call(e);
      },
    );
  }

  checkTokenAndGetTabList({OnSuccess success, OnFailure failure}) async {
    await FeedbackService.getToken(
      onResult: (token) {
        initTabList();
      },
      onFailure: (e) {
        ToastProvider.error('获取分区失败');
        failure?.call(e);
        notifyListeners();
      },
    );
  }

  checkTokenAndGetPostList(FbDepartmentsProvider provider, int index, int mode,
      {OnSuccess success, OnFailure failure}) async {
    await FeedbackService.getToken(
      onResult: (token) {
        provider.initDepartments();
        initPostList(index);
      },
      onFailure: (e) {
        lakeAreas[index].status = LakePageStatus.error;
        failure?.call(e);
        notifyListeners();
      },
    );
  }

  Future<void> initPostList(int index,
      {OnSuccess success, OnFailure failure, bool reset = false}) async {
    if (reset) {
      lakeAreas[index].status = LakePageStatus.loading;
      notifyListeners();
    }
    await FeedbackService.getPosts(
      type: '$index',
      mode: sortSeq,
      page: '1',
      onSuccess: (postList, totalPage) {
        tabControllerLoaded = true;
        if (lakeAreas[index].dataList != null)
          lakeAreas[index].dataList.clear();
        _addOrUpdateItems(postList, index);
        lakeAreas[index].currentPage = 1;
        lakeAreas[index].status = LakePageStatus.idle;
        success?.call();
        notifyListeners();
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
        lakeAreas[index].status = LakePageStatus.error;
        failure?.call(e);
        notifyListeners();
      },
    );
  }

  getClipboardWeKoContents(BuildContext context) async {
    ClipboardData clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text.trim() != '') {
      String weCo = clipboardData.text.trim();
      RegExp regExp = RegExp(r'(wpy):\/\/(school_project)\/');
      if (regExp.hasMatch(weCo)) {
        var id = RegExp(r'\d{1,}').stringMatch(weCo);
        if (CommonPreferences().feedbackLastWeCo.value != id &&
            CommonPreferences().feedbackToken.value != "") {
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
                    CommonPreferences().feedbackLastWeCo.value = id;
                  } else {
                    CommonPreferences().feedbackLastWeCo.value = id;
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
}
