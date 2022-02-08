import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/push/push_manager.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/test_router.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_notifier.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam_notifier.dart';
import 'package:we_pei_yang_flutter/schedule/model/schedule_notifier.dart';

class SettingPageArgs {
  final bool showBrief;

  SettingPageArgs(this.showBrief);
}

class SettingPage extends StatefulWidget {
  final bool showBrief;

  SettingPage(SettingPageArgs args) : showBrief = args.showBrief;

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  static final titleTextStyle = FontManager.YaHeiBold.copyWith(
      fontSize: 14, color: Color.fromRGBO(177, 180, 186, 1), fontWeight: FontWeight.bold);
  static final mainTextStyle = FontManager.YaHeiRegular.copyWith(
      fontSize: 14, color: Color.fromRGBO(98, 103, 122, 1), fontWeight: FontWeight.bold);
  static final hintTextStyle = FontManager.YaHeiRegular.copyWith(fontSize: 10, color: Color.fromRGBO(205, 206, 212, 1));
  static final arrow = Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 22);

  var pref = CommonPreferences();
  double descriptionMaxWidth;

  @override
  Widget build(BuildContext context) {
    descriptionMaxWidth = MediaQuery.of(context).size.width / 2;
    return Scaffold(
      appBar: AppBar(
          title: Text(S.current.setting,
              style: FontManager.YaHeiRegular.copyWith(
                  fontSize: 16, color: Color.fromRGBO(36, 43, 69, 1), fontWeight: FontWeight.bold)),
          elevation: 0,
          brightness: Brightness.light,
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
                child: Icon(Icons.arrow_back, color: Color.fromRGBO(53, 59, 84, 1.0), size: 32),
                onTap: () => Navigator.pop(context)),
          )),
      body: ListView(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(25, 20, 25, 5),
            alignment: Alignment.centerLeft,
            child: (!widget.showBrief)
                ? Text(S.current.setting_general, style: titleTextStyle)
                : Text("首页自定义", style: titleTextStyle),
          ),
          if (!widget.showBrief)
            Padding(
              padding: EdgeInsets.fromLTRB(17, 4, 17, 4),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, AuthRouter.colorSetting).then((_) {
                    /// 使用pop返回此页面时进行rebuild
                    this.setState(() {});
                  }),
                  splashFactory: InkRipple.splashFactory,
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: descriptionMaxWidth,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(S.current.setting_color, style: mainTextStyle),
                              SizedBox(height: 3),
                              Text(S.current.setting_color_hint, style: hintTextStyle)
                            ],
                          ),
                        ),
                        Spacer(),
                        arrow,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(17, 4, 17, 4),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: <Widget>[
                    SizedBox(width: descriptionMaxWidth, child: Text(S.current.setting_gpa, style: mainTextStyle)),
                    Spacer(),
                    Switch(
                      value: pref.hideGPA.value,
                      onChanged: (value) {
                        setState(() => pref.hideGPA.value = value);
                        Provider.of<GPANotifier>(context, listen: false).hideGPA = value;
                      },
                      activeColor: Color.fromRGBO(105, 109, 127, 1),
                      inactiveThumbColor: Color.fromRGBO(205, 206, 212, 1),
                      activeTrackColor: Color.fromRGBO(240, 241, 242, 1),
                      inactiveTrackColor: Color.fromRGBO(240, 241, 242, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(17, 4, 17, 4),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: <Widget>[
                    SizedBox(width: descriptionMaxWidth, child: Text(S.current.setting_exam, style: mainTextStyle)),
                    Spacer(),
                    Switch(
                      value: pref.hideExam.value,
                      onChanged: (value) {
                        setState(() => pref.hideExam.value = value);
                        Provider.of<ExamNotifier>(context, listen: false).hideExam = value;
                      },
                      activeColor: Color.fromRGBO(105, 109, 127, 1),
                      inactiveThumbColor: Color.fromRGBO(205, 206, 212, 1),
                      activeTrackColor: Color.fromRGBO(240, 241, 242, 1),
                      inactiveTrackColor: Color.fromRGBO(240, 241, 242, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.fromLTRB(17, 4, 17, 4),
          //   child: Card(
          //     elevation: 0,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(15),
          //     ),
          //     child: Padding(
          //       padding: const EdgeInsets.all(10.0),
          //       child: Row(
          //         children: <Widget>[
          //           SizedBox(
          //               width: descriptionMaxWidth,
          //               child: Text("首页显示看板娘", style: mainTextStyle)),
          //           Spacer(),
          //           Switch(
          //             value: pref.showPosterGirl.value,
          //             onChanged: (value) {
          //               setState(() => pref.showPosterGirl.value = value);
          //             },
          //             activeColor: Color.fromRGBO(105, 109, 127, 1),
          //             inactiveThumbColor: Color.fromRGBO(205, 206, 212, 1),
          //             activeTrackColor: Color.fromRGBO(240, 241, 242, 1),
          //             inactiveTrackColor: Color.fromRGBO(240, 241, 242, 1),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          Padding(
            padding: EdgeInsets.fromLTRB(17, 4, 17, 4),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: descriptionMaxWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(S.current.setting_night_mode, style: mainTextStyle),
                          SizedBox(height: 3),
                          Text(
                            S.current.setting_night_mode_hint,
                            style: hintTextStyle,
                          )
                        ],
                      ),
                    ),
                    Spacer(),
                    Switch(
                      value: pref.nightMode.value,
                      onChanged: (value) {
                        setState(() => pref.nightMode.value = value);
                        Provider.of<ScheduleNotifier>(context, listen: false).nightMode = value;
                      },
                      activeColor: Color.fromRGBO(105, 109, 127, 1),
                      inactiveThumbColor: Color.fromRGBO(205, 206, 212, 1),
                      activeTrackColor: Color.fromRGBO(240, 241, 242, 1),
                      inactiveTrackColor: Color.fromRGBO(240, 241, 242, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!widget.showBrief)
            Column(children: [
              Container(
                  padding: const EdgeInsets.fromLTRB(20, 17, 40, 5),
                  alignment: Alignment.centerLeft,
                  child: Text(S.current.schedule, style: titleTextStyle)),
              Padding(
                padding: EdgeInsets.fromLTRB(17, 4, 17, 4),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, AuthRouter.scheduleSetting).then((_) {
                      /// 使用pop返回此页面时进行rebuild
                      this.setState(() {});
                    }),
                    splashFactory: InkRipple.splashFactory,
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: descriptionMaxWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(S.current.setting_day_number, style: mainTextStyle),
                                SizedBox(height: 3),
                                Text('${pref.dayNumber.value}', style: hintTextStyle)
                              ],
                            ),
                          ),
                          Spacer(),
                          arrow,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(17, 4, 17, 4),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: descriptionMaxWidth,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(S.current.setting_other_week, style: mainTextStyle),
                              SizedBox(height: 3),
                              Text(S.current.setting_other_week_hint, style: hintTextStyle)
                            ],
                          ),
                        ),
                        Spacer(),
                        Switch(
                          value: pref.otherWeekSchedule.value,
                          onChanged: (value) {
                            setState(() => pref.otherWeekSchedule.value = value);
                          },
                          activeColor: Color.fromRGBO(105, 109, 127, 1),
                          inactiveThumbColor: Color.fromRGBO(205, 206, 212, 1),
                          activeTrackColor: Color.fromRGBO(240, 241, 242, 1),
                          inactiveTrackColor: Color.fromRGBO(240, 241, 242, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                  padding: const EdgeInsets.fromLTRB(20, 17, 40, 5),
                  alignment: Alignment.centerLeft,
                  child: Text('消息通知', style: titleTextStyle)),
              Padding(
                padding: EdgeInsets.fromLTRB(17, 4, 17, 4),
                child: GestureDetector(
                  onLongPress: (){
                    Navigator.pushNamed(context, TestRouter.pushTest);
                  },
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: descriptionMaxWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('青年湖底和信箱消息通知', style: mainTextStyle),
                                SizedBox(height: 3),
                                Text('应用消息通知', style: hintTextStyle)
                              ],
                            ),
                          ),
                          Spacer(),
                          Builder(builder: (context) {
                            return Switch(
                              value: context.select((PushManager manger) => manger.openPush),
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
                              activeColor: Color.fromRGBO(105, 109, 127, 1),
                              inactiveThumbColor: Color.fromRGBO(205, 206, 212, 1),
                              activeTrackColor: Color.fromRGBO(240, 241, 242, 1),
                              inactiveTrackColor: Color.fromRGBO(240, 241, 242, 1),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ])
        ],
      ),
    );
  }
}
