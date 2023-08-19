import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/view/image_view/local_image_view_page.dart';

class MapCalenderPage extends StatefulWidget {
  MapCalenderPage();

  @override
  MapCalenderState createState() => MapCalenderState();
}

class MapCalenderState extends State<MapCalenderPage> {
  MapCalenderState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          titleSpacing: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(
              CupertinoIcons.back,
              color: Color(0XFF252525),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            '地图·校历',
            style: TextUtil.base.NotoSansSC.black2A.w600.sp(18),
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: MapAndCalender(),
            )));
  }
}

class MapAndCalender extends StatefulWidget {
  const MapAndCalender({Key? key}) : super(key: key);

  @override
  State<MapAndCalender> createState() => MapAndCalenderState();
}

class MapAndCalenderState extends State<MapAndCalender> {
  BoxDecoration get cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: EdgeInsets.only(left: 28.w),
        child: Text(
          '校园地图',
          style: TextUtil.base.PingFangSC.black00.bold.sp(14),
        ),
      ),
      SizedBox(
        height: 126.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.only(left: 16.h),
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, FeedbackRouter.localImageView,
                    arguments: LocalImageViewPageArgs([], [
                      'assets/images/account/map_wei_jin.jpg',
                      'assets/images/account/map_pei_yang.jpg'
                    ], 2, 0));
              },
              child: Stack(
                children: [
                  Container(
                      width: 250.h,
                      height: 100.h,
                      margin: EdgeInsets.fromLTRB(0, 10.h, 18.h, 16.h),
                      decoration: cardDecoration.copyWith(
                          image: DecorationImage(
                              alignment: Alignment.topCenter,
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Color(0xFFBED1FF), BlendMode.screen),
                              image: AssetImage(
                                  'assets/images/account/map_wei_jin.jpg')))),
                  Positioned(
                    top: 20.h,
                    left: 14.h,
                    child: Opacity(
                      opacity: 0.34,
                      child: Text(
                        '卫津路校区',
                        style: TextUtil.base.PingFangSC.black4E.w900.sp(22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, FeedbackRouter.localImageView,
                    arguments: LocalImageViewPageArgs([], [
                      'assets/images/account/map_wei_jin.jpg',
                      'assets/images/account/map_pei_yang.jpg'
                    ], 2, 1));
              },
              child: Stack(
                children: [
                  Container(
                      width: 250.h,
                      height: 100.h,
                      margin: EdgeInsets.fromLTRB(0, 10.h, 18.h, 16.h),
                      decoration: cardDecoration.copyWith(
                          image: DecorationImage(
                              alignment: Alignment.center,
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Color(0xFFFFF2F2), BlendMode.hardLight),
                              image: AssetImage(
                                  'assets/images/account/map_pei_yang.jpg')))),
                  Positioned(
                    top: 20.h,
                    left: 14.h,
                    child: Opacity(
                      opacity: 0.34,
                      child: Text(
                        '北洋园校区',
                        style: TextUtil.base.PingFangSC.black4E.w900.sp(22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 28.w),
        child: Text(
          '校历',
          style: TextUtil.base.PingFangSC.black00.bold.sp(14),
        ),
      ),
      SizedBox(
        height: 126.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.only(left: 16.h),
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  FeedbackRouter.localImageView,
                  arguments: LocalImageViewPageArgs([], [
                    'assets/images/calender/first.jpg',
                    'assets/images/calender/second.jpg'
                  ], 2, 0),
                );
              },
              child: Stack(
                children: [
                  Container(
                      width: 250.h,
                      height: 100.h,
                      margin: EdgeInsets.fromLTRB(0, 10.h, 18.h, 16.h),
                      decoration: cardDecoration.copyWith(
                          image: DecorationImage(
                              alignment: Alignment.topCenter,
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Color(0xFFBED1FF), BlendMode.screen),
                              image: AssetImage(
                                  'assets/images/calender/first.jpg')))),
                  Positioned(
                    top: 20.h,
                    left: 14.h,
                    child: Opacity(
                      opacity: 0.34,
                      child: Text(
                        '23-24第一学期',
                        style: TextUtil.base.PingFangSC.black4E.w900.sp(22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  FeedbackRouter.localImageView,
                  arguments: LocalImageViewPageArgs([], [
                    'assets/images/calender/first.jpg',
                    'assets/images/calender/second.jpg'
                  ], 2, 0),
                );
              },
              child: Stack(
                children: [
                  Container(
                      width: 250.h,
                      height: 100.h,
                      margin: EdgeInsets.fromLTRB(0, 10.h, 18.h, 16.h),
                      decoration: cardDecoration.copyWith(
                          image: DecorationImage(
                        alignment: Alignment.topCenter,
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Color(0xFFBED1FF), BlendMode.screen),
                        image: AssetImage('assets/images/calender/second.jpg'),
                      ))),
                  Positioned(
                    top: 20.h,
                    left: 14.h,
                    child: Opacity(
                      opacity: 0.34,
                      child: Text(
                        '23-24第二学期',
                        style: TextUtil.base.PingFangSC.black4E.w900.sp(22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}
