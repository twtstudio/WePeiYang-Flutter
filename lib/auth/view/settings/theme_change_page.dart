import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/network/theme_service.dart';

import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';

import '../../skin_utils.dart';

class ThemeChangePage extends StatefulWidget {
  @override
  _ThemeChangePageState createState() => _ThemeChangePageState();
}

class _ThemeChangePageState extends State<ThemeChangePage> {
  var pref = CommonPreferences();
  List<Skin> skins = [];

  Widget ThemeCard() {
    return InkWell(
      onTap: () async {
        await ThemeService.addSkin(
            onFailure: {ToastProvider.success('失败了呢')},
            onSuccess: () {
              ToastProvider.success('成功里');
            });
        print(pref.token.value);
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(14, 12, 14, 2),
        child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            child: Stack(
              children: [
                Image.asset('assets/images/lake_butt_icons/haitang_banner.png',
                    fit: BoxFit.fitWidth),
                Positioned(bottom: 4, right: 8, child: TextPod('海棠节·活动')),
              ],
            )),
      ),
    );
  }

  @override
  void initState() {
    ThemeService.loginFromClient(
        onSuccess: () async {
          ToastProvider.success(CommonPreferences().themeToken.value);
          await ThemeService.getSkins(
              onFailure: {ToastProvider.success('oshuhd')},
              onResult: (List<Skin> data) {
                skins.addAll(data);
                print(skins);
              });
        },
        onFailure: {ToastProvider.success('oshuhd')});
    //onFailure: ToastProvider.error('皮肤界面登录失败'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('主题皮肤',
                style: FontManager.YaHeiRegular.copyWith(
                    fontSize: 16,
                    color: Color.fromRGBO(36, 43, 69, 1),
                    fontWeight: FontWeight.bold)),
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
        body: ListView.builder(
          itemCount: 5,
          physics: BouncingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return ThemeCard();
          },
        ));
  }
}
