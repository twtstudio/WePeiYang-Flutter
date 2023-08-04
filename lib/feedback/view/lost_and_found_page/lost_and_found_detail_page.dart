import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/lost_and_found_post.dart';
import 'package:we_pei_yang_flutter/feedback/view/lost_and_found_page/lost_and_found_home_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/report_question_page.dart';

import 'lost_and_found_report_page.dart';

class LostAndFoundDetailAppBar extends LostAndFoundAppBar {
  LostAndFoundDetailAppBar({
    Key? key,
    required Widget leading,
    required Widget action,
    required Widget title,
    required double height,
  }) : super(
          key: key,
          leading: leading,
          action: action,
          title: title,
          height: height,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65.h,
      color: Colors.white, // Change the background color to white
      child: Stack(
        children: [
          Positioned(
            left: 0.w,
            bottom: 0.h,
            child: leading,
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: title,
          ),
          Positioned(
            right: 0.w,
            bottom: 0.h,
            child: action,
          )
        ],
      ),
    );
  }
}

class LostAndFoundDetailPage extends StatefulWidget {
  final int postId;
  final bool findOwner;

  LostAndFoundDetailPage({required this.postId, required this.findOwner});

  @override
  _LostAndFoundDetailPageState createState() => _LostAndFoundDetailPageState();
}

