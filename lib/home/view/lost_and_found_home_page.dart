import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/lost_and_found/lost_and_found_router.dart';
import 'package:we_pei_yang_flutter/lost_and_found/view/lost_and_found_notifier.dart';
import 'package:we_pei_yang_flutter/lost_and_found/view/lost_and_found_sub_page.dart';

class LostAndFoundHomePage extends StatefulWidget {
  LostAndFoundHomePage({Key? key}) : super(key: key);

  @override
  LostAndFoundHomePageState createState() => LostAndFoundHomePageState();
}

class LostAndFoundHomePageState extends State<LostAndFoundHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Scaffold(
              appBar: LostAndFoundAppBar(
                height: 97.h,
                leading: Padding(
                  padding: EdgeInsetsDirectional.only(start: 19.w,bottom: 9.h),
                  child: WButton(
                    child: WpyPic(
                      'assets/svg_pics/laf_butt_icons/back.svg',
                      width: 30.w,
                      height: 30.w,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    ///to do
                  ),
                ),
                action: Padding(
                  padding: EdgeInsetsDirectional.only(end: 22.w, bottom: 10.h),
                  child: WButton(
                    child: WpyPic(
                      'assets/svg_pics/laf_butt_icons/ph_cube-bold.svg',
                      width: 24.w,
                      height: 24.w,
                    ),
                    onPressed: () {},

                    ///to do
                  ),
                ),
                title: Padding(
                  padding: EdgeInsets.only(bottom: 5.h),
                  child: TabBar(
                    labelStyle: TextUtil.base.sp(20).white.w600,
                    unselectedLabelStyle: TextUtil.base.normal.sp(20).white,
                    labelPadding:
                        EdgeInsetsDirectional.only(start: 52.w, end: 50.w),
                    isScrollable: true,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorColor: Colors.white,
                    indicatorWeight: 2.h,
                    tabs: [
                      Text('寻物'),
                      Text('寻主'),
                    ],
                  ),
                ),
              ),
              body: Stack(
                children: [
                  Container(
                    child: TabBarView(
                      children: [
                        LostAndFoundSubPage(
                          type: '寻物启事',
                          findOwner: false,
                        ),
                        LostAndFoundSubPage(
                          type: '失物招领',
                          findOwner: true,
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: ScreenUtil().bottomBarHeight + 90.h,
                    right: 20.w,
                    child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Container(
                          height: 52.r,
                          width: 52.r,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/add_post.png"),
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context,
                              LostAndFoundRouter.lostAndFoundPostPage);
                        }),
                  )
                ],
              )),
        ));
  }

  @override
  void initState() {
    super.initState();
    context.read<LostAndFoundModel>().getClipboardWeKoContents(context);
  }
}

class LostAndFoundAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Widget leading;
  final Widget action;
  final Widget title;
  final double height;

  LostAndFoundAppBar(
      {Key? key,
      required this.leading,
      required this.action,
      required this.title,
      required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [ColorUtil.blue2CColor, ColorUtil.blue64Color]),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0.w,
              bottom: 0.h,
              child: leading,
            ),
            Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Padding(
                padding: EdgeInsetsDirectional.only(bottom: 3.5.h),
                child: title,
              ),
            ),
            Positioned(right: 0.w, bottom: 0.h, child: action)
          ],
        ));
  }

  @override
  Size get preferredSize => Size(ScreenUtil().screenWidth, 60.h);
}
