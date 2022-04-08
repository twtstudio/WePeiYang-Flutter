import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/network/theme_service.dart';

import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/main.dart';

import '../../auth_router.dart';
import '../../skin_utils.dart';

class ThemeChangePage extends StatefulWidget {
  @override
  _ThemeChangePageState createState() => _ThemeChangePageState();
}

class _ThemeChangePageState extends State<ThemeChangePage>
    with TickerProviderStateMixin {
  var pref = CommonPreferences();
  List<Skin> skins = [];
  bool isReady = false;
  int selected;

  Widget ThemeCard(int index) {
    return InkWell(
      onTap: () {
        setState(() {
          selected = skins[index].id;
          pref.skinNow.value = skins[index].id;
        selected = skins[index].id;
        CommonPreferences().isSkinUsed.value = true;
        CommonPreferences().skinMain.value = skins[index].mainPageImage;
        CommonPreferences().skinClass.value = skins[index].schedulePageImage;
        CommonPreferences().skinProfile.value = skins[index].selfPageImage;
        CommonPreferences().skinColorA.value = skins[index].colorA;
        CommonPreferences().skinColorB.value = skins[index].colorB;
        CommonPreferences().skinColorC.value = skins[index].colorC;
        CommonPreferences().skinColorD.value = skins[index].colorD;
        CommonPreferences().skinColorE.value = skins[index].colorE;
        CommonPreferences().skinColorF.value = skins[index].colorF;
      });},
      child: AnimatedContainer(
        height: selected == skins[index].id
            ? (WePeiYangApp.screenWidth - 28) * 0.5
            : (WePeiYangApp.screenWidth - 28) * 0.3,
        margin: EdgeInsets.fromLTRB(14, 12, 14, 2),
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOutBack,
        child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(skins[index].selfPageImage, fit: BoxFit.fitWidth),
                Positioned(
                    bottom: 4, right: 8, child: TextPod(skins[index].name)),
              ],
            )),
      ),
    );
  }

  Widget DefaultThemeCard(int ind) {
    return InkWell(
      onTap: () => setState(() {
        selected = ind;
        pref.skinNow.value = ind;
      }),
      child: AnimatedContainer(
        height: selected == ind
            ? (WePeiYangApp.screenWidth - 28) * 0.5
            : (WePeiYangApp.screenWidth - 28) * 0.3,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOutBack,
        margin: EdgeInsets.fromLTRB(14, 6, 14, 6),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)), color: Colors.black12),
        child: Column(
          children: [
            Expanded(
              child: Container(
                  margin: selected != ind ? EdgeInsets.all(0) : EdgeInsets.all(4),
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset('assets/images/user_back.png',
                              fit: BoxFit.fitWidth),
                          ColoredBox(
                              color: ind == -1 ? Colors.white54 : Colors.black12),
                          if (selected == ind)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                  padding: EdgeInsets.only(right: 18),
                                  child: Icon(Icons.check,
                                      color: Colors.white, size: 20)),
                            ),
                          Positioned(
                            bottom: 4,
                            right: 8,
                            child: TextPod(ind == -1 ? '默认-白' : '默认-黑'),
                          )
                        ],
                      ))),
            ),
            if (selected == ind) Padding(
              padding: EdgeInsets.fromLTRB(2, 0, 2, 2),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  onTap: () =>
                      Navigator.pushNamed(context, AuthRouter.colorSetting)
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
                          width: MediaQuery.of(context).size.width / 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('调色盘（继续自定义）',
                                  style: TextUtil.base.sp(14).mainColor.w700),
                              SizedBox(height: 3),
                              Text(S.current.setting_color_hint,
                                  style: TextUtil.base.sp(10).grey97.w400)
                            ],
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 22)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    selected = pref.skinNow.value;
    ThemeService.loginFromClient(onSuccess: () async {
      await ThemeService.getSkins().then((list) {
        skins.clear();
        skins.addAll(list);
        setState(() {
          isReady = true;
        });
      });
    }, onFailure: () {
    });
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
        body: isReady
            ? ListView.builder(
                itemCount: skins.length + 1,
                physics: BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0)
                    return Column(
                      children: [DefaultThemeCard(-1), DefaultThemeCard(-2)],
                    );
                  index--;
                  return ThemeCard(index);
                },
              )
            : Center(child: Loading()));
  }
}
