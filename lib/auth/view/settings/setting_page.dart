import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/channel/push/push_manager.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_notifier.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';

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
  static final titleTextStyle =
      TextUtil.base.bold.sp(14).customColor(Color.fromRGBO(177, 180, 186, 1));
  static final mainTextStyle =
      TextUtil.base.bold.sp(14).customColor(Color.fromRGBO(98, 103, 122, 1));
  static final hintTextStyle = TextUtil.base.regular
      .sp(10)
      .customColor(Color.fromRGBO(205, 206, 212, 1));
  static final arrow =
      Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 22);

  double descriptionMaxWidth;

  @override
  Widget build(BuildContext context) {
    descriptionMaxWidth = MediaQuery.of(context).size.width / 2;
    return Scaffold(
      appBar: AppBar(
          title: Text(S.current.setting,
              style: TextUtil.base.bold
                  .sp(16)
                  .customColor(Color.fromRGBO(36, 43, 69, 1))),
          elevation: 0,
          brightness: Brightness.light,
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(53, 59, 84, 1.0), size: 32),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  onTap: () =>
                      Navigator.pushNamed(context, AuthRouter.themeSetting)
                          .then((_) {
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
                              Text('主题', style: mainTextStyle),
                              SizedBox(height: 3),
                              Text('联网获取全部已获得主题', style: hintTextStyle)
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
                    SizedBox(
                        width: descriptionMaxWidth,
                        child:
                            Text(S.current.setting_gpa, style: mainTextStyle)),
                    Spacer(),
                    Switch(
                      value: CommonPreferences.hideGPA.value,
                      onChanged: (value) {
                        setState(() => CommonPreferences.hideGPA.value = value);
                        Provider.of<GPANotifier>(context, listen: false)
                            .hideGPA = value;
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
                    SizedBox(
                        width: descriptionMaxWidth,
                        child:
                            Text(S.current.setting_exam, style: mainTextStyle)),
                    Spacer(),
                    Switch(
                      value: CommonPreferences.hideExam.value,
                      onChanged: (value) {
                        setState(
                            () => CommonPreferences.hideExam.value = value);
                        Provider.of<ExamProvider>(context, listen: false)
                            .hideExam = value;
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
                  borderRadius: BorderRadius.circular(15)),
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
                          Text(S.current.setting_night_mode,
                              style: mainTextStyle),
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
                      value: CommonPreferences.nightMode.value,
                      onChanged: (value) {
                        setState(
                            () => CommonPreferences.nightMode.value = value);
                        Provider.of<CourseDisplayProvider>(context,
                                listen: false)
                            .nightMode = value;
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, AuthRouter.scheduleSetting)
                            .then((_) {
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
                                Text(S.current.setting_day_number,
                                    style: mainTextStyle),
                                SizedBox(height: 3),
                                Text('${CommonPreferences.dayNumber.value}',
                                    style: hintTextStyle)
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
              Container(
                  padding: const EdgeInsets.fromLTRB(20, 17, 40, 5),
                  alignment: Alignment.centerLeft,
                  child: Text('消息通知', style: titleTextStyle)),
              Padding(
                padding: EdgeInsets.fromLTRB(17, 4, 17, 4),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
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
                            value: context.select(
                                (PushManager manger) => manger.openPush),
                            onChanged: (value) {
                              if (value) {
                                context.read<PushManager>().turnOnPushService(
                                    () {
                                  ToastProvider.success("开启推送成功");
                                }, () {
                                  ToastProvider.success("开启推送需要通知权限");
                                }, () {
                                  ToastProvider.error("打开失败");
                                });
                              } else {
                                context.read<PushManager>().turnOffPushService(
                                    () {
                                  ToastProvider.success("关闭推送成功");
                                }, () {
                                  ToastProvider.error("关闭失败");
                                });
                              }
                            },
                            activeColor: Color.fromRGBO(105, 109, 127, 1),
                            inactiveThumbColor:
                                Color.fromRGBO(205, 206, 212, 1),
                            activeTrackColor: Color.fromRGBO(240, 241, 242, 1),
                            inactiveTrackColor:
                                Color.fromRGBO(240, 241, 242, 1),
                          );
                        }),
                      ],
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
