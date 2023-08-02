import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/lost_and_found_post.dart';
import 'package:we_pei_yang_flutter/feedback/view/lost_and_found_page/lost_and_found_home_page.dart';

class LostAndFoundDetailAppBar extends LostAndFoundAppBar {
  LostAndFoundDetailAppBar({
    Key? key,
    required Widget leading,
    required Widget action,
    required Widget title,
  }) : super(key: key, leading: leading, action: action, title: title);

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

  LostAndFoundDetailPage({required this.postId});

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
          return buildDetailUI(context, snapshot.data!);
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

  Future<LostAndFoundPost?> fetchPost(int id) async {
    LostAndFoundPost? post;
    try {
      post = await FeedbackService.getLostAndFoundPostDetail(
          id: id, onResult: (p) {}, onFailure: (e) {});
    } catch (e) {
      // 处理错误
    }
    return post;
  }

  // 构建UI
  Widget buildDetailUI(BuildContext context, LostAndFoundPost post) {
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
                        : '确定找到了吗？\n每天最多只能获取三次联系方式哦',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  Align(
                      alignment:Alignment.bottomCenter,
                      child:Row(
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
                              minimumSize:
                              MaterialStateProperty.all<Size>(Size(110, 40)),
                              shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
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
                              minimumSize:
                              MaterialStateProperty.all<Size>(Size(110, 40)),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color.fromRGBO(44, 126, 223, 1)),
                              shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
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
                      )
                  )
                ])),
          );
        },
      );
    }

    // 使用post数据构建UI
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: LostAndFoundDetailAppBar(
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
              onPressed: () {},
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
                                      post.uploadTime,
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: Color(0xFF909090),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 3.w,
                                    ),
                                    Text(
                                      '12:17:05',
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
                          '#MP000001',
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
                                '其他',
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
                          SizedBox(width: 15.w),
                          Text('2023-03-31',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF2C7EDF),
                                  fontWeight: FontWeight.w600)),
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
                          Text(
                            post.location,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2C7EDF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
                                '我找到了',
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
                            onPressed: () {
                              setState(() {
                                brightened = true;
                              });
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
