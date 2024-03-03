import 'package:flutter/material.dart';

import '../ui/star_ui.dart';

void showCommentDialog(BuildContext context, double rating) {
  String comment = ''; // 用于保存输入的评论内容

  double screenWidth = MediaQuery.of(context).size.width;
  double mm = screenWidth * 0.9 / 60; //获取现实中1毫米的像素长度

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('创建评论'),
        content: Container(
          height: 40*mm,
          child: Column(
            children: [
              StarUI(
                rating: rating,
                size: 6 * mm,
                onRatingUpdate: (rating) {
                  rating = rating;
                },
              ),
              Container(
                height: 20 * mm,
                child:  TextField(
                  maxLines: null, // 设置为null以允许输入多行文本
                  onChanged: (value) {
                    comment = value; // 更新评论内容
                  },
                  decoration: InputDecoration(
                    hintText: '输入评论',
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 关闭对话框
            },
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {


              Navigator.of(context).pop(); // 关闭对话框
            },
            child: Text('提交'),
          ),
        ],
      );
    },
  );
}