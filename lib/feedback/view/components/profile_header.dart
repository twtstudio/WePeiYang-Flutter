import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:we_pei_yang_flutter/auth/auth_router.dart';
import 'package:we_pei_yang_flutter/auth/view/settings/setting_page.dart';
import 'package:we_pei_yang_flutter/auth/view/user/user_avatar_image.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/message/model/message_provider.dart';

import 'change_nickname_dialog.dart';

class ProfileHeader extends StatelessWidget {
  final Widget child;
  final String date;

  const ProfileHeader({this.child, this.date});

  @override
  Widget build(BuildContext context) {
    double _width = ScreenUtil.defaultSize.width;
    return CustomScrollView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: ColorUtil.bold42TextColor,
              size: 20.w,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "我的湖底",
            style: TextUtil.base.NotoSansSC.black2A.w600.sp(18),
          ),
          centerTitle: true,
          actions: [FeedbackMailbox()],
        ),
        SliverToBoxAdapter(
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 90.h,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r)),
                    child: Container(
                      color: Colors.white,
                      height: 100.h,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: CommonPreferences.isAprilFoolHead.value
                          ? BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/lake_butt_icons/jokers.png'),
                                  fit: BoxFit.contain),
                            )
                          : BoxDecoration(),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB((_width - 80) / 6, 20,
                            (_width - 80) / 15, (_width - 80) / 6),
                        child: UserAvatarImage(
                            size: (_width - 80) / 3, iconColor: Colors.white),
                      ),
                    ),
                    // SizedBox(width: (ScreenUtil.defaultSize.width - 60) / 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                  width: WePeiYangApp.screenWidth / 3,
                                  child: Text(
                                      CommonPreferences.lakeNickname.value,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 4,
                                      style: TextUtil
                                          .base.ProductSans.white.w700
                                          .sp(20))),
                              InkWell(
                                onTap: () => showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (BuildContext context) =>
                                        ChangeNicknameDialog()),
                                child: Padding(
                                  padding: EdgeInsets.all(4.w),
                                  child: SvgPicture.asset(
                                    'assets/svg_pics/lake_butt_icons/edit.svg',
                                    width: 18.w,
                                    color: ColorUtil.mainColor,
                                  ),
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(CommonPreferences.userNumber.value,
                                    textAlign: TextAlign.start,
                                    style: TextUtil
                                        .base.ProductSans.black4E.w700
                                        .sp(14)),
                                SizedBox(
                                  width: 20.w,
                                ),
                                Text(
                                    "MPID: ${CommonPreferences.lakeUid.value.toString().padLeft(6, '0')}",
                                    textAlign: TextAlign.start,
                                    style: TextUtil
                                        .base.ProductSans.black4E.w700
                                        .sp(14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class FeedbackMailbox extends StatefulWidget {
  @override
  _FeedbackMailboxState createState() => _FeedbackMailboxState();
}

class _FeedbackMailboxState extends State<FeedbackMailbox> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pushNamed(context, FeedbackRouter.mailbox),
        onLongPress: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return LakeDialogWidget(
                title: '一键已读：',
                titleTextStyle:
                    TextUtil.base.normal.black2A.NotoSansSC.sp(18).w600,
                content: Text('这将清除所有的消息提醒'),
                cancelText: "取消",
                confirmTextStyle:
                    TextUtil.base.normal.white.NotoSansSC.sp(16).w600,
                cancelTextStyle:
                    TextUtil.base.normal.black2A.NotoSansSC.sp(16).w400,
                confirmText: "确认",
                cancelFun: () {
                  Navigator.pop(context);
                },
                confirmFun: () async {
                  await context.read<MessageProvider>().setAllMessageRead();
                  Navigator.pop(context);
                },
                confirmButtonColor: ColorUtil.selectionButtonColor,
              );
            }),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AuthRouter.mailbox),
              child: Icon(
                Icons.email_outlined,
                size: 28,
                color: Color.fromRGBO(255, 255, 255, 1),
              ),
            ),
            SizedBox(width: 15),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AuthRouter.setting,
                      arguments: SettingPageArgs(false))
                  .then((value) => this.setState(() {})),
              child: Image.asset(
                'assets/images/setting.png',
                width: 24,
                height: 24,
                color: Color.fromRGBO(255, 255, 255, 1),
              ),
            ),
          ],
        ),

        // SizedBox(
        //   height: 45,
        //   width: 45,
        //   child: Center(
        //     child: FeedbackBadgeWidget(
        //       child: SvgPicture.asset(
        //         'assets/svg_pics/lake_butt_icons/bell.svg',
        //         width: 16.w,
        //       ),
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
