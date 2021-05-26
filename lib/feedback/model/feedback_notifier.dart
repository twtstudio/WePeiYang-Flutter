import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/feedback/model/comment.dart';
import 'package:wei_pei_yang_demo/feedback/model/post.dart';
import 'package:wei_pei_yang_demo/feedback/model/tag.dart';
import 'package:wei_pei_yang_demo/feedback/util/http_util.dart';
import 'package:wei_pei_yang_demo/generated/l10n.dart';
import 'package:wei_pei_yang_demo/message/message_model.dart';

// TODO: Invoke this method when initialize [ProfilePage].
extension PostListSortExtension on List<Post> {
  List<Post> sortWithMessage(List<MessageDataItem> list) {
    if (list == null) return this;
    List<Post> match = [];
    List<int> ids = list.map((e) => e.questionId).toList();
    List<Post> base = [...this];
    this.forEach((element) {
      if (ids.contains(element.id)) {
        match.add(element);
        base.remove(element);
      }
    });
    match.sort((a, b) => a.updatedTime.compareTo(b.updatedTime) * (-1));
    base.sort((a, b) => a.updatedTime.compareTo(b.updatedTime) * (-1));
    return [...match, ...base];
  }
}

class FeedbackNotifier with ChangeNotifier {
  List<Tag> _tagList = List();
  List<Post> _homePostList = List();
  List<Post> _profilePostList = List();
  List<Comment> _officialCommentList = List();
  List<Comment> _commentList = List();
  List<String> _searchHistoryList = List();
  String _token;

  List<Tag> get tagList => _tagList;

  List<Post> get homePostList => _homePostList;

  List<Post> get profilePostList => _profilePostList;

  List<Comment> get officialCommentList => _officialCommentList;

  List<Comment> get commentList => _commentList;

  List<String> get searchHistoryList => _searchHistoryList;

  String get token => _token ?? CommonPreferences().feedbackToken.value;

  initSearchHistory() async {
    final _prefs = await SharedPreferences.getInstance();
    if (_prefs.getStringList('feedback_search_history') == null) {
      _prefs.setStringList('feedback_search_history', List());
      _searchHistoryList = List();
    } else {
      _searchHistoryList = _prefs.getStringList('feedback_search_history');
    }
    notifyListeners();
  }

  clearTagList() {
    _tagList.clear();
    notifyListeners();
  }

  clearHomePostList() {
    _homePostList.clear();
    notifyListeners();
  }

  clearProfilePostList() {
    _profilePostList.clear();
    notifyListeners();
  }

  clearCommentList() {
    _officialCommentList.clear();
    _commentList.clear();
  }

  addComments(List<Comment> officialCommentList, List<Comment> commentList) {
    print(officialCommentList);
    print(commentList);
    _officialCommentList.addAll(officialCommentList);
    _commentList.addAll(commentList);
    notifyListeners();
  }

  updateRating(double rating, index) {
    _officialCommentList[index].rating = (rating * 2).toInt();
    notifyListeners();
  }

  addHomePosts(List<Post> posts) {
    _homePostList.addAll(posts);
    notifyListeners();
  }

  changeProfilePostFavoriteState(index) {
    if (_profilePostList[index].isFavorite) {
      _profilePostList[index].isFavorite = false;
    } else {
      _profilePostList[index].isFavorite = true;
    }
    notifyListeners();
  }

  changeCommentLikeState(index) {
    if (_commentList[index].isLiked) {
      _commentList[index].likeCount--;
      _commentList[index].isLiked = false;
    } else {
      _commentList[index].likeCount++;
      _commentList[index].isLiked = true;
    }
    notifyListeners();
  }

  changeOfficialCommentLikeState(index) {
    if (_officialCommentList[index].isLiked) {
      _officialCommentList[index].likeCount--;
      _officialCommentList[index].isLiked = false;
    } else {
      _officialCommentList[index].likeCount++;
      _officialCommentList[index].isLiked = true;
    }
    notifyListeners();
  }

  // TODO: Callback hell goes brrrrrrrrrr.
  Future<void> initHomePostList(onSuccess, onFailure) async {
    clearHomePostList();
    if (CommonPreferences().feedbackToken.value == "") {
      await getToken(
        onSuccess: (token) {
          _token = token;
          log("token: ${token}");
          CommonPreferences().feedbackToken.value = token;
          initTags(onSuccess, onFailure);
        },
        onFailure: () {
          ToastProvider.error('校务专区登录失败, 请刷新');
        },
      );
    } else {
      _token = CommonPreferences().feedbackToken.value;
      await initTags(onSuccess, onFailure);
    }
  }

  Future<void> initTags(onSuccess, onError) async {
    await getTags(
      _token,
      onSuccess: (list) {
        _tagList.clear();
        _tagList.addAll(list);
        getPosts(
          tagId: '',
          page: '1',
          onSuccess: (postList, totalPage) {
            _homePostList.addAll(postList);
            onSuccess(totalPage);
          },
          onFailure: () {
            ToastProvider.error(S.current.feedback_get_post_error);
          },
        );
      },
      onFailure: () {
        ToastProvider.error('校务专区获取标签失败, 请刷新');
      },
    );
  }

  addSearchHistory(content) async {
    final _prefs = await SharedPreferences.getInstance();
    if (_searchHistoryList.contains(content)) {
      _searchHistoryList.remove(content);
    }
    _searchHistoryList.insert(0, content);
    _prefs.setStringList('feedback_search_history', _searchHistoryList);
    notifyListeners();
  }

  clearSearchHistory() async {
    searchHistoryList.clear();
    final _prefs = await SharedPreferences.getInstance();
    _prefs.setStringList('feedback_search_history', List());
    notifyListeners();
  }

  removeProfilePost(index) {
    _profilePostList.removeAt(index);
    notifyListeners();
  }

  changeHomePostLikeState(int index) {
    if (homePostList[index].isLiked) {
      homePostList[index].isLiked = false;
      homePostList[index].likeCount--;
    } else {
      homePostList[index].isLiked = true;
      homePostList[index].likeCount++;
    }
    notifyListeners();
  }

  changeProfilePostLikeState(int index) {
    if (profilePostList[index].isLiked) {
      profilePostList[index].isLiked = false;
      profilePostList[index].likeCount--;
    } else {
      profilePostList[index].isLiked = true;
      profilePostList[index].likeCount++;
    }
    notifyListeners();
  }

  changeHomePostFavoriteState(int index) {
    homePostList[index].isFavorite = !homePostList[index].isFavorite;
    notifyListeners();
  }

  addProfilePosts(List<Post> list) {
    profilePostList.addAll(list);
    notifyListeners();
  }
}
