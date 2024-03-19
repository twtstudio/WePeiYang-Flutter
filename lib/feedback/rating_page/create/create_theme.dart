import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/user_data.dart';
import 'package:we_pei_yang_flutter/main.dart';
import '../ui/base64_image_ui.dart';
import 'create_page_fun.dart';

final ImagePicker _picker = ImagePicker();

class CreateTheme extends StatefulWidget {
  @override
  CreateThemeState createState() => CreateThemeState();
}

class CreateThemeState extends State<CreateTheme> {
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
  (String,Color) isDataComplete() {
    //判断评分主题里有没有重名的
    for (int i = 0; i < 5; i++) {
      for (int j = i + 1; j < 5; j++) {
        if (objectName(i) == objectName(j)) {
          return ("对象重名了",Colors.red);
        }
      }
    }
    if (title().isEmpty || title().length > 10) {
      return ("标题长度不对",Colors.red);
    }
    if (description().isEmpty || description().length > 40) {
      return ("描述长度不对",Colors.red);
    }
    for (int i = 0; i < 5; i++) {
      if (objectName(i).isEmpty || objectName(i).length > 10) {
        return ("对象名称不对劲",Colors.red);
      }
      if (!objectImgList.containsKey(i)) {
        return ("好像图片没选全",Colors.red);
      }
    }
    //createTheme(context);
    return ("正在发送",Colors.black);
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
        // 检查文件大小是否大于2MB
        if (fileSizeInMB > 2) {
          debugOutput(context, utf8.decode(
              base64.decode(
                  "57uE5Lu25Lit5ZCr5pyJ5aSn6YeP5Zu+54mHLOWmguaenOWbvueJh+i/h+WkpyzlsLHkvJrmtarotLnlvojlpJrmtYHph48s5Zug5q2k5Zu+54mH5aSn5bCP5LiN5bqU6LaF6L+HMk1CX19fX0J5IOmdnuepuuabsuWlhw=="
              )
          ));
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
                        SnackBar(
                          backgroundColor: isDataComplete().$2,
                          content: Text(isDataComplete().$1),
                          duration: Duration(seconds: 1), // 设置显示时间
                        )
                    ),
                    (isDataComplete().$2==Colors.black)?createTheme(context):null,
                  },
                  child: Icon(
                    size: 6 * mm,
                    Icons.upload,
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.blue.withOpacity(0.8),
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

  /*************************************
   * 创建模块
   * 包含如下参数
   * 1.数据类型
   * 2.数据
   *************************************/
  createTheme(BuildContext context) async {
    //首先构造theme
    DataIndexLeaf themeLeaf = DataIndexLeaf();
    // 构建主题数据
    Map<String, String> themeData = {
      "themeName": title(),
      "themeDescribe": description(),
      "themeCreator": myUserId
    };
    Map<int,DataIndexLeaf> objectLeafL = {};

    for(int i = 0; i < 5; i++) {
      objectLeafL[i] = DataIndexLeaf();
    }

    int i=0;
    try{
      try{
        //powerDebug(context);
        await themeLeaf.create("theme", themeData);
        assert(themeLeaf.isSucceed("create"));
      }
      catch (e1){
        try{
          assert(themeLeaf.dataM["create"]!["error"]!=null);
        }
        catch(e2){
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text("创建主题失败:"+e1.toString()),
                duration: Duration(seconds: 1), // 设置显示时间
              )
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text("创建主题失败:"+themeLeaf.dataM["create"]!["error"]),
              duration: Duration(seconds: 1), // 设置显示时间
            )
        );
      }

      // 构建评分对象数据

      for (i = 0; i < 5; i++) {
        await objectLeafL[i]!.create("object", {
          "themeId": themeLeaf.dataM['create']!['succeed']!.toString(),
          "objectName": objectName(i),
          "objectImage": objectImg(i),
          "objectDescribe": " ",
          "objectCreator": myUserId,
          "objectRating": "0.0",
        });
        assert(objectLeafL[i]!.isSucceed("create"));
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('发送成功'),
          duration: Duration(seconds: 2), // 设置显示时间
        )
      );
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("网络错误:"+e.toString()+objectLeafL[i]!.dataM['create']!.toString().substring(0,40)),
            duration: Duration(seconds: 2), // 设置显示时间
          )
      );
    }



  }
}


