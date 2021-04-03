import 'package:flutter/material.dart';

class Comment {
  int id;
  String content;
  int userId;
  int adminId;
  int likeCount;
  int rating;
  String createTime;
  String updatedTime;
  String userName;
  String adminName;
  bool isLiked;

  Comment({
    this.id,
    this.content,
    this.userId,
    this.adminId,
    this.likeCount,
    this.rating,
    this.createTime,
    this.updatedTime,
    this.userName,
    this.adminName,
    this.isLiked,
  });

  Comment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    content = json['contain'];
    userId = json['user_id'];
    adminId = json['admin_id'];
    likeCount = json['likes'];
    rating = json['score'];
    createTime = json['created_at'];
    updatedTime = json['updated_at'];
    userName = json['username'];
    adminName = json['admin_name'];
    isLiked = json['is_liked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['contain'] = this.content;
    data['user_id'] = this.userId;
    data['admin_id'] = this.adminId;
    data['likes'] = this.likeCount;
    data['created_at'] = this.createTime;
    data['updated_at'] = this.updatedTime;
    data['username'] = this.userName;
    data['admin_name'] = this.adminName;
    data['is_liked'] = this.isLiked;
    return data;
  }
}
