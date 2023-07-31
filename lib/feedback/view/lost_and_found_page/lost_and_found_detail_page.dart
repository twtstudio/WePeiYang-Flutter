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

class LostAndFoundDetailPage extends StatelessWidget {
  final int postId;

  LostAndFoundDetailPage({required this.postId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchPost(postId),
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

  // 获取详情
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
                                Column(
                                  children: [
                                    Text(
                                      '2021-11-07',
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: Color(0xFF909090),
                                      ),
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
                      ' 急 ! 狗丢了 ! ! !',
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
                        '求好心人带回可爱柴柴求好心人带回可爱柴柴求好心人带回可爱柴柴求好心人带回可爱柴柴求好心人带回可爱柴柴求好心人带回可爱柴柴',
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
                            '图书馆到诚八沿途',
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
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '我找到了',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ])),
                        SizedBox(
                          width: 30.w,
                        ),
                        Container(
                          width: 110.w,
                          height: 40.h,
                          margin: EdgeInsets.only(left: 30.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Color(0xFF2C7EDF),
                              width: 1.w,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/octicon_light-bulb-24.png',
                                width: 24.w,
                                height: 20.h,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '擦亮',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF2C7EDF),
                                ),
                              ),
                            ],
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
