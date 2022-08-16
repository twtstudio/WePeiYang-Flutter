import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiOverlayStyle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/auth/view/settings/setting_page.dart';
import 'package:we_pei_yang_flutter/auth/view/user/logout_dialog.dart';
import 'package:we_pei_yang_flutter/auth/view/user/user_avatar_image.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.white));
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        AnimatedContainer(
            duration: Duration(milliseconds: 800),
            curve: Curves.easeIn,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      Color(0xFF2C7EDF),
                      Color(0xFFA6CFFF),
                      // 用来挡下面圆角左右的空
                      Colors.white
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    // 在0.7停止同理
                    stops: [0, 0.22, 0.22]))),
        SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 87.h),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.r),
                      topRight: Radius.circular(10.r)),
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    controller: ScrollController(),
                    children: <Widget>[
                      // SizedBox(height: 72),
                      Row(
                        children: <Widget>[
                          SizedBox(width: 20),
                          UserAvatarImage(size: 90, iconColor: Colors.white),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(CommonPreferences.nickname.value,
                                  textAlign: TextAlign.left,
                                  style: FontManager.YaHeiRegular.copyWith(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  )),
                              SizedBox(height: 15),
                              Row(children: <Widget>[
                                Text(CommonPreferences.userNumber.value,
                                    textAlign: TextAlign.center,
                                    style: FontManager.YaHeiRegular.copyWith(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    )),
                                SizedBox(width: 10),
                                Text(
                                    'MPID: ${CommonPreferences.lakeUid.value.padLeft(6, '0')}',
                                    textAlign: TextAlign.center,
                                    style: FontManager.YaHeiRegular.copyWith(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ]),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      // GestureDetector(
                      //     onLongPress: () => showDialog(
                      //         context: context,
                      //         barrierDismissible: true,
                      //         builder: (BuildContext context) => DebugDialog()),
                      //     child: Text(CommonPreferences().userNumber.value,
                      //         textAlign: TextAlign.center,
                      //         style: FontManager.Texta.copyWith(
                      //             color: CommonPreferences().isSkinUsed.value
                      //                 ? Colors.white
                      //                 : MyColors.deepDust,
                      //             fontSize: 15))),
                      if (CommonPreferences.isSkinUsed.value)
                        Container(
                            height: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.bottomRight,
                            child: Row(
                              children: <Widget>[
                                Spacer(),
                                SizedBox(
                                  width: 30.w,
                                )
                              ],
                            )),
                      SizedBox(height: 40),
                      //NavigationWidget(),

                      Row(
                        children: [
                          Spacer(),
                          SizedBox(
                            width: 125.w,
                            height: 90.h,
                            child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 7),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/mymsg.png',
                                        width: 24.w,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 7.h),
                                  Text('消息中心',
                                      maxLines: 1,
                                      style: TextUtil.base.w400.black2A
                                          .sp(12)
                                          .medium),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 125.w,
                            height: 90.h,
                            child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 7),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/mylike.png',
                                        width: 24.w,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 7.h),
                                  Text('我的点赞',
                                      maxLines: 1,
                                      style: TextUtil.base.w400.black2A
                                          .sp(12)
                                          .medium),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 125.w,
                            height: 90.h,
                            child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 7),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/myfav.png',
                                        width: 24.w,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 7.h),
                                  Text('我的收藏',
                                      maxLines: 1,
                                      style: TextUtil.base.w400.black2A
                                          .sp(12)
                                          .medium),
                                ],
                              ),
                            ),
                          ),
                          Spacer(),
                        ],
                      ),

                      Container(
                        height: 80,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: InkWell(
                            onTap: () => showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (BuildContext context) =>
                                    LogoutDialog()),
                            splashFactory: InkRipple.splashFactory,
                            borderRadius: BorderRadius.circular(12),
                            child: Row(
                              children: <Widget>[
                                SizedBox(width: 20),
                                Image.asset('assets/images/logout.png',
                                    width: 20),
                                SizedBox(width: 10),
                                SizedBox(width: 150, child: Text('logout')),
                                Spacer()
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Container(
                      //   height: 80,
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 20, vertical: 5),
                      //   child: Card(
                      //     elevation: 0,
                      //     shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12)),
                      //     child: InkWell(
                      //       onTap: () => Navigator.pushNamed(
                      //               context, AuthRouter.userInfo)
                      //           .then((value) => this.setState(() {})),
                      //       splashFactory: InkRipple.splashFactory,
                      //       borderRadius: BorderRadius.circular(12),
                      //       child: Row(
                      //         children: <Widget>[
                      //           SizedBox(width: 20),
                      //           Image.asset(
                      //               'assets/images/modify_info_icon.png',
                      //               width: 20),
                      //           SizedBox(width: 10),
                      //           SizedBox(
                      //               width: 150,
                      //               child: Text(S.current.reset_user_info,
                      //                   style: textStyle)),
                      //           Spacer(),
                      //           arrow,
                      //           SizedBox(width: 22)
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // Container(
                      //   height: 80,
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 20, vertical: 5),
                      //   child: Card(
                      //     elevation: 0,
                      //     shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12)),
                      //     child: InkWell(
                      //       onLongPress: () {
                      //         if (EnvConfig.isTest) {
                      //           Navigator.pushNamed(
                      //               context, TestRouter.mainPage);
                      //         }
                      //       },
                      //       onTap: () => Navigator.pushNamed(
                      //           context, AuthRouter.aboutTwt),
                      //       splashFactory: InkRipple.splashFactory,
                      //       borderRadius: BorderRadius.circular(12),
                      //       child: Row(
                      //         children: <Widget>[
                      //           SizedBox(width: 20),
                      //           Image.asset('assets/images/twt.png', width: 20),
                      //           SizedBox(width: 10),
                      //           SizedBox(
                      //               width: 150,
                      //               child: Text(S.current.about_twt,
                      //                   style: textStyle)),
                      //           Spacer(),
                      //           arrow,
                      //           SizedBox(width: 22),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // Container(
                      //   height: 80,
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 20, vertical: 5),
                      //   child: Card(
                      //     elevation: 0,
                      //     shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12)),
                      //     child: InkWell(
                      //       onTap: () {
                      //         context
                      //             .read<UpdateManager>()
                      //             .checkUpdate(auto: false);
                      //       },
                      //       splashFactory: InkRipple.splashFactory,
                      //       borderRadius: BorderRadius.circular(12),
                      //       child: Row(
                      //         children: <Widget>[
                      //           SizedBox(width: 20),
                      //           Icon(Icons.update,
                      //               color: Color.fromRGBO(98, 103, 122, 1),
                      //               size: 20),
                      //           SizedBox(width: 10),
                      //           Text(S.current.check_new, style: textStyle),
                      //           Spacer(),
                      //           Padding(
                      //             padding: const EdgeInsets.only(right: 26),
                      //             child: Text(
                      //               "${S.current.current_version}: ${EnvConfig.VERSION}",
                      //               style: FontManager.YaHeiLight.copyWith(
                      //                 color:
                      //                     CommonPreferences().isSkinUsed.value
                      //                         ? Color(CommonPreferences()
                      //                             .skinColorC
                      //                             .value)
                      //                         : Colors.grey,
                      //                 fontSize: 11,
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // Container(
                      //   height: 80,
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 20, vertical: 5),
                      //   child: Card(
                      //     elevation: 0,
                      //     shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12)),
                      //     child: InkWell(
                      //       onTap: () => showDialog(
                      //           context: context,
                      //           barrierDismissible: true,
                      //           builder: (BuildContext context) =>
                      //               LogoutDialog()),
                      //       splashFactory: InkRipple.splashFactory,
                      //       borderRadius: BorderRadius.circular(12),
                      //       child: Row(
                      //         children: <Widget>[
                      //           SizedBox(width: 20),
                      //           Image.asset('assets/images/logout.png',
                      //               width: 20),
                      //           SizedBox(width: 10),
                      //           SizedBox(
                      //               width: 150,
                      //               child: Text(S.current.logout,
                      //                   style: textStyle)),
                      //           Spacer()
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     GestureDetector(
                      //       onTap: () => showDialog(
                      //           context: context,
                      //           barrierDismissible: true,
                      //           builder: (context) => UserAgreementDialog()),
                      //       child: Container(
                      //         padding: const EdgeInsets.all(8),
                      //         decoration: BoxDecoration(),
                      //         child: Text('《用户协议》',
                      //             style: FontManager.YaHeiRegular.copyWith(
                      //                 fontSize: 11,
                      //                 color: Color.fromRGBO(98, 103, 122, 1))),
                      //       ),
                      //     ),
                      //     GestureDetector(
                      //       onTap: () => showDialog(
                      //           context: context,
                      //           barrierDismissible: true,
                      //           builder: (context) => PrivacyDialog()),
                      //       child: Container(
                      //         padding: const EdgeInsets.all(8),
                      //         decoration: BoxDecoration(),
                      //         child: Text('《隐私政策》',
                      //             style: FontManager.YaHeiRegular.copyWith(
                      //                 fontSize: 11,
                      //                 color: Color.fromRGBO(98, 103, 122, 1))),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                    padding: EdgeInsets.only(right: 30.w),
                    child: SizedBox(
                      height: 60.h,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: AnimatedOpacity(
                          opacity: 1,
                          duration: Duration(milliseconds: 800),
                          curve: Curves.easeIn,
                          child: Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child: Row(
                              children: [
                                Spacer(),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, AuthRouter.mailbox),
                                  child: Icon(
                                    Icons.email_outlined,
                                    size: 28,
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                  ),
                                ),
                                SizedBox(width: 15),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                          context, AuthRouter.setting,
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
                          ),
                        ),
                      ),
                    )),
              )
            ],
          ),
        ),
      ],
      // ),
      // ),
    );
  }
}
