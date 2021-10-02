import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/post.dart';
import 'package:we_pei_yang_flutter/feedback/model/tag.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_service.dart';
import 'package:we_pei_yang_flutter/message/message_model.dart';

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

  List<Post> sortNormal() =>
      this..sort((a, b) => a.updatedTime.compareTo(b.updatedTime) * (-1));
}

class FeedbackNotifier with ChangeNotifier {
  List<Tag> _tagList = List();
  List<Post> _homePostList = List();
  List<Post> _profilePostList = List();
  List<String> _searchHistoryList = List();
  String _token;

  List<Tag> get tagList => _tagList;

  List<Post> get homePostList => _homePostList;

  List<Post> get profilePostList => _profilePostList;

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

  // TODO: Callback hell goes brrrrrrrrrr.
  Future<void> initHomePostList(onSuccess, onFailure) async {
    clearHomePostList();
    if (CommonPreferences().feedbackToken.value == "") {
      await FeedbackService.getToken(
        onResult: (token) {
          _token = token;
          CommonPreferences().feedbackToken.value = token;
          initTags(onSuccess, onFailure);
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
        },
      );
    } else {
      _token = CommonPreferences().feedbackToken.value;
      await initTags(onSuccess, onFailure);
    }
  }

  Future<void> initTags(onSuccess, onError) async {
    await FeedbackService.getTags(
      _token,
      onResult: (list) {
        _tagList.clear();
        _tagList.addAll(list);
        FeedbackService.getPosts(
          tagId: '',
          page: '1',
          onSuccess: (postList, totalPage) {
            _homePostList.addAll(postList);
            onSuccess(totalPage);
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
          },
        );
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
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
