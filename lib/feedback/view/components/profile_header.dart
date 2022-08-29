import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:we_pei_yang_flutter/auth/auth_router.dart';
import 'package:we_pei_yang_flutter/auth/view/user/user_avatar_image.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/lounge/util/level_util.dart';
import 'change_nickname_dialog.dart';

class ProfileHeader extends StatefulWidget {
  final Widget child;
  final String date;

  const ProfileHeader({Key key, this.date, this.child}) : super(key: key);

  @override
  State<ProfileHeader> createState() => ProfileHeaderState();
}

class ProfileHeaderState extends State<ProfileHeader> {
  @override
  Widget build(BuildContext context) {
    double _width = ScreenUtil.defaultSize.width;
    return CustomScrollView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AuthRouter.mailbox),
              child: Icon(
                Icons.email_outlined,
                size: 28,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 15),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AuthRouter.setting)
                  .then((_) => this.setState(() {})),
              child: Image.asset(
                'assets/images/setting.png',
                width: 24,
                height: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
        SliverToBoxAdapter(
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 114.h),
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r)),
                    child: Container(color: Colors.white, height: 41.h),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(4, 80, 4, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AuthRouter.avatarCrop)
                            .then((_) => this.setState(() {}));
                      },
                      child: Container(
                        decoration: CommonPreferences.isAprilFoolHead.value
                            ? BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/lake_butt_icons/jokers.png'),
                                    fit: BoxFit.contain),
                              )
                            : BoxDecoration(),
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: Hero(
                          tag: 'avatar',
                          child: UserAvatarImage(
                            size: (_width - 80) / 3,
                            iconColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //SizedBox(height: 30.w),
                          Row(
                            children: [
                              ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: WePeiYangApp.screenWidth / 3,
                                  ),
                                  child: Text(
                                      CommonPreferences.lakeNickname.value,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextUtil
                                          .base.ProductSans.white.w700
                                          .sp(20))),
                              SizedBox(width: 10.w),
                              LevelUtil(
                                width: 40,
                                height: 20,
                                style: TextUtil.base.white.w100.sp(12),
                                level: CommonPreferences.level.value.toString(),
                              ),
                              SizedBox(width: 5.w),
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
                              ),
                            ],
                          ),
                          SizedBox(height: 13.w),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(CommonPreferences.userNumber.value,
                                  textAlign: TextAlign.start,
                                  style: TextUtil.base.ProductSans.black4E.w900
                                      .sp(14)),
                              SizedBox(width: 20.w),
                              Text(
                                  "MPID: ${CommonPreferences.lakeUid.value.toString().padLeft(6, '0')}",
                                  textAlign: TextAlign.start,
                                  style: TextUtil.base.ProductSans.black4E.w900
                                      .sp(14)),
                            ],
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
        widget.child,
      ],
    );
  }
}
