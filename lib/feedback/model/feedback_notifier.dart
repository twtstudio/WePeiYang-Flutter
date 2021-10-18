import 'dart:io';

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/network/tag.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';

class FbTagsProvider {
  List<Tag> tagList = List();

  Future<void> initTags() async {
    await FeedbackService.getTags(
      CommonPreferences().feedbackToken.value,
      onResult: (list) {
        tagList.clear();
        tagList.addAll(list);
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
  Tag tag;

  List<File> imgList = [];

  bool get check => title.isNotEmpty && content.isNotEmpty && tag?.id != -1;
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
}

class FbHomeListModel extends ChangeNotifier {
  // map default is LinkedHashMap
  Map<int, Post> _homeList = {};

  List<Post> get homeList => _homeList.values.toList();
  FbHomePageStatus _status = FbHomePageStatus.loading;
  int _totalPage = 0;
  int _currentPage = 0;

  bool get isLastPage => _totalPage == _currentPage;

  // TODO: 是否要在进行操作时更新列表？
  void quietUpdateItem(Post post) {
    _homeList.update(
      post.id,
      (value) {
        value.isLiked = post.isLiked;
        value.isFavorite = post.isFavorite;
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

  Future<void> getNextPage({OnSuccess success, OnFailure failure}) async {
    await FeedbackService.getPosts(
      tagId: '',
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

  checkTokenAndGetPostList({OnSuccess success, OnFailure failure}) async {
    if (CommonPreferences().feedbackToken.value == "") {
      await FeedbackService.getToken(
        onResult: (token) {
          CommonPreferences().feedbackToken.value = token;
          initPostList();
        },
        onFailure: (e) {
          _status = FbHomePageStatus.error;
          failure?.call(e);
          notifyListeners();
        },
      );
    } else {
      initPostList();
    }
  }

  Future<void> initPostList({OnSuccess success, OnFailure failure}) async {
    await FeedbackService.getPosts(
      tagId: '',
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
