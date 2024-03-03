import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/user_data.dart';

import '../modle/rating/rating_page_data.dart';
import '../ui/star_ui.dart';

void showCommentDialog(
    BuildContext context, double rating, DataIndex dataIndex) {
  String comment = ''; // 用于保存输入的评论内容

  double screenWidth = MediaQuery.of(context).size.width;
  double mm = screenWidth * 0.9 / 60; //获取现实中1毫米的像素长度

  bool isDataComplete(String comment) {
    return comment.length > 1 && comment.length < 100;
  }

  createComment(BuildContext context) async {
    //首先构造叶片
    DataIndexLeaf commentLeaf = DataIndexLeaf();
    //构造评论数据
    Map<String, String> commentData = {
      'objectId': dataIndex.dataId,
      'commentCreator': myUserId,
      'commentContent': comment,
      'ratingValue': rating.toString(),
    };
    //发送评论
    await commentLeaf.create('comment', commentData);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: Text('发送成功'),
      duration: Duration(seconds: 3), // 设置显示时间
    ));
  }
  //显示SnackBar
  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  showDialog(
    context: context,
    builder: (BuildContext thisContext) {
      return AlertDialog(
        title: Text('创建评论'),
        content: Container(
          height: 40 * mm,
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
                child: TextField(
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
          TextButton(
            onPressed: () {
              if(!isDataComplete(comment)){
                _showSnackBar(thisContext, '评论内容不对劲');
              }
              else{
                _showSnackBar(thisContext, '提交中');
                createComment(thisContext);
              }
              //(isDataComplete(comment)) ? createComment(thisContext) : null;
            },
            child: Text('提交'),
          ),
        ],
      );
    },
  );
}