class _LostAndFoundDetailPageState extends State<LostAndFoundDetailPage> {
  bool brightened = false;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchPost(widget.postId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return buildDetailUI(context, snapshot.data!, widget.findOwner);
        } else if (snapshot.hasError) {
          return Center(
            child: Text("获取失败: ${snapshot.error}"),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Future<LostAndFoundPost?> fetchPost(int id) {
    Completer<LostAndFoundPost?> completer = Completer();
    try {
      FeedbackService.getLostAndFoundPostDetail(
          id: id,
          onResult: (p) {
            completer.complete(p);
          },
          onFailure: (e) {
            // 处理错误
          });
    } catch (e) {
      // 处理错误
    }
    return completer.future;
  }

  // 构建UI
  Widget buildDetailUI(BuildContext context, LostAndFoundPost post, findOwner) {
    // 寻物或寻主，待对接
    String phoneNum = '';

    void _showConfirmationDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: Colors.white,
            content: Container(
                width: 280.w,
                height: 150.h,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Image.asset(
                    'assets/images/tip.png',
                    width: 28.w,
                    height: 28.h,
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    phoneNum != ''
                        ? phoneNum + '\n'
                        : (findOwner
                            ? '确定是你遗失的吗？\n每天最多只能获取三次联系方式哦'
                            : '确定找到了吗？\n每天最多只能获取三次联系方式哦'),
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 10.w,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all<Size>(
                                  Size(110, 40)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                            child: Text(
                              '取消',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                phoneNum = post.phone;
                              });
                              Navigator.of(context).pop();
                              _showConfirmationDialog();
                            },
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all<Size>(
                                  Size(110, 40)),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color.fromRGBO(44, 126, 223, 1)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                            child: Text(
                              '确定',
                              style: TextStyle(
                                color: Colors.white,
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ))
                ])),
          );
        },
      );
    }

    String _formatDate(String originalString) {
      DateTime parsedDate = DateTime.parse(originalString.substring(0, 4) +
          '-' +
          originalString.substring(4, 6) +
          '-' +
          originalString.substring(6, 8) +
          ' ' +
          originalString.substring(8, 10) +
          ':' +
          originalString.substring(10, 12) +
          ':' +
          originalString.substring(12, 14));
      String isoDate = parsedDate.toIso8601String();
      return isoDate.substring(0, isoDate.length - 4).replaceAll('T', ' ');
    }

    void _showMenu() {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    Card(
                      color: Colors.white.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          {
                            String weCo =
                                '我在微北洋发现了个有趣的问题【${post.title}】\n#MP${post.id} ，你也来看看吧~\n将本条微口令复制到微北洋求实论坛打开问题 wpy://school_project/${post.id}';
                            ClipboardData data = ClipboardData(text: weCo);
                            Clipboard.setData(data);
                            CommonPreferences.feedbackLastWeCo.value =
                                post.id.toString();
                            ToastProvider.success('微口令复制成功，快去给小伙伴分享吧！');
                            FeedbackService.postShare(
                                id: post.id.toString(),
                                type: 0,
                                onSuccess: () {},
                                onFailure: () {});
                          }
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 42.0,
                          alignment: Alignment.center, // 居中对齐
                          child: Text(
                            '分享',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      color: Colors.white.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                      ),
                      child: InkWell(
                        onTap: () => {
                          Navigator.pushNamed(context, FeedbackRouter.report,
                              arguments: ReportPageArgs(post.id, true))
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 42.0,
                          alignment: Alignment.center, // 居中对齐
                          child: Text(
                            '举报',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Card(
                      color: Colors.white.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 42.0,
                          alignment: Alignment.center, // 居中对齐
                          child: Text(
                            '取消',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 20.h,
                      color: Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    // 使用post数据构建UI
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: LostAndFoundDetailAppBar(
        height: 65,
        leading: Padding(
          padding: EdgeInsets.only(top: 46.h, left: 16.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: WButton(
              child: WpyPic(
                'assets/images/back.png',
                width: 30.w,
                height: 30.w,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              // Other onPressed logic goes here
            ),
          ),
        ),
        action: Padding(
          padding: EdgeInsets.only(top: 46.h, right: 16.w),
          child: Align(
            alignment: Alignment.centerRight,
            child: WButton(
              child: WpyPic(
                'assets/images/more-horizontal.png',
                width: 30.w,
                height: 30.w,
              ),
              onPressed: () {
                _showMenu();
              },
              // Other onPressed logic goes here
            ),
          ),
        ),
        title: Text('   '),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 91),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/school.png',
                              width: 32.w,
                              height: 32.h,
                            ),
                            SizedBox(width: 13.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.author,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    Text(
                                      _formatDate(post.detailedUploadTime),
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: Color(0xFF909090),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          '#MP${post.id.toString().padLeft(6, '0')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF909090),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    Text(
                      post.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Image.asset(
                      'assets/images/schedule_empty.png',
                      width: 360,
                      height: 204,
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color(0xFFF8F8F8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '#',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                '其他' + '  ',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF909090),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '11445次浏览' + '       ',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF909090),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 28.h),
                    Padding(
                      padding: EdgeInsets.all(7),
                      child: Text(
                        post.text,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5.h,
                          color: Color.fromRGBO(42, 42, 42, 1),
                        ),
                      ),
                    ),
                    SizedBox(height: 45.h),
                    Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('丢失日期',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 3.h),
                              Text(
                                  "${post.uploadTime.substring(0, 4)}-${post.uploadTime.substring(4, 6)}-${post.uploadTime.substring(6, 8)}",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF2C7EDF),
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h),
                    Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '丢失地点',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 15.w),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 3.h),
                                Text(
                                  post.location,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF2C7EDF),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ])
                        ],
                      ),
                    ),
                    SizedBox(height: 85.h),
                    Row(
                      children: [
                        SizedBox(
                          width: 10.w,
                        ),
                        Container(
                            width: 110.w,
                            height: 40.h,
                            margin: EdgeInsets.only(left: 30.w),
                            decoration: BoxDecoration(
                              color: Color(0xFF2C7EDF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: WButton(
                              child: Text(
                                findOwner ? '我遗失的' : '我找到了',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: _showConfirmationDialog,
                            )),
                        SizedBox(
                          width: 30.w,
                        ),
                        Container(
                          width: 110.w,
                          height: 40.h,
                          margin: EdgeInsets.only(left: 30.w),
                          decoration: BoxDecoration(
                            color: brightened ? Colors.grey[200] : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: brightened
                                ? null
                                : Border.all(
                                    color: Color(0xFF2C7EDF),
                                    width: 1.w,
                                  ),
                          ),
                          child: WButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  brightened
                                      ? 'assets/images/octicon_light-bulb-24-dark.png'
                                      : 'assets/images/octicon_light-bulb-24.png',
                                  width: 24.w,
                                  height: 20.h,
                                ),
                                SizedBox(
                                  width: 8.w,
                                ),
                                Text(
                                  brightened ? '已擦亮' : '擦亮',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: brightened
                                        ? Colors.grey
                                        : Color(0xFF2C7EDF),
                                  ),
                                ),
                              ],
                            ),
                            onPressed: brightened
                                ? null // 如果brightened为true，则禁用按钮
                                : () {
                                    setState(() {
                                      brightened = true;
                                    });
                                    ToastProvider.success('成功擦亮');
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
