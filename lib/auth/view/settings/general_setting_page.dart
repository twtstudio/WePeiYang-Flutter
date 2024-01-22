import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/channel/push/push_manager.dart';
import 'package:we_pei_yang_flutter/commons/font/font_loader.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';

import '../../../commons/widgets/w_button.dart';
import '../../../gpa/model/gpa_notifier.dart';

class GeneralSettingPage extends StatefulWidget {
  @override
  _GeneralSettingPageState createState() => _GeneralSettingPageState();
}

class _GeneralSettingPageState extends State<GeneralSettingPage> {
  static final titleTextStyle = TextUtil.base.bold
      .sp(14)
      .grey177;
  static final mainTextStyle = TextUtil.base.bold
      .sp(14)
      .blue98122;
  static final hintTextStyle = TextUtil.base.regular
      .sp(12)
      .whiteHint205;
  static const arrow =
  Icon(Icons.arrow_forward_ios, color: ColorUtil.grey, size: 22);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('应用设置', style: TextUtil.base.bold
            .sp(16)
            .blue52hz),
        elevation: 0,
        centerTitle: true,
        backgroundColor: ColorUtil.whiteFFColor,
        leading: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: WButton(
            child: Icon(Icons.arrow_back, color: ColorUtil.blue53, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          SizedBox(height: 15.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(S.current.setting_general, style: titleTextStyle),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 15.w, 20.h),
            decoration: BoxDecoration(
              color: ColorUtil.whiteFFColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: WButton(
              onPressed: () {
                WbyFontLoader.initFonts(hint: true);
              },
              child: Row(
                children: [
                  Expanded(
                      child: Text('重新加载字体文件', style: mainTextStyle)),
                  arrow,
                  SizedBox(width: 15.w),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
            decoration: BoxDecoration(
              color: ColorUtil.whiteFFColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('主页显示校园地图和校历', style: mainTextStyle),
                      SizedBox(height: 3.h),
                      Text('默认关闭', style: hintTextStyle)
                    ],
                  ),
                ),
                Switch(
                  value: CommonPreferences.showMap.value,
                  onChanged: (value) {
                    setState(() => CommonPreferences.showMap.value = value);
                  },
                  activeColor: ColorUtil.blue105,
                  inactiveThumbColor: ColorUtil.hintWhite205,
                  activeTrackColor: ColorUtil.white240,
                  inactiveTrackColor: ColorUtil.white240,
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
            decoration: BoxDecoration(
              color: ColorUtil.whiteFFColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('主页显示GPA', style: mainTextStyle),
                      SizedBox(height: 3.h),
                      Text('默认关闭', style: hintTextStyle)
                    ],
                  ),
                ),
                Switch(
                  value: !CommonPreferences.hideGPA.value,
                  onChanged: (value) {
                    setState(() => CommonPreferences.hideGPA.value = !value);
                    context
                        .read<GPANotifier>()
                        .hideGPA = !value;
                  },
                  activeColor: ColorUtil.blue105,
                  inactiveThumbColor: ColorUtil.hintWhite205,
                  activeTrackColor: ColorUtil.white240,
                  inactiveTrackColor: ColorUtil.white240,
                ),
              ],
            ),
          ),
          // SizedBox(height: 10.h),
          // Container(
          //   padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(12.r),
          //   ),
          //   child: WButton(
          //     onPressed: () => Navigator.pushNamed(context, AuthRouter.themeSetting)
          //         .then((_) {
          //       /// 使用pop返回此页面时进行rebuild
          //       this.setState(() {});
          //     }),
          //     child: Row(
          //       children: [
          //         Expanded(
          //           child: Column(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Text('主题', style: mainTextStyle),
          //               SizedBox(height: 3.h),
          //               Text('联网获取全部已获得主题', style: hintTextStyle)
          //             ],
          //           ),
          //         ),
          //         arrow,
          //         SizedBox(width: 15.w),
          //       ],
          //     ),
          //   ),
          // ),
          // SizedBox(height: 10.h),
          // Container(
          //   padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(12.r),
          //   ),
          //   child: Row(
          //     children: [
          //       Expanded(
          //           child: Text(S.current.setting_gpa, style: mainTextStyle)),
          //       Switch(
          //         value: CommonPreferences.hideGPA.value,
          //         onChanged: (value) {
          //           setState(() => CommonPreferences.hideGPA.value = value);
          //           Provider.of<GPANotifier>(context, listen: false).hideGPA =
          //               value;
          //         },
          //         activeColor: Color.fromRGBO(105, 109, 127, 1),
          //         inactiveThumbColor: Color.fromRGBO(205, 206, 212, 1),
          //         activeTrackColor: Color.fromRGBO(240, 241, 242, 1),
          //         inactiveTrackColor: Color.fromRGBO(240, 241, 242, 1),
          //       ),
          //     ],
          //   ),
          // ),
          // SizedBox(height: 10.h),
          // Container(
          //   padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(12.r),
          //   ),
          //   child: Row(
          //     children: [
          //       Expanded(
          //           child: Text(S.current.setting_exam, style: mainTextStyle)),
          //       Switch(
          //         value: CommonPreferences.hideExam.value,
          //         onChanged: (value) {
          //           setState(() => CommonPreferences.hideExam.value = value);
          //           Provider.of<ExamProvider>(context, listen: false).hideExam =
          //               value;
          //         },
          //         activeColor: Color.fromRGBO(105, 109, 127, 1),
          //         inactiveThumbColor: Color.fromRGBO(205, 206, 212, 1),
          //         activeTrackColor: Color.fromRGBO(240, 241, 242, 1),
          //         inactiveTrackColor: Color.fromRGBO(240, 241, 242, 1),
          //       ),
          //     ],
          //   ),
          // ),
          SizedBox(height: 15.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(S.current.schedule, style: titleTextStyle),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
            decoration: BoxDecoration(
              color: ColorUtil.whiteFFColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('智能云端服务（BETA）', style: mainTextStyle),
                      SizedBox(height: 3.h),
                      Text('获取课表、GPA、考表无需输入图形验证码',
                          style: hintTextStyle)
                    ],
                  ),
                ),
                Switch(
                  value: CommonPreferences.useClassesBackend.value,
                  onChanged: (value) {
                    setState(() =>
                    CommonPreferences.useClassesBackend.value = value);
                  },
                  activeColor: ColorUtil.blue105,
                  inactiveThumbColor: ColorUtil.hintWhite205,
                  activeTrackColor: ColorUtil.white240,
                  inactiveTrackColor: ColorUtil.white240,
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
            decoration: BoxDecoration(
              color: ColorUtil.whiteFFColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.current.setting_night_mode, style: mainTextStyle),
                      SizedBox(height: 3.h),
                      Text(S.current.setting_night_mode_hint,
                          style: hintTextStyle)
                    ],
                  ),
                ),
                Switch(
                  value: CommonPreferences.nightMode.value,
                  onChanged: (value) {
                    setState(() => CommonPreferences.nightMode.value = value);
                    Provider
                        .of<CourseDisplayProvider>(context, listen: false)
                        .nightMode = value;
                  },
                  activeColor: ColorUtil.blue105,
                  inactiveThumbColor: ColorUtil.hintWhite205,
                  activeTrackColor: ColorUtil.white240,
                  inactiveTrackColor: ColorUtil.white240,
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
            decoration: BoxDecoration(
              color: ColorUtil.whiteFFColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: WButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AuthRouter.scheduleSetting)
                      .then((_) => this.setState(() {})),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.current.setting_day_number,
                            style: mainTextStyle),
                        SizedBox(height: 5.h),
                        Text('${CommonPreferences.dayNumber.value}',
                            style: hintTextStyle)
                      ],
                    ),
                  ),
                  arrow,
                  SizedBox(width: 15.w),
                ],
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('消息通知', style: titleTextStyle),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
            decoration: BoxDecoration(
              color: ColorUtil.whiteFFColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('求是论坛和信箱消息通知', style: mainTextStyle),
                      SizedBox(height: 3.h),
                      Text('应用消息通知', style: hintTextStyle)
                    ],
                  ),
                ),
                Builder(builder: (context) {
                  return Switch(
                    value:
                    context.select((PushManager manger) => manger.openPush),
                    onChanged: (value) {
                      if (value) {
                        context.read<PushManager>().turnOnPushService(() {
                          ToastProvider.success("开启推送成功");
                        }, () {
                          ToastProvider.success("开启推送需要通知权限");
                        }, () {
                          ToastProvider.error("打开失败");
                        });
                      } else {
                        context.read<PushManager>().turnOffPushService(() {
                          ToastProvider.success("关闭推送成功");
                        }, () {
                          ToastProvider.error("关闭失败");
                        });
                      }
                    },
                    activeColor: ColorUtil.blue105,
                    inactiveThumbColor: ColorUtil.hintWhite205,
                    activeTrackColor: ColorUtil.white240,
                    inactiveTrackColor: ColorUtil.white240,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
