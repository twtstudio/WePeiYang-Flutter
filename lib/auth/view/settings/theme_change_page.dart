import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/network/theme_service.dart';

import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
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
    with SingleTickerProviderStateMixin {
  List<Skin> skins = [];
  bool isReady = false;
  int selected;
  bool isSelected = false;
  bool canRefresh = true;
  String process = '';
  TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = new TextEditingController();
    if (CommonPreferences.skinNow.value == 0 ||
        CommonPreferences.skinNow.value == null)
      CommonPreferences.skinNow.value = -1;
    selected = CommonPreferences.skinNow.value;
    CommonPreferences.themeToken.clear();
    ThemeService.loginFromClient(onSuccess: () async {
      await ThemeService.getSkins().then((list) {
        skins.clear();
        skins.addAll(list);
        setState(() {
          isReady = true;
        });
      });
    });
    //onFailure: ToastProvider.error('皮肤界面登录失败'));
    super.initState();
  }

  void sure() async {
    await FeedbackService.getPostById(
        id: int.parse(_textEditingController.text.toString()),
        onResult: (Post post) {
          FocusManager.instance.primaryFocus.unfocus();
          process = '';
          if (post.isOwner) {
            Future.delayed(Duration(milliseconds: 1000)).then((_) {
              setState(() {
                process = process + '该帖由您发出';
              });
              if (post.createAt.toLocal().isAfter(DateTime(2022, 4, 8))) {
                Future.delayed(Duration(milliseconds: 1000)).then((_) {
                  setState(() {
                    process = process + '\n该帖符合时间要求（4/8日前）';
                  });
                  if (post.tag.name == '海棠季') {
                    Future.delayed(Duration(milliseconds: 1000)).then((_) {
                      setState(() {
                        process = process + '\n该帖符合tag要求（海棠季）';
                      });
                      if (post.likeCount >= 15) {
                        Future.delayed(Duration(milliseconds: 1000)).then((_) {
                          setState(() {
                            process = process + '\n该帖符合点赞要求（15+）\n恭喜你获得海棠季限定皮肤';
                          });
                          ThemeService.postMeSkin(
                              skinId: 1271410690,
                              onSuccess: () async {
                                await ThemeService.getSkins().then((list) {
                                  skins.clear();
                                  skins.addAll(list);
                                  setState(() {
                                    isReady = true;
                                  });
                                });
                              },
                              onFailure: () =>
                                  ToastProvider.error('获得皮肤失败（或已经拥有该皮肤）'));
                        });
                      } else
                        setState(() {
                          process = process + '\n该帖不符合点赞要求（15+）';
                        });
                    });
                  } else
                    setState(() {
                      process = process + '\n该帖不符合时间要求（4/8日前）';
                    });
                });
              } else
                setState(() {
                  process = process + '\n该帖不符合时间要求（4/8日前）';
                });
            });
          } else
            setState(() {
              process = process + '\n该帖不是您的帖子';
            });
        },
        onFailure: (_) => ToastProvider.error('拉取帖子失败'));
  }

  Widget ActionCard() {
    return DateTime.now().toLocal().isAfter(DateTime(2022, 4, 19))
        ? SizedBox()
        : AnimatedSize(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOutBack,
            vsync: this,
            child: Container(
              width: WePeiYangApp.screenWidth - 28,
              padding: EdgeInsets.all(6),
              margin: EdgeInsets.fromLTRB(14, 12, 14, 2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  color: Color(0xCFF7E4E4)),
              child: Column(
                children: [
                  InkWell(
                      onTap: () => setState(() {
                            isSelected = !isSelected;
                          }),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 8, 0, 10),
                          child: Text('集赞兑换海棠季主题',
                              style: TextUtil.base.sp(16).mainColor.w600),
                        ),
                      )),
                  if (isSelected)
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          color: Colors.black12),
                      child: Row(
                        children: [
                          SizedBox(width: 14),
                          Text('MP', style: TextUtil.base.sp(18).black00.w600),
                          SizedBox(width: 2),
                          Expanded(
                            child: TextField(
                              style: TextUtil.base.w400.NotoSansSC
                                  .sp(16)
                                  .h(1.4)
                                  .black00,
                              controller: _textEditingController,
                              maxLength: 200,
                              textInputAction: TextInputAction.send,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  counterText: '',
                                  hintText: '输入MP号以兑换（纯数字）',
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12))),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 20),
                                  fillColor: Colors.white,
                                  filled: true,
                                  isDense: true,
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.check),
                                    onPressed: () {
                                      sure();
                                    },
                                  )),
                              onEditingComplete: () => sure(),
                              minLines: 1,
                              maxLines: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 4),
                  if (isSelected && process != '')
                    Center(
                        child: Text(process,
                            style: TextUtil.base.sp(12).greyA6.w600))
                ],
              ),
            ),
          );
  }

  Widget ThemeCard(int index) {
    return InkWell(
      onTap: () {
        setState(() {
          selected = skins[index].id;
          CommonPreferences.isSkinUsed.value = true;
          CommonPreferences.isAprilFoolClass.value = false;
          CommonPreferences.skinMain.value = skins[index].mainPageImage;
          CommonPreferences.skinClass.value = skins[index].schedulePageImage;
          CommonPreferences.skinProfile.value = skins[index].selfPageImage;
          CommonPreferences.skinColorA.value = skins[index].colorA;
          CommonPreferences.skinColorB.value = skins[index].colorB;
          CommonPreferences.skinColorC.value = skins[index].colorC;
          CommonPreferences.skinColorD.value = skins[index].colorD;
          CommonPreferences.skinColorE.value = skins[index].colorE;
          CommonPreferences.skinColorF.value = skins[index].colorF;
        });
      },
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
                if (selected == skins[index].id)
                  Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        height: double.infinity,
                        color: Colors.black38,
                        padding: EdgeInsets.only(right: 6, left: 4),
                        child: Column(
                          children: [
                            Spacer(),
                            TextPod(skins[index].name),
                            SizedBox(height: 4)
                          ],
                        ),
                      )),
                if (selected == skins[index].id)
                  Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 28.0),
                        child: Icon(Icons.check, color: Colors.white, size: 20),
                      )),
                if (selected == skins[index].id)
                  Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                          padding: const EdgeInsets.only(left: 18, top: 10),
                          child: Text(skins[index].description,
                              style: TextUtil.base.sp(18).white.w600))),
              ],
            )),
      ),
    );
  }

  Widget DefaultThemeCard(int ind) {
    return InkWell(
      onTap: () => setState(() {
        selected = ind;
        CommonPreferences.skinNow.value = ind;
        CommonPreferences.isSkinUsed.value = false;
        CommonPreferences.isDarkMode.value = ind == -1 ? false : true;
      }),
      child: AnimatedContainer(
        height: selected == ind
            ? (WePeiYangApp.screenWidth - 28) * 0.5
            : (WePeiYangApp.screenWidth - 28) * 0.3,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOutBack,
        margin: EdgeInsets.fromLTRB(14, 6, 14, 6),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.black12),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                  padding:
                      selected != ind ? EdgeInsets.all(0) : EdgeInsets.all(4),
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset('assets/images/user_back.png',
                              fit: BoxFit.fitWidth),
                          ColoredBox(
                              color:
                                  ind == -1 ? Colors.white54 : Colors.black12),
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
                            child: TextPod(ind == -1 ? '默认-白' : '敬请期待'),
                          )
                        ],
                      ))),
            ),
            if (selected == ind)
              Padding(
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
                                Text('调色板（继续自定义）',
                                    style: TextUtil.base.sp(14).mainColor.w700),
                                SizedBox(height: 3),
                                Text(S.current.setting_color_hint,
                                    style: TextUtil.base.sp(10).grey97.w400)
                              ],
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.arrow_forward_ios,
                              color: Colors.grey, size: 22)
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('主题皮肤',
              style: TextUtil.base.bold
                  .sp(16)
                  .h(1.2)
                  .customColor(Color.fromRGBO(36, 43, 69, 1))),
          elevation: 0,
          brightness: Brightness.light,
          centerTitle: false,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(53, 59, 84, 1.0), size: 32),
                onTap: () => Navigator.pop(context)),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: canRefresh
                  ? GestureDetector(
                      child: Icon(Icons.loop,
                          color: ColorUtil.mainColor, size: 25),
                      onTap: () {
                        setState(() {
                          canRefresh = false;
                        });
                        if (CommonPreferences.skinNow.value == 0 ||
                            CommonPreferences.skinNow.value == null)
                          CommonPreferences.skinNow.value = -1;
                        selected = CommonPreferences.skinNow.value;
                        CommonPreferences.themeToken.clear();
                        ThemeService.loginFromClient(onSuccess: () async {
                          await ThemeService.getSkins().then((list) {
                            skins.clear();
                            skins.addAll(list);
                            setState(() {
                              isReady = true;
                            });
                          });
                        });
                        Future.delayed(Duration(milliseconds: 3000)).then((_) {
                          setState(() {
                            canRefresh = true;
                          });
                        });
                      })
                  : Center(
                      child: Text('刷新中',
                          style: TextUtil.base.sp(14).grey6C.w700.h(0.8))),
            ),
          ],
        ),
        body: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            DefaultThemeCard(-1),
            DefaultThemeCard(-2),
            if (isReady) ActionCard(),
            isReady
                ? Column(
                    children: List<Widget>.generate(
                        skins.length, (index) => ThemeCard(index)))
                : Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text('加载在线皮肤中 点击右上角刷新\n',
                            style: TextUtil.base.sp(14).grey6C.w700.h(0.8)),
                        Loading(),
                      ],
                    ))
          ],
        ));
  }
}
