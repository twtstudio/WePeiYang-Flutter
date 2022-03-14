import 'dart:io';

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/home_page.dart';

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
      content.isNotEmpty &&
      ((type == 1 && department.id != null) || type == 0);

  void clear() {
    title = "";
    content = "";
    type = 1;
    images = [];
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

enum FbHomePageStatus {
  unload,
  loading,
  idle,
  error,
}

class FbHomeStatusNotifier extends ChangeNotifier {
  List<FbHomePageStatus> status = [FbHomePageStatus.loading];

  void update(FbHomeListModel listProvider) {
    status.clear();
    status.addAll(listProvider._status);
    notifyListeners();
  }

  void toLoading(int type) {
    status[type] = FbHomePageStatus.loading;
    notifyListeners();
  }
}

class FbHomeListModel extends ChangeNotifier {
  // map default is LinkedHashMap
  List<Map<int, Post>> _homeList = List.filled(100, Map());
  int current;

  List<Map<int, Post>> get list => _homeList;

  int _totalPage = 0;
  int _currentPage = 0;

  List<FbHomePageStatus> _status = [FbHomePageStatus.loading];

  bool get isLastPage => _totalPage == _currentPage;

  // // TODO: 是否要在进行操作时更新列表？
  // void quietUpdateItem(Post post, int type) {
  //   _homeList[type].update(
  //     post.id,
  //     (value) {
  //       value.isLike = post.isLike;
  //       value.isFav = post.isFav;
  //       value.likeCount = post.likeCount;
  //       value.favCount = post.favCount;
  //       return value;
  //     },
  //     ifAbsent: () => post,
  //   );
  // }
  // TODO: 是否要在进行操作时更新列表？
  void quietUpdateItem(Post post, int type) {
    _homeList[type].update(
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
  void _addOrUpdateItems(List<Post> data, int type) {
    data.forEach((element) {
      _homeList[type]
          .update(element.id, (value) => element, ifAbsent: () => element);
    });
  }

  Future<void> getNextPage(type, {OnSuccess success, OnFailure failure}) async {
    await FeedbackService.getPosts(
      type: '$type',
      page: _currentPage + 1,
      onSuccess: (postList, page) {
        _addOrUpdateItems(postList, type);
        _currentPage += 1;
        success?.call();
        notifyListeners();
      },
      onFailure: (e) {
        failure?.call(e);
      },
    );
  }

  justForGetConcentrate() {
    notifyListeners();
  }

  checkTokenAndGetPostList(FbDepartmentsProvider provider, int type,
      {OnSuccess success, OnFailure failure}) async {
    await FeedbackService.getToken(
      onResult: (token) {
        CommonPreferences().feedbackToken.value = token;
        provider.initDepartments();
        initPostList(type);
      },
      onFailure: (e) {
        _status[type] = FbHomePageStatus.error;
        failure?.call(e);
        notifyListeners();
      },
    );
  }

  addSomeLoading(int type) {
    _status[type] = FbHomePageStatus.loading;
    notifyListeners();
  }

  loadingFailed(int type) {
    _status[type] = FbHomePageStatus.error;
    notifyListeners();
  }

  Future<void> initPostList(int type,
      {OnSuccess success, OnFailure failure, bool reset = false}) async {
    if (reset) {
      _status[type] = FbHomePageStatus.loading;
      notifyListeners();
    }
    await FeedbackService.getPosts(
      type: '$type',
      page: '1',
      onSuccess: (postList, totalPage) {
        if (_homeList != null) _homeList[type].clear();
        _addOrUpdateItems(postList, type);
        _currentPage = 1;
        _totalPage = totalPage;
        if (type >= _status.length) {
          for (int i = _status.length; i < type; i++)
            _status.add(FbHomePageStatus.unload);
          _status.add(FbHomePageStatus.idle);
        } else
          _status[type] = FbHomePageStatus.idle;
        success?.call();
        notifyListeners();
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
        if (type >= _status.length) {
          for (int i = _status.length; i < type; i++)
            _status.add(FbHomePageStatus.unload);
          _status.add(FbHomePageStatus.idle);
        } else
          _status[type] = FbHomePageStatus.error;
        failure?.call(e);
        notifyListeners();
      },
    );
  }
}

class TabNotifier extends ChangeNotifier {
  List<WPYTab> tabLister;
  bool tagWrapShow = false;

  changeTagWrap() {
    tagWrapShow == null ? tagWrapShow = true : tagWrapShow = !tagWrapShow;
    notifyListeners();
  }

  Future<void> initTabList(
      {OnSuccess success, OnFailure failure, bool reset = false}) async {
    await FeedbackService.getTabList(
      onSuccess: (tabList) {
        tabLister = tabList;
        success?.call();
        notifyListeners();
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
        failure?.call(e);
        notifyListeners();
      },
    );
  }
}
