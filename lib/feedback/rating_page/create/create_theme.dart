import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/user_data.dart';
import 'package:we_pei_yang_flutter/main.dart';

import '../ui/base64_image_ui.dart';

final ImagePicker _picker = ImagePicker();

class CreateTheme extends StatefulWidget {
  @override
  _CreateThemeState createState() => _CreateThemeState();
}

class _CreateThemeState extends State<CreateTheme> {
  //这个是标题哦
  final TextEditingController _titleController = TextEditingController();

  //这个是描述哦
  final TextEditingController _descriptionController = TextEditingController();

  //这个是评分对象名称哦,共五个
  final List<TextEditingController> _objectNameController =
      List.generate(10, (index) => TextEditingController());

  //这个是评分对象图片哦,共五个
  final Map<int, String> objectImgList = {};

  //获取标题
  String title() => _titleController.text;

  //获取描述
  String description() => _descriptionController.text;

  //获取评分对象名称
  String objectName(int index) => _objectNameController[index].text;

  //获取评分对象图片base64形式
  String objectImg(int index) => objectImgList[index]!;

  //验证数据有没有填写完整
  bool isDataComplete() {
    if (title().isEmpty || title().length > 10) {
      return false;
    }
    if (description().isEmpty || description().length > 40) {
      return false;
    }
    for (int i = 0; i < 5; i++) {
      if (objectName(i).isEmpty || objectName(i).length > 10) {
        return false;
      }
      if (!objectImgList.containsKey(i)) {
        return false;
      }
    }
    return true;
  }

  String fileToBase64(File file) {
    // 检查文件是否存在
    if (!file.existsSync()) {
      throw ArgumentError('文件不存在: ${file.path}');
    }
    // 将图片文件读取为字节列表
    List<int> imageBytes = file.readAsBytesSync();
    // 将字节列表转换为Base64编码
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  // 异步函数来选择图片
  Future<void> selectImage(int index) async {
    // 从图库中选择图片
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        File file = File(image.path);
        int fileSizeInBytes = file.lengthSync();
        double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
        // 检查文件大小是否大于4MB
        if (fileSizeInMB > 4) {
          debugOutput(context, "图片大小不应超过4MB(2024年2月)");
          return;
        }
        List<int> fileBytes = file.readAsBytesSync();
        // 对文件内容进行Base64编码
        String base64String = base64Encode(fileBytes);
        objectImgList[index] = base64String;
      });
    } else {
      // 用户可能取消了图片选择
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double mm = screenWidth * 0.9 / 60; //获取现实中1毫米的像素长度

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '创建评分主题',
          style: TextStyle(
              fontSize: 3 * mm,
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
          color: Colors.white,
          child: ListView(children: [
            Column(
              children: [
                SizedBox(height: 3 * mm),
                Container(
                  width: screenWidth,
                  height: 1 * mm,
                  color:Colors.black.withOpacity(0.8),
                ),
                SizedBox(height: 3 * mm),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05),
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "输入评分标题(最多10字)",
                      hintStyle:
                          TextStyle(fontSize: 4 * mm, color: Colors.black,fontWeight: FontWeight.bold),
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 4 * mm),
                Row(
                  children: [
                    SizedBox(width: 4 * mm),
                    Expanded(
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: null, // 允许输入多行
                        decoration: InputDecoration(
                          hintText: "输入简介(最多40字)",
                          hintStyle:
                              TextStyle(fontSize: 3 * mm, color: Colors.black),
                          border: UnderlineInputBorder(), // 无边框
                        ),
                        style: TextStyle(fontSize: 2 * mm, color: Colors.black),
                      ),
                    ),
                    Text(
                      "${_descriptionController.text.length}/40",
                      style: TextStyle(
                        fontSize: 2 * mm,
                        color: _descriptionController.text.length > 40
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                    SizedBox(width: 4 * mm),
                  ],
                ),
                SizedBox(height: 4 * mm),
                Container(
                  width: screenWidth,
                  height: 1 * mm,
                  color:Colors.black.withOpacity(0.8),
                ),
                SizedBox(height: 2 * mm),
                ...List.generate(5, (index) => buildItemWidget(mm, index))
                    .toList(),
                SizedBox(height: 3 * mm),
                Container(
                  width: screenWidth,
                  height: 1 * mm,
                  color:Colors.black.withOpacity(0.8),
                ),
                SizedBox(height: 3 * mm),
                //提交
                FloatingActionButton(
                  onPressed: () => {
                    ScaffoldMessenger.of(context).showSnackBar(
                        (isDataComplete())?
                        SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('发送中'),
                          duration: Duration(seconds: 3), // 设置显示时间
                        ):
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('数据不完整或有误'),
                          duration: Duration(seconds: 3), // 设置显示时间
                        )
                    ),
                    (isDataComplete())?createTheme(context):null,
                  },
                  child: Icon(
                    size: 6 * mm,
                    Icons.create_outlined,
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.black.withOpacity(0.8),
                  elevation: 0,
                ),


              ],
            ),
          ])),
    );
  }

  //图片选择器
  Widget buildItemWidget(double mm, int index) {
    return Container(
      height: 11 * mm,
      width: MediaQuery.of(context).size.width - 8 * mm,
      child: Column(
        children:[
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  await selectImage(index);
                  setState(() {});
                },
                child: objectImgList.containsKey(index)
                    ? Container(
                  width: 10 * mm,
                  height: 10 * mm,
                  decoration: BoxDecoration(
                    color: Colors.white, // 容器的背景颜色
                    borderRadius: BorderRadius.circular(8), // 圆角半径
                    border: Border.all(
                      color: Colors.black, // 边框颜色
                      width: 0.1*mm, // 边框宽度
                    ),
                  ),
                  child: IgnorePointer(
                    ignoring: true, // 设置为 true 即可让子组件不可触摸
                    child: Base64Image(
                      base64String: objectImg(index),
                      width: 10 * mm,
                      height: 10 * mm,
                    )
                  ),
                )
                    : Icon(
                  Icons.photo,
                  size: 10 * mm,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              Container(width: 4 * mm),
              Expanded(
                child:  TextField(
                  controller: _objectNameController[index],
                  decoration: InputDecoration(
                    hintText: '输入对象名称(最多10字)',
                    hintStyle: TextStyle(fontSize: 3 * mm, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ]
      )
    );
  }

  createTheme(BuildContext context) async {

    //首先构造theme
    DataIndexLeaf themeLeaf = DataIndexLeaf();
    // 构建主题数据
    Map<String, String> themeData = {
      "themeName": title(),
      "themeDescribe": description(),
      "themeCreator": myUserId
    };

    await themeLeaf.create("theme", themeData);
    //debugOutput(context, themeLeaf.log.toString());

    // 构建评分对象数据
    for (int i = 0; i < 1; i++) {
      DataIndexLeaf objectLeaf = DataIndexLeaf();
      Map<String, String> objectData = {
        "themeId": objectLeaf.dataM['succeed']!.toString(),
        "objectName": objectName(i),
        "objectImage": objectImg(i),
        "objectDescribe": " ",
        "objectCreator": myUserId,
        "objectRating": "0.0",
      };
      objectLeaf.create("object", objectData);
      //等待2s
      await Future.delayed(Duration(seconds: 2));
      debugOutput(context, objectLeaf.log.toString());
    }

  }
}

