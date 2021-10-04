import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/post.dart';
import 'package:we_pei_yang_flutter/feedback/model/tag.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_service.dart';

class FbMainPageListProvider with ChangeNotifier {
  List<Post> _homePostList = [];

  List<Post> get homePostList => _homePostList;

  clearHomePostList() {
    _homePostList.clear();
    notifyListeners();
  }

  Future<void> initHomePostList(
      OnResult<int> onSuccess, OnFailure onFailure) async {
    clearHomePostList();
    if (CommonPreferences().feedbackToken.value == "") {
      await FeedbackService.getToken(
        onResult: (token) {
          CommonPreferences().feedbackToken.value = token;
          getHomePostListWithTagAndPage(onSuccess, onFailure);
        },
        onFailure: (e) => onFailure(e),
      );
    } else {
      getHomePostListWithTagAndPage(onSuccess, onFailure);
    }
  }

  Future<void> getHomePostListWithTagAndPage(
      OnResult<int> onSuccess, OnFailure onFailure,
      {String tag, int page}) async {
    FeedbackService.getPosts(
      tagId: tag ?? '',
      page: page ?? 1,
      onSuccess: (postList, totalPage) {
        _homePostList.addAll(postList);
        onSuccess(totalPage);
      },
      onFailure: (e) {
        onFailure(e);
      },
    );
  }
}

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