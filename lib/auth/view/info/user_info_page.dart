import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/auth/view/info/unbind_dialogs.dart';
import 'package:we_pei_yang_flutter/auth/view/user/user_avatar_image.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';

import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/widgets/w_button.dart';

class UserInfoPage extends StatefulWidget {
  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  @override
  Widget build(BuildContext context) {
    final arrow = Icon(Icons.arrow_forward_ios,
        color: WpyTheme.of(context).get(WpyColorKey.oldListActionColor),
        size: 22);
    final hintTextStyle = TextUtil.base.w600.sp(12).oldHint(context);
    final mainTextStyle = TextUtil.base.bold.sp(14).oldThirdAction(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('个人信息更改',
            style: TextUtil.base.bold.sp(16).oldActionColor(context)),
        elevation: 0,
        centerTitle: true,
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        leading: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: WButton(
            child: Icon(Icons.arrow_back,
                color: WpyTheme.of(context).get(WpyColorKey.oldActionColor),
                size: 32),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          SizedBox(height: 15.h),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 15.w, 20.h),
            decoration: BoxDecoration(
              color:
                  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                WButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AuthRouter.avatarCrop)
                        .then((_) => this.setState(() {}));
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('头像', style: mainTextStyle),
                      ),
                      Hero(
                          tag: 'avatar',
                          child: UserAvatarImage(
                            size: 45,
                            context: context,
                          )),
                      arrow,
                      SizedBox(width: 15.w)
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                    height: 1,
                    color: WpyTheme.of(context).get(WpyColorKey.oldHintColor)),
                SizedBox(height: 20.h),
                WButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AuthRouter.resetName)
                        .then((_) => this.setState(() {}));
                  },
                  child: Row(
                    children: [
                      Text('用户名', style: mainTextStyle),
                      Expanded(
                        child: Text(
                          CommonPreferences.nickname.value,
                          style: hintTextStyle,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      arrow,
                      SizedBox(width: 15.w)
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                    height: 1,
                    color: WpyTheme.of(context).get(WpyColorKey.oldHintColor)),
                SizedBox(height: 20.h),
                WButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AuthRouter.tjuBind)
                        .then((_) => this.setState(() {}));
                  },
                  child: Row(
                    children: [
                      Text('办公网', style: mainTextStyle),
                      Spacer(),
                      Text(
                          CommonPreferences.isBindTju.value
                              ? '已绑定'
                              : '未绑定',
                          style: hintTextStyle),
                      SizedBox(width: 10.w),
                      arrow,
                      SizedBox(width: 15.w)
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                    height: 1,
                    color: WpyTheme.of(context).get(WpyColorKey.oldHintColor)),
                SizedBox(height: 20.h),
                WButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AuthRouter.resetPassword)
                        .then((_) => this.setState(() {}));
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('密码更改',
                            style: mainTextStyle),
                      ),
                      arrow,
                      SizedBox(width: 15.w)
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                    height: 1,
                    color: WpyTheme.of(context).get(WpyColorKey.oldHintColor)),
                SizedBox(height: 20.h),
                WButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AuthRouter.avatarBox)
                        .then((_) => this.setState(() {}));
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('更换头像框', style: mainTextStyle),
                      ),
                      arrow,
                      SizedBox(width: 15.w)
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15.h),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 15.w, 20.h),
            decoration: BoxDecoration(
              color:
                  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                WButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AuthRouter.phoneBind)
                          .then((_) => this.setState(() {})),
                  child: Row(
                    children: [
                      Image.asset('assets/images/telephone.png', width: 20.w),
                      SizedBox(width: 12.w),
                      Text('电话', style: mainTextStyle),
                      Spacer(),
                      Text(
                          (CommonPreferences.phone.value != "")
                              ? '已绑定'
                              : '未绑定',
                          style: hintTextStyle),
                      SizedBox(width: 10.w),
                      arrow,
                      SizedBox(width: 15.w)
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                    height: 1,
                    color: WpyTheme.of(context).get(WpyColorKey.oldHintColor)),
                SizedBox(height: 20.h),
                WButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AuthRouter.emailBind)
                          .then((_) => this.setState(() {})),
                  child: Row(
                    children: [
                      Image.asset('assets/images/email.png', width: 20.w),
                      SizedBox(width: 12.w),
                      Text('邮箱', style: mainTextStyle),
                      Spacer(),
                      Text(
                          (CommonPreferences.email.value != "")
                              ? '已绑定'
                              : '未绑定',
                          style: hintTextStyle),
                      SizedBox(width: 10.w),
                      arrow,
                      SizedBox(width: 15.w)
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15.h),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 15.w, 20.h),
            decoration: BoxDecoration(
              color:
                  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: WButton(
              onPressed: () => showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) => LogoffDialog()),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text('注销账号', style: mainTextStyle)),
                  arrow,
                  SizedBox(width: 15.w)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
