import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/user_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/loading_dot.dart';

import '../modle/rating/rating_page_data.dart';
import '../ui/base64_image_ui.dart';
import '../ui/star_ui.dart';



/************************
 * 用于创建评论
 * English: Used to create comments
 ************************/

class CreateComment extends StatefulWidget {
  final DataIndex dataIndex;
  double ratingValue;
  CreateComment({required this.dataIndex,required this.ratingValue});
  @override
  State<StatefulWidget> createState() {
    return _CreateCommentState();
  }
}

class _CreateCommentState extends State<CreateComment> {

  /************************
   * 初始化数据
   * English: Initialize data
   ************************/
  //评分对象名称~
  final TextEditingController commentContent = TextEditingController();
  String objectImageBase64 = " ";

  /************************
   * 获取相对长度
   ************************/
  double _getMM(BuildContext context){
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * 0.9 / 60; //获取现实中1毫米的像素长度
  }

  /************************
   * 顶部的UI~,显示当前页面的信息
   * 退回键,等等
   * English: Top UI~, display the information of the current page
   ************************/
  PreferredSizeWidget _topUI(BuildContext context) {
    double mm = _getMM(context);
    return AppBar(
      leading: IconButton(
        color: Colors.black,
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        '创建评论',
        style: TextStyle(
            fontSize: 3 * mm,
            color: Colors.black,
            fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  /************************
   * 用于弹出提示
   * English: Used to pop up prompts
   ************************/
  _print(BuildContext context,String message,Color color){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: color,
          content: Text(message),
          duration: Duration(seconds: 1), // 设置显示时间
        )
    );
  }

  /************************
   * 装饰条
   * English: Decorative strip
   ************************/
  Widget _decorativeStrip(BuildContext context) {
    double mm = _getMM(context);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 1 * mm,
      color: Colors.black.withOpacity(0.8),
    );
  }

  /************************
   * 数据的验证
   * English: Data verification
   ************************/
  (String,Color) _checkData(){
    if(commentContent.text.length < 1){
      return ("评论内容不能为空",Colors.red);
    }
    if(commentContent.text.length > 100){
      return ("评论内容过长",Colors.red);
    }
    if(widget.ratingValue>5 || widget.ratingValue<0){
      return ("评分不合法",Colors.red);
    }
    return ("上传中",Colors.blue);
  }

  /************************
   * 评分条
   * English: Rating bar
   ************************/
  Widget _ratingBar(BuildContext context) {
    double mm = _getMM(context);
    return Container(
      height: 10 * mm,
      child: RatingBar.builder(
        initialRating: widget.ratingValue,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        itemSize: 6 * mm,
        itemBuilder: (context, _) =>
            Icon(
              Icons.star,
              color: Colors.lightBlue,
            ),
        onRatingUpdate: (rating) {
          widget.ratingValue = rating;
        },
      ),
    );
  }

  /************************
   * 输入框
   * English: Upload button
   ************************/
  Widget _inputBox(BuildContext context) {
    double mm = _getMM(context);
    return Center(
      child: Container(
        height: 20 * mm,
        width: MediaQuery.of(context).size.width * 0.9,
        child: TextField(
          maxLines: null, // 设置为null以允许输入多行文本
          controller: commentContent,
          decoration: InputDecoration(
            hintText: "输入评论",
            hintStyle:
            TextStyle(fontSize: 4 * mm,
                color: Colors.black,
                fontWeight: FontWeight.bold),
            border: UnderlineInputBorder(),
          ),
        ),
      ),
    );
  }

  /************************
   * 用于上传数据~
   * English: Used to upload data~
   ************************/
  _createComment(BuildContext context) async {
    //首先构造叶片
    DataIndexLeaf commentLeaf = DataIndexLeaf();
    //构造评论数据
    Map<String, String> commentData = {
      'objectId': widget.dataIndex.dataId,
      'commentCreator': myUserId,
      'commentContent': commentContent.text,
      'ratingValue': widget.ratingValue.toString(),
    };
    //发送评论
    try{
      await commentLeaf.create('comment', commentData);
      assert(commentLeaf.isSucceed("create"));
      _print(context, "发送成功", Colors.green);

    }
    catch(e) {
      _print(context, "网络错误:"+commentLeaf.dataM["create"].toString(), Colors.red); // 设置显示时间
    }
  }

  /************************
   * 上传按钮
   * English: `Upload` button
   ************************/
  Widget _uploadButton(BuildContext context) {
    double mm = _getMM(context);
    return FloatingActionButton(
      onPressed: () =>
      {
        _print(
            context,
            _checkData().$1,
            _checkData().$2
        ),
        if(_checkData().$1 == "上传中")
          _createComment(context)
      },
      child: Icon(
        size: 6 * mm,
        Icons.upload,
        color: Colors.white,
      ),
      backgroundColor: Colors.blue.withOpacity(0.8),
      elevation: 0,
    );
  }

  /************************
   * 主体UI
   * English: Main UI
   ************************/
  @override
  Widget build(BuildContext context) {
    double mm = _getMM(context);
    return Scaffold(
      appBar: _topUI(context),
      body: Column(
        children: [
          _decorativeStrip(context),
          Container(height: 4 * mm),
          _ratingBar(context),
          Container(height: 4 * mm),
          _decorativeStrip(context),
          Container(height: 4 * mm),
          _inputBox(context),
          Container(height: 4 * mm),
          _decorativeStrip(context),
          Container(height: 4 * mm),
          _uploadButton(context)
        ],
      ),
    );
  }
}
