import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/commons/channel/local_setting/local_setting.dart';

import '../commons/widgets/w_button.dart';

class NucPassportPage extends StatefulWidget {
  @override
  _NucPassportPageState createState() => _NucPassportPageState();
}

class _NucPassportPageState extends State<NucPassportPage> {
  late Timer _timer;
  Map<String, Color> mainColor = {
    '格园': Color(0xFFFF3D3F),
    '知园': Color(0xFFFF9449),
    '诚园': Color(0xFFFFC130),
    '正园': Color(0xFFFFC130),
    '修园': Color(0xFF40A9FF),
    '齐园': Color(0xFFAE45DB),
    '治园': Color(0xFF53A6D2),
    '平园': Color(0xFF15D1D3),
    '青园': Color(0xFFE536BF),
    '留园': Color(0xFFE536BF)
  };

  Map<String, Color> assistColor = {
    '1斋': Color(0xFFFF9449),
    '2斋': Color(0xFFFFC130),
    '3斋': Color(0xFF9254DE),
    '4斋': Color(0xFFFF3D3F),
    '5斋': Color(0xFFFFC130),
    '6斋A': Color(0xFFFF3D3F),
    '6斋B': Color(0xFFFF3D3F),
    '7斋': Color(0xFFFF9449),
    '8斋A': Color(0xFF9254DE),
    '8斋B': Color(0xFF40A9FF),
    '9斋': Color(0xFFFFC130),
    '10斋': Color(0xFF40A9FF),
    '11斋': Color(0xFFFF3D3F),
    '12斋': Color(0xFFFFC130),
    '13斋': Color(0xFFFFC130),
    '14斋': Color(0xFFFF3D3F),
    '15斋': Color(0xFF40A9FF),
    '16斋': Color(0xFF40A9FF),
    '17斋': Color(0xFFF0CD27),
    '18斋': Color(0xFF40C7CD),
    '19斋': Color(0xFFC58EB8),
    '20斋': Color(0xFFFD779C),
    '21斋': Color(0xFFFF3D3F),
    '22斋': Color(0xFFFF9449),
    '23斋': Color(0xFFFFC130),
    '24斋': Color(0xFF73D13D),
    '25斋': Color(0xFF40A9FF),
    '26斋': Color(0xFF9254DE),
  };

  bool reverse = false;
  int changeContainerState = 0;

  @override
  void initState() {
    super.initState();
    try {
      LocalSetting.changeBrightness(1);
      LocalSetting.changeSecurity(true);
    } catch (e) {
      ToastProvider.error('亮度调节失败');
    }

    ///循环执行
    ///间隔1秒
    _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      if (changeContainerState < 3)
        changeContainerState++;
      else
        changeContainerState = 0;
      setState(() {
        if (changeContainerState == 0) reverse = !reverse;
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
    return WillPopScope(
      onWillPop: () async {
        try {
          LocalSetting.changeBrightness(-1);
          LocalSetting.changeSecurity(false);
        } catch (e) {
          ToastProvider.error('亮度调节失败');
        }
        return true;
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 4000),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: reverse ? Alignment(0, 0.2) : Alignment(0, 1.6),
            colors: [
              mainColor[CommonPreferences.area.value] ?? Color(0xFF4F4F4F),
              assistColor[CommonPreferences.building.value] ?? Colors.white70
            ],
          ),
        ),
        child: Stack(
          children: [
            Align(
                alignment: Alignment.bottomRight,
                child: SvgPicture.asset('assets/images/peiyang_shield.svg',
                    width: WePeiYangApp.screenWidth * 0.7,
                    fit: BoxFit.fitWidth)),
            Align(
                alignment: Alignment.bottomRight,
                child: WButton(
                  onPressed: () {
                    try {
                      LocalSetting.changeBrightness(-1);
                    } catch (e) {
                      ToastProvider.error('亮度调节失败');
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SvgPicture.asset('assets/svg_pics/half_black.svg',
                        color: Colors.white, width: 30.w, fit: BoxFit.fitWidth),
                  ),
                )),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WButton(
                      onPressed: () {
                        try {
                          LocalSetting.changeBrightness(-1);
                          LocalSetting.changeSecurity(false);
                        } catch (e) {
                          ToastProvider.error('亮度调节失败');
                        }
                        Navigator.pop(context);
                      },
                      child: SvgPicture.asset('assets/svg_pics/domain_back.svg',
                          width: 28.w, height: 28.w),
                    ),
                    SizedBox(height: 34.w),
                    Text('请向志愿者出示您的号码牌',
                        style: TextUtil.base.white.sp(18).w700),
                    SizedBox(height: 8.w),
                    Text('Please show your number to the volunteer',
                        style: TextUtil.base.white.sp(16).w700),
                    SizedBox(height: 10.w),
                    Container(
                        padding: EdgeInsets.symmetric(vertical: 6.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${CommonPreferences.area.value}',
                                style: TextUtil.base.white.sp(78).w900.h(1.4)),
                            Text(
                                '${CommonPreferences.building.value}\n${CommonPreferences.room.value}',
                                style: TextUtil.base.white.sp(78).w900.h(1.4)),
                          ],
                        ),
                        decoration: BoxDecoration(
                            border: Border.symmetric(
                                horizontal: BorderSide(color: Colors.white)))),
                    SizedBox(height: 10.w),
                    Text(
                        '${CommonPreferences.department.value}  ${CommonPreferences.realName.value}',
                        style: TextUtil.base.white.sp(17).w700),
                    SizedBox(height: 4.w),
                    Text(
                        '${CommonPreferences.userNumber.value == '' ? '请绑定办公网' : CommonPreferences.userNumber.value}',
                        style: TextUtil.base.white.sp(17).w700),
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
                    SizedBox(height: 20.w)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
