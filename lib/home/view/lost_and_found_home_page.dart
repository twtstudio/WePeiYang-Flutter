import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/lost_and_found/lost_and_found_router.dart';
import 'package:we_pei_yang_flutter/lost_and_found/view/lost_and_found_notifier.dart';
import 'package:we_pei_yang_flutter/lost_and_found/view/lost_and_found_sub_page.dart';

import '../../commons/util/type_util.dart';

///我该怎么看到自己发布的所有帖子？

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
              appBar: AppBar(
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            WpyTheme.of(context)
                                .get(WpyColorKey.primaryActionColor),
                            WpyTheme.of(context)
                                .get(WpyColorKey.primaryLighterActionColor),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter),
                    ),
                  ),
                  leading: Padding(
                    padding: EdgeInsets.only(left: 20.w),
                    child: WButton(
                      child: WpyPic(
                        'assets/svg_pics/laf_butt_icons/back.svg',
                        width: 30.w,
                        height: 30.w,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  title: TabBar(
                    labelStyle: TextUtil.base.sp(20).bright(context).w600,
                    unselectedLabelStyle:
                        TextUtil.base.normal.sp(20).bright(context),
                    indicatorColor: Colors.white,
                    indicatorWeight: 2.h,
                    dividerHeight: 0,
                    tabs: [
                      Text('寻物'),
                      Text('寻主'),
                    ],
                  ),
                  actions: [
                    Padding(
                      padding: EdgeInsets.only(right: 20.w),
                      child: WButton(
                        child: WpyPic(
                          'assets/svg_pics/laf_butt_icons/ph_cube-bold.svg',
                          width: 24.w,
                          height: 24.w,
                        ),
                        onPressed: () {
                          ///仅用于测试，
                          // Navigator.pushNamed(
                          //     context,
                          //     LAFRouter.lafDetailPage,
                          //     //进入详细信息页面的时候要传这两个参数
                          //     arguments: Tuple2(2, true)
                          // );
                          //进入举报，历史页面的时候会有非空断言报错
                          // Navigator.pushNamed(
                          //     context, LAFRouter.lostAndFoundReportPage);
                          // Navigator.pushNamed(
                          //     context, LAFRouter.lostAndFoundHistoryPage);
                        },
                      ),
                    ),
                  ]),
              body: TabBarView(
                children: [
                  ///搜索框是否要放在subpage里？
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
              floatingActionButton: Padding(
                padding: EdgeInsets.only(bottom: 100.h),
                child: FloatingActionButton(
                  //floatingactionbutton自身是hero属性的小组件，不需要再添加hero部件，直接加herotag即可
                  heroTag: 'add',
                  //浮动按钮的背景色和形状是取决于自身的，不适应于子组件，存在在两个图层
                  shape: CircleBorder(),
                  backgroundColor:
                      WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
                  onPressed: () {
                    Navigator.pushNamed(
                        context, LAFRouter.lostAndFoundPostPage);
                  },
                  child: Container(
                    child: Icon(
                      Icons.add,
                      size: 40.w,
                      color: Colors.white,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              )),
        ));
  }

  @override
  void initState() {
    super.initState();
    context.read<LAFoundModel>().getClipboardWeKoContents(context);
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
              colors: [
                WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
                WpyTheme.of(context).get(WpyColorKey.primaryLighterActionColor),
              ]),
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
