import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/user_data.dart';
import 'package:we_pei_yang_flutter/main.dart';

import '../ui/base64_image_ui.dart';
import 'create_theme.dart';

final ImagePicker _picker = ImagePicker();

class CreateObject extends StatefulWidget {
  final DataIndex themeIndex;
  CreateObject({required this.themeIndex});
  @override
  CreateObjectState createState() => CreateObjectState();
}

//懒得写了,直接继承复用
//但是createTheme写得太差劲,不许复用
//甚至国际化
//English: I'm too lazy to write, just inherit and reuse
//But createTheme is written too badly, not allowed to reuse
//Even internationalization
class CreateObjectState extends State<CreateObject> {

  /************************
   * 初始化数据
   * English: Initialize data
   ************************/
  //评分对象名称~
  final TextEditingController objectName = TextEditingController();
  String objectImageBase64 = " ";
  //评分对象描述~
  final TextEditingController objectDescription = TextEditingController();

  /************************
   * 图片选择器
   * English: Image selector
   ************************/
  // 异步函数来选择图片
  Future<void> _selectImage() async {
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
        objectImageBase64 = base64String;
      });
    } else {
      // 用户可能取消了图片选择
      print('No image selected.');
    }
  }

  /************************
   * 数据的验证
   * English: Data verification
   ************************/
  (String,Color)_checkDataAndUpdate(BuildContext context){
    if(objectName.text.length==0){
      return ("对象名称为空",Colors.red);
    }
    if(objectName.text.length>10){
      return ("对象名称太长了",Colors.red);
    }
    if(objectDescription.text.length==0){
      return ("对象描述为空",Colors.red);
    }
    if(objectDescription.text.length>40){
      return ("对象描述太长了",Colors.red);
    }
    if(objectImageBase64==" "){
      return ("图片没选",Colors.red);
    }
    return ("上传中",Colors.black);
  }

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
        '创建评分对象',
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
     * 用于输入对象名称的UI
     * English: UI for entering the object name
     ************************/
    Widget _objectNameUI(BuildContext context) {
      double mm = _getMM(context);
      return Container(
        width: 0.9*MediaQuery.of(context).size.width,
        child: TextField(
          controller: objectName,
          decoration: InputDecoration(
            hintText: "输入对象名称(最多10字)",
            hintStyle:
            TextStyle(fontSize: 4 * mm,
                color: Colors.black,
                fontWeight: FontWeight.bold),
            border: UnderlineInputBorder(),
          ),
        )
      );
    }

    /************************
     * 用于输入对象描述的UI
     * English: UI for entering the object description
     ************************/
    Widget _objectDescriptionUI(BuildContext context) {
      double mm = _getMM(context);
      return Row(
        children: [
          SizedBox(width: 4 * mm),
          Expanded(
            child: TextField(
              controller: objectDescription,
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
            "${objectDescription.text.length}/40",
            style: TextStyle(
              fontSize: 2 * mm,
              color: objectDescription.text.length > 40
                  ? Colors.red
                  : Colors.black,
            ),
          ),
          SizedBox(width: 4 * mm),
        ],
      );
    }

      /************************
       * 用于选择图片的UI
       * English: UI for selecting images
       ************************/
      Widget _selectImageUI(BuildContext context) {
        double mm = _getMM(context);
        return GestureDetector(
          onTap: () async {
            await _selectImage();
            setState(() {});
          },
          child: Container(
            width: 20 * mm,
            height: 20 * mm,
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
                  base64String: objectImageBase64,
                  width: 20 * mm,
                  height: 20 * mm,
                )
            ),
          )
        );
    }

    /************************
     * 上传按钮
     * English: Upload button
     ************************/
    Widget _uploadButton(BuildContext context) {
      double mm = _getMM(context);
      return FloatingActionButton(
        onPressed: () => {
          _print(
              context,
              _checkDataAndUpdate(context).$1,
              _checkDataAndUpdate(context).$2
          ),
          if(_checkDataAndUpdate(context).$2==Colors.black)
              _createObject(context)
        },
        child: Icon(
          size: 6 * mm,
          Icons.create_outlined,
          color: Colors.white,
        ),
        backgroundColor: Colors.black.withOpacity(0.8),
        elevation: 0,
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
     * 用于上传数据~
     * English: Used to upload data~
     ************************/
    _createObject(BuildContext context) async {
      //首先创建一个数据叶片嘛(万能的数据叶)
      DataIndexLeaf objectLeaf = DataIndexLeaf();
      //构造对象数据
      try{
        await objectLeaf.create("object", {
          "themeId" : widget.themeIndex.dataId,
          "objectName" : objectName.text,
          "objectImage" : objectImageBase64,
          "objectDescribe" : objectDescription.text,
          "objectCreator" : myUserId,
          "objectRating" : "0.0"
        }
        );
        assert(objectLeaf.isSucceed("create"));
        _print(context, "发送成功", Colors.green);
      }
      catch(e){
        _print(context, "发送失败", Colors.red);
        return;
      }
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
            duration: Duration(seconds: 2), // 设置显示时间
          )
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
            SizedBox(height: 4 * mm),
            _objectNameUI(context),
            SizedBox(height: 4 * mm),
            _objectDescriptionUI(context),
            SizedBox(height: 4 * mm),
            _selectImageUI(context),
            SizedBox(height: 4 * mm),
            _decorativeStrip(context),
            SizedBox(height: 4 * mm),
            _uploadButton(context),
          ],
        ),
      );
    }
}

