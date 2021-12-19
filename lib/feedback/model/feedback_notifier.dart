import 'dart:io';

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';

class FbTagsProvider {
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

class NewPostProvider {
  String title = "";
  String content = "";
  int type = 1;
  Department department;
  Tag tag;

  List<File> images = [];

  bool get check => title.isNotEmpty && content.isNotEmpty && ((type == 1 && department != null) || (type == 0 && tag != null));
}

// class ReloadProvider with ChangeNotifier{
//
// }

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
}

class FbHomeListModel extends ChangeNotifier {
  // map default is LinkedHashMap
  Map<int, Post> _homeList = {};

  List<Post> get homeList => _homeList.values.toList();
  FbHomePageStatus _status = FbHomePageStatus.loading;
  int _postType = 2;
  int _totalPage = 0;
  int _currentPage = 0;

  bool get isLastPage => _totalPage == _currentPage;

  int get postType => _postType;

  // TODO: 是否要在进行操作时更新列表？
  void quietUpdateItem(Post post) {
    _homeList.update(
      post.id,
      (value) {
        value.isLike = post.isLike;
        value.isFav = post.isFav;
        value.likeCount = post.likeCount;
        return value;
      },
      ifAbsent: () => post,
    );
  }

  // 列表去重
  void _addOrUpdateItems(List<Post> data) {
    data.forEach((element) {
      _homeList.update(element.id, (value) => element, ifAbsent: () => element);
    });
  }

  Future<void> getNextPage(type, {OnSuccess success, OnFailure failure}) async {
    await FeedbackService.getPosts(
      type: '$type',
      page: _currentPage + 1,
      onSuccess: (postList, page) {
        _addOrUpdateItems(postList);
        _currentPage += 1;
        success?.call();
        notifyListeners();
      },
      onFailure: (e) {
        failure?.call(e);
      },
    );
  }

  checkTokenAndGetPostList(int type, FbTagsProvider provider,
      {OnSuccess success, OnFailure failure}) async {
    if (CommonPreferences().feedbackToken.value == "") {
      await FeedbackService.getToken(
        onResult: (token) {
          CommonPreferences().feedbackToken.value = token;
          provider.initDepartments();
          initPostList(type);
        },
        onFailure: (e) {
          _status = FbHomePageStatus.error;
          failure?.call(e);
          notifyListeners();
        },
      );
    } else {
      provider.initDepartments();
      initPostList(type);
    }
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
        _homeList.clear();
        _addOrUpdateItems(postList);
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
