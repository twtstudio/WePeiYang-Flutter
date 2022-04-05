import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/main.dart';

class NucPassportPage extends StatefulWidget {
  @override
  _NucPassportPageState createState() => _NucPassportPageState();
}

class _NucPassportPageState extends State<NucPassportPage> {
  Timer _timer;
  Color mainColor = Colors.red;
  Color assistColor = Colors.purple;
  bool reverse = false;

  @override
  void initState() {
    super.initState();

    ///循环执行
    ///间隔1秒
    _timer = Timer.periodic(Duration(milliseconds: 3000), (timer) {
      setState(() {
        reverse = !reverse;
      });
    });
  }

  @override
  void dispose() {
    ///取消计时器
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 3000),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment(0, 2),
          colors: [
            reverse ? assistColor : mainColor,
            !reverse ? assistColor : mainColor
          ],
        ),
      ),
      child: Stack(
        children: [
          Align(
              alignment: Alignment.bottomRight,
              child: SvgPicture.asset('assets/images/peiyang_shield.svg',
                  width: WePeiYangApp.screenWidth * 0.7, fit: BoxFit.fitWidth)),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset('assets/svg_pics/domain_back.svg',
                        width: 28.w, height: 28.w),
                  ),
                  SizedBox(height: 34.w),
                  Text('请向志愿者出示您的号码牌', style: TextUtil.base.white.sp(18).w700),
                  SizedBox(height: 8.w),
                  Text('Please show your number to the volunteer',
                      style: TextUtil.base.white.sp(18).w700),
                  SizedBox(height: 10.w),
                  Container(
                      child: Text('诚园\n8斋311',
                          style: TextUtil.base.white.sp(80).w700),
                      decoration: BoxDecoration(
                          border: Border.symmetric(
                              horizontal: BorderSide(color: Colors.white)))),
                  SizedBox(height: 10.w),
                  Text(
                      '${CommonPreferences().major.value} ${CommonPreferences().realName.value}',
                      style: TextUtil.base.white.sp(18).w700),
                  SizedBox(height: 8.w),
                  Text('${CommonPreferences().tjuuname.value ?? '请绑定办公网'}',
                      style: TextUtil.base.white.sp(18).w700),
                  Spacer(),
                  Text(
                      DateTime.now()
                              .toLocal()
                              .toIso8601String()
                              .substring(0, 10) +
                          " " +
                          DateTime.now()
                              .toLocal()
                              .toIso8601String()
                              .substring(11, 19),
                      style: TextUtil.base.white.sp(18).w700),
                  Text('请在核酸检测时出示，请勿截图',
                      style: TextUtil.base.white.sp(18).w700),
                  SizedBox(
                    height: 30.w,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
