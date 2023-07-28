import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:image_size_getter_http_input/image_size_getter_http_input.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/lost_and_found_post.dart';
import 'package:we_pei_yang_flutter/feedback/view/lost_and_found_page/lost_and_found_home_page.dart';

// 失物招领帖子详情页
class LostAndFoundDetailPage extends StatelessWidget {
  final LostAndFoundPost post;

  LostAndFoundDetailPage({required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LostAndFoundDetailAppBar(
        leading: Padding(
          padding: EdgeInsetsDirectional.only(start: 8, bottom: 8),
          child: WButton(
            child: WpyPic(
              'assets/svg_pics/laf_butt_icons/back_black.svg',
              width: 20.w,
              height: 20.w,
            ),
            onPressed: () {
              Navigator.pop(context);
            },

            ///to do
          ),
        ),
        action: Padding(
          padding: EdgeInsetsDirectional.only(end: 20, bottom: 12),
          child: WButton(
            child: WpyPic(
              'assets/svg_pics/laf_butt_icons/ph_cube-bold.svg',
              width: 20.w,
              height: 20.w,
            ),
            onPressed: () {},

            ///to do
          ),
        ),
        title: Text(''),
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
                              'assets/images/icon_peiyang.png',
                              width: 32,
                              height: 32,
                            ),
                            SizedBox(width: 13),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '创作者某某',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 6),
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
                      '急!狗丢了!!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Image.asset(
                      'assets/images/schedule_empty.png',
                      width: 360,
                      height: 204,
                    ),
                    SizedBox(height: 14),
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
                              SizedBox(width: 2),
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
                          '11445次浏览',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF909090),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 28),
                    Text(
                      '求好心人带回可爱柴柴求好心人带回可爱柴柴求好心人带回可爱柴柴求好心人带回可爱柴柴求好心人带回可爱柴柴求好心人带回可爱柴柴',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 28),
                    Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '丢失日期',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '2023-03-31',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2C7EDF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                    Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '丢失地点',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
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
                    SizedBox(height: 92),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Color(0xFF2C7EDF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '我找到了',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/schedule_empty.png',
                              width: 24,
                              height: 20,
                            ),
                            SizedBox(width: 10),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Color(0xFF2C7EDF),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '擦亮',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF2C7EDF),
                                ),
                              ),
                            ),
                          ],
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
