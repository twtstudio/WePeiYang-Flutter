import 'package:flutter/material.dart';

class Post with ChangeNotifier {
  int id;
  String title;
  String content;
  int campus;
  int userId;
  int isSolved;
  int isCommentForbidden;
  int likeCount;
  String createTime;
  String updatedTime;
  String userName;
  int commentCount;
  List<String> imgUrlList;
  List<String> thumbImgUrlList;
  String topImgUrl;
  List<TagOfPost> tags;
  bool isLiked;
  bool isFavorite;
  bool isOwner;

  Post(
      {this.id,
      this.title,
      this.content,
      this.campus,
      this.userId,
      this.isSolved,
      this.isCommentForbidden,
      this.likeCount,
    this.createTime,
    this.updatedTime,
    this.userName,
    this.commentCount,
    this.imgUrlList,
    this.thumbImgUrlList,
    this.topImgUrl,
    this.tags,
    this.isLiked,
    this.isFavorite,
    this.isOwner});

  Post.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['name'];
    content = json['description'];
    campus = json['campus'];
    userId = json['user_id'];
    isSolved = json['solved'];
    isCommentForbidden = json['no_commit'];
    likeCount = json['likes'];
    createTime = json['created_at'];
    updatedTime = json['updated_at'];
    userName = json['username'];
    commentCount = json['msgCount'];
    if (json['url_list'] != null) {
      imgUrlList = new List<String>();
      json['url_list'].forEach((v) {
        imgUrlList.add(v);
      });
    }
    if (json['thumb_url_list'] != null) {
      thumbImgUrlList = new List<String>();
      json['thumb_url_list'].forEach((v) {
        thumbImgUrlList.add(v);
      });
    }
    topImgUrl = json['thumbImg'];
    if (json['tags'] != null) {
      tags = new List<TagOfPost>();
      json['tags'].forEach((v) {
        tags.add(new TagOfPost.fromJson(v));
      });
    }
    isLiked = json['is_liked'];
    isFavorite = json['is_favorite'];
    isOwner = json['is_owner'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.title;
    data['description'] = this.content;
    data['campus'] = this.campus;
    data['user_id'] = this.userId;
    data['solved'] = this.isSolved;
    data['no_commit'] = this.isCommentForbidden;
    data['likes'] = this.likeCount;
    data['created_at'] = this.createTime;
    data['updated_at'] = this.updatedTime;
    data['username'] = this.userName;
    data['msgCount'] = this.commentCount;
    // List.of(data['url_list']) = this.urlList;
    // if (this.urlList != null) {
    //   data['url_list'] = this.urlList.map((v) => v.toJson()).toList();
    // }
    // if (this.thumbUrlList != null) {
    //   data['thumb_url_list'] =
    //       this.thumbUrlList.map((v) => v.toJson()).toList();
    // }
    data['thumbImg'] = this.topImgUrl;
    if (this.tags != null) {
      data['tags'] = this.tags.map((v) => v.toJson()).toList();
    }
    data['is_liked'] = this.isLiked;
    data['is_owner'] = this.isOwner;
    return data;
  }
}

class TagOfPost with ChangeNotifier {
  int id;
  String name;

  TagOfPost({this.id, this.name});

  TagOfPost.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}
