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
      backgroundColor: Colors.white,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '作者: ${post.author}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '类型: ${post.type}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '分类: ${post.category}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '时间: ${post.uploadTime}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '地点: ${post.location}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '联系电话: ${post.phone}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '详情:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                post.text,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              post.coverPhotoPath != null
                  ? Image.network(
                      post.coverPhotoPath!,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Text('No Cover Photo'),
            ],
          ),
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
