import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/we_ko_dialog.dart';

import '../feedback_router.dart';

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

class NewPostProvider {
  String title = "";
  String content = "";
  int type = 1;
  Department department;
  Tag tag = Tag();

  List<File> images = [];

  bool get check =>
      title.isNotEmpty &&
      content.isNotEmpty && ((type == 1 && department != null) || (type != 1));

  void clear() {
    title = "";
    content = "";
    type = 1;
    images = [];
    tag = Tag();
    department = null;
  }
}

class NewFloorProvider extends ChangeNotifier {
  int locate;
  int replyTo = 0;
  List<File> images = [];
  String floorSentContent = '';
  bool inputFieldEnabled = false;
  FocusNode focusNode = FocusNode();

  void inputFieldOpenAndReplyTo(int rep) {
    inputFieldEnabled = true;
    replyTo = rep;
    notifyListeners();
  }

  void inputFieldClose() {
    inputFieldEnabled = false;
    notifyListeners();
  }

  void clearAndClose() {
    focusNode.unfocus();
    inputFieldEnabled = false;
    replyTo = 0;
    images = [];
    notifyListeners();
  }
}

enum LakePageStatus {
  unload,
  loading,
  idle,
  error,
}

class LakeArea {
  final Map<int, Post> dataList;
  final RefreshController refreshController;
  final ScrollController controller;
  LakePageStatus status;
  int currentPage;

  LakeArea._(this.dataList, this.refreshController, this.controller,
      LakePageStatus unload);

  factory LakeArea.empty() {
    return LakeArea._(
        {}, RefreshController(), ScrollController(), LakePageStatus.unload);
  }
}

class LakeModel extends ChangeNotifier {
  Map<WPYTab, LakeArea> lakeAreas = {};
  List<WPYTab> lakeTabList = [];
  List<WPYTab> newPostTabList = [];
  int currentTab = 0;
  bool openFeedbackList = false, tabControllerLoaded = false, scroll = false, lockSaver = false;
  double opacity = 0;
  TabController tabController;
  ScrollController nController;
  int sortSeq;

  Future<void> initTabList() async {
    await FeedbackService.getTabList().then((tabList) {
          WPYTab oTab = WPYTab(id: 0, shortname: '全部', name: '全部');
          lakeTabList = [oTab];
          lakeTabList.addAll(tabList);
          lakeAreas.addAll({oTab: LakeArea.empty()});
          newPostTabList.clear();
          newPostTabList.addAll(tabList);
          tabList.forEach((element) {
            lakeAreas.addAll({element: LakeArea.empty()});
          });
          notifyListeners();
        }, onError: (e) {
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
    if (!scroll &&
        nController.offset !=
            nController.position.maxScrollExtent) {
      scroll = true;
      nController
          .animateTo(nController.position.maxScrollExtent,
              duration: Duration(milliseconds: 160), curve: Curves.decelerate)
          .then((value) => scroll = false);
    }
    //if (_refreshController.isRefresh) _refreshController.refreshCompleted();
  }

  void initLakeArea(
      WPYTab tab, RefreshController rController, ScrollController sController) {
    LakeArea lakeArea =
        new LakeArea._({}, rController, sController, LakePageStatus.unload);
    lakeAreas[tab] = lakeArea;
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
  void _addOrUpdateItems(List<Post> data, WPYTab tab) {
    data.forEach((element) {
      lakeAreas[tab]
          .dataList
          .update(element.id, (value) => element, ifAbsent: () => element);
    });
  }

  Future<void> getNextPage(WPYTab tab,
      {OnSuccess success, OnFailure failure}) async {
    await FeedbackService.getPosts(
      type: '${tab.id}',
      mode: sortSeq,
      page: lakeAreas[tab].currentPage + 1,
      onSuccess: (postList, page) {
        _addOrUpdateItems(postList, tab);
        lakeAreas[tab].currentPage += 1;
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

  checkTokenAndGetPostList(FbDepartmentsProvider provider, WPYTab tab, int mode,
      {OnSuccess success, OnFailure failure}) async {
    await FeedbackService.getToken(
      onResult: (token) {
        provider.initDepartments();
        initPostList(tab);
      },
      onFailure: (e) {
        lakeAreas[tab].status = LakePageStatus.error;
        failure?.call(e);
        notifyListeners();
      },
    );
  }

  Future<void> initPostList(WPYTab tab,
      {OnSuccess success, OnFailure failure, bool reset = false}) async {
    if (reset) {
      lakeAreas[tab].status = LakePageStatus.loading;
      notifyListeners();
    }
    await FeedbackService.getPosts(
      type: '${tab.id}',
      mode: sortSeq,
      page: '1',
      onSuccess: (postList, totalPage) {
        tabControllerLoaded = true;
        if (lakeAreas[tab].dataList != null) lakeAreas[tab].dataList.clear();
        _addOrUpdateItems(postList, tab);
        lakeAreas[tab].currentPage = 1;
        lakeAreas[tab].status = LakePageStatus.idle;
        success?.call();
        notifyListeners();
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
        lakeAreas[tab].status = LakePageStatus.error;
        failure?.call(e);
        notifyListeners();
      },
    );
  }

  ///微口令的识别
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
