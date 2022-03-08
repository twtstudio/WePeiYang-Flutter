import 'dart:io';

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';

class FbDepartmentsProvider {
  List<Department> departmentList = [];

  Future<void> initDepartments() async {
    await FeedbackService.getDepartments(
      CommonPreferences.feedbackToken.value,
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
  loading,
  idle,
  error,
}

class FbHomeStatusNotifier extends ChangeNotifier {
  FbHomePageStatus _status = FbHomePageStatus.loading;

  bool get isLoading => _status == FbHomePageStatus.loading;

  bool get isIdle => _status == FbHomePageStatus.idle;

  bool get isError => _status == FbHomePageStatus.error;

  void update(FbHomeListModel listProvider) {
    if (listProvider._status != _status) {
      _status = listProvider._status;
      notifyListeners();
    }
  }

  void toLoading() {
    _status = FbHomePageStatus.loading;
    notifyListeners();
  }
}

class FbHomeListModel extends ChangeNotifier {
  // map default is LinkedHashMap
  List<Map<int, Post>> _homeList = [{}, {}, {}];

  List<List<Post>> get allList => [
        _homeList[0].values.toList(),
        _homeList[1].values.toList(),
        _homeList[2].values.toList()
      ];

  int _postType = 2;
  int _totalPage = 0;
  int _currentPage = 0;

  FbHomePageStatus _status = FbHomePageStatus.loading;

  bool get isLastPage => _totalPage == _currentPage;

  int get postType => _postType;

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
        CommonPreferences.feedbackToken.value = token;
        provider.initDepartments();
        initPostList(type);
      },
      onFailure: (e) {
        _status = FbHomePageStatus.error;
        failure?.call(e);
        notifyListeners();
      },
    );
  }

  addSomeLoading() {
    _status = FbHomePageStatus.loading;
    notifyListeners();
  }

  loadingFailed() {
    _status = FbHomePageStatus.error;
    notifyListeners();
  }

  Future<void> initPostList(int type,
      {OnSuccess success, OnFailure failure, bool reset = false}) async {
    if (reset) {
      _status = FbHomePageStatus.loading;
      notifyListeners();
    }
    await FeedbackService.getPosts(
      type: '$type',
      page: '1',
      onSuccess: (postList, totalPage) {
        _homeList[type].clear();
        _addOrUpdateItems(postList, type);
        _currentPage = 1;
        _totalPage = totalPage;
        _status = FbHomePageStatus.idle;
        success?.call();
        notifyListeners();
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
        _status = FbHomePageStatus.error;
        failure?.call(e);
        notifyListeners();
      },
    );
  }
}
