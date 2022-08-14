import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

class ErCiYuanWidget extends StatefulWidget {
  ErCiYuanWidget(Key key) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ErCiYuanWidgetState();
  }
}

class ErCiYuanWidgetState extends State<ErCiYuanWidget>
    with TickerProviderStateMixin {
  GlobalKey<ErCiYuanWidgetState> erCiYuanKey = GlobalKey();

  var rand = new Random();

  bool _offStage = true;
  int welcomeHintNum = 0;
  int talkingNum = 0;
  double _welcomeOpacity = 1;

  ///会说的话，不能少于两条
  List<String> welcomeHints = [
    CommonPreferences.nickname.value + ",欢迎光临",
    "...",
    "您的学号是" + CommonPreferences.tjuuname.value,
  ];

  AnimationController _girlController;
  AnimationController _talkController;

  Animation _girlAnimation, _talkAnimation; //这个虽然是黄但是不要删

  @override
  void initState() {
    super.initState();
    _girlController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _talkController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    _girlAnimation = CurvedAnimation(
        parent: Tween(begin: 0.0, end: 1.0).animate(_girlController),
        curve: Curves.easeInQuad);

    _talkAnimation = CurvedAnimation(
        parent: Tween(begin: 0.0, end: 1.0).animate(_talkController),
        curve: Curves.easeInBack);
    welcomeHintNum = rand.nextInt(welcomeHints.length);
  }

  @override
  Widget build(BuildContext context) {
    if (!CommonPreferences.showPosterGirl.value ||
        CommonPreferences.showPosterGirl == null)
      return SizedBox();
    else
      return Offstage(
          offstage: _offStage,
          child: Stack(
            children: [
              Positioned(
                  left: -30,
                  bottom: -45,
                  child: FadeTransition(
                    opacity: _girlAnimation,
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        talkingNum = shfWords(talkingNum);
                      },
                      // child: Image.asset(
                      //   'assets/images/er_ci_yuan.png',
                      //   width: 300,
                      // ),
                    ),
                  )),
              Positioned(
                  top: 50,
                  left: 30,
                  child: AnimatedOpacity(
                    duration: Duration(seconds: 8),
                    opacity: _welcomeOpacity,
                    curve: Curves.easeInBack,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 80,
                      child: Text(
                        welcomeHints[welcomeHintNum],
                        style: FontManager.YaHeiRegular.copyWith(
                            color: ColorUtil.lightTextColor,
                            fontSize: 18,
                            letterSpacing: 1.8,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  )),
              Positioned(
                  bottom: 230,
                  left: 155,
                  child: FadeTransition(
                    opacity: _talkController,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 160,
                      child: Text(
                        "『" + welcomeHints[talkingNum] + "』",
                        textAlign: TextAlign.start,
                        style: FontManager.YaQiHei.copyWith(
                          color: ColorUtil.lightTextColor,
                          fontSize: 30,
                          letterSpacing: 1.8,
                          fontWeight: FontWeight.w600,
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 2.0,
                              color: Color.fromARGB(125, 93, 91, 132),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
            ],
          ));
  }

  @override
  void dispose() {
    _girlController.dispose();
    _talkController.dispose();
    super.dispose();
  }

  void onStaged(bool offstage) {
    setState(() {
      if (offstage) {
        _girlController.reset();
        _talkController.reset();
      } else {
        _girlController.forward();
        _talkController.forward();
        _welcomeOpacity = 0;
      }
      _offStage = offstage;
    });
  }

  int shfWords(int lastTalkingNum) {
    //改变说的话和动作,可以保证前后不同
    setState(() {
      talkingNum = rand.nextInt(welcomeHints.length);
      if (talkingNum == lastTalkingNum) shfWords(talkingNum);
      lastTalkingNum = talkingNum;
    });
    return lastTalkingNum;
  }

  String get _getGreetText {
    int hour = DateTime.now().hour;
    if (hour >= 0 && hour < 5)
      return '夜深了，早点睡';
    else if (hour >= 5 && hour < 8)
      return '起得好早';
    else if (hour >= 8 && hour < 12)
      return '早上好';
    else if (hour >= 12 && hour < 14)
      return '中午好';
    else if (hour >= 12 && hour < 17)
      return '下午好';
    else if (hour >= 17 && hour < 19)
      return '傍晚好';
    else
      return '晚上好';
  }
}
