import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/view/lost_and_found_page/lost_and_found_post_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/lost_and_found_page/lost_and_found_sub_page.dart';

class LostAndFoundHomePage extends StatefulWidget {

  LostAndFoundHomePage({Key? key}) : super(key: key);

  @override
  LostAndFoundHomePageState createState()=> LostAndFoundHomePageState();
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
              leading: Padding(
                padding: EdgeInsetsDirectional.only(start: 8, bottom: 8),
                child: WButton(
                  child: WpyPic(
                    'assets/svg_pics/laf_butt_icons/back.svg',
                    width: 28.w,
                    height: 28.w,
                  ),
                  onPressed: (){}, ///to do
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
                  onPressed: (){}, ///to do
                ),
              ),
              title: Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: TabBar(
                  labelStyle: TextUtil.base.bold.sp(22),
                  unselectedLabelStyle: TextUtil.base.normal.sp(22),
                  labelPadding: EdgeInsetsDirectional.only(start: 55.w,end: 55.w),
                  isScrollable: true,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: Colors.white,
                  indicatorWeight: 2.5.h,
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
                      LostAndFoundSubPage(type: '寻物启事'),
                      LostAndFoundSubPage(type: '失物招领')
                    ],
                  ),
                ),
                Positioned(
                  bottom: ScreenUtil().bottomBarHeight + 90.h,
                  right: 20.w,
                  child: Hero(
                    tag: "addNewPost",
                    child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Container(
                          height: 72.r,
                          width: 72.r,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/add_post.png"),
                            ),
                          ),
                        ),
                        onTap: () {Navigator.of(context).push(
                            MaterialPageRoute(builder:(BuildContext context){
                              return LostAndFoundPostPage();
                            })
                        );}
                    ),
                  ),
                )
              ],
            )
          ),
        )
    );
  }
}

class LostAndFoundAppBar extends StatelessWidget implements PreferredSizeWidget {

  final Widget leading;
  final Widget action;
  final Widget title;
  const LostAndFoundAppBar({Key? key, required this.leading, required this.action, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 65.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blueAccent, Colors.lightBlueAccent]
          ),
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
              child: title,
            ),
            Positioned(
                right: 0.w,
                bottom: 0.h,
                child: action
            )
          ],
        )
    );
  }

  @override
  Size get preferredSize => Size(ScreenUtil().screenWidth, 60.h );
}
