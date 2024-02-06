import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/auth/view/user/user_avatar_image.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';

class AvatarBoxPage extends StatefulWidget {
  @override
  _AvatarBoxPageState createState() => _AvatarBoxPageState();
}

class _AvatarBoxPageState extends State<AvatarBoxPage> {
  ValueNotifier<String> _valueNotifier =
      ValueNotifier<String>(CommonPreferences.avatarBoxMyUrl.value);

  @override
  void initState() {
    super.initState();
    _valueNotifier.value = CommonPreferences.avatarBoxMyUrl.value;
  }

  @override
  void dispose() {
    _valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        title: Text(
          '更换头像框',
          style: TextUtil.base.label(context).sp(16),
        ),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: WButton(
              child: Icon(Icons.arrow_back,
                  color:
                      WpyTheme.of(context).get(WpyColorKey.defaultActionColor),
                  size: 32),
              onPressed: () => Navigator.pop(context)),
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              width: 1.sw,
              height: 0.3.sh,
              child: Stack(
                children: [
                  ValueListenableBuilder<String>(
                      valueListenable: _valueNotifier,
                      builder: (c, i, _) {
                        return Center(
                          child: Hero(
                            tag: 'avatar',
                            child: UserAvatarImage(
                              size: 0.3.sw,
                              iconColor: WpyTheme.of(context)
                                  .get(WpyColorKey.primaryBackgroundColor),
                              tempUrl: _valueNotifier.value,
                              context: context,
                            ),
                          ),
                        );
                      }),
                  Align(
                    alignment: Alignment(0, 0.8),
                    child: Text(
                      '点击下方头像框预览',
                      style: TextUtil.base.w400.customColor(WpyTheme.of(context).get(WpyColorKey.oldHintColor)).sp(16),
                    ),
                  ),
                ],
              ),
            ),
            AvatarListBuilder(_valueNotifier),
          ],
        ),
      ),
    );
  }
}

class AvatarListBuilder extends StatefulWidget {
  final ValueNotifier<String> valueNotifier;

  AvatarListBuilder(this.valueNotifier);

  @override
  _AvatarListBuilderState createState() => _AvatarListBuilderState();
}

class _AvatarListBuilderState extends State<AvatarListBuilder> {
  ValueNotifier<int> currentIndex = ValueNotifier<int>(-1);

  /// 当level < comment时，判断为不可用
  List<bool> canChange = [];

  List<AvatarBox> avatarList = [];

  Future<void> loadAvatarBox() async {
    avatarList.clear();
    avatarList = await FeedbackService.getAllAvatarBox();
    canChange.clear();
    avatarList.forEach((e) {
      int degree = 0;
      degree = int.tryParse(e.comment) ?? 100;
      if (CommonPreferences.level.value >= degree) {
        canChange.add(true);
      } else
        canChange.add(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadAvatarBox(),
      builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
        switch (asyncSnapshot.connectionState) {
          case ConnectionState.none:
            return Text('none');
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          case ConnectionState.active:
            return Center(child: CircularProgressIndicator());
          case ConnectionState.done:
            if (asyncSnapshot.hasError)
              return Center(child: CircularProgressIndicator());
            else
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 300.h,
                      child: GridView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: avatarList.length,
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 0,
                            childAspectRatio: 1.3,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: 14.h),
                                  WButton(
                                    onPressed: () async {
                                      if (canChange[index]) {
                                        widget.valueNotifier.value =
                                            avatarList[index].addr;
                                        currentIndex.value = index;
                                      } else {
                                        ToastProvider.running('(つд⊂)还未解锁哦~');
                                      }
                                    },
                                    child: ValueListenableBuilder(
                                      valueListenable: currentIndex,
                                      builder: (a, i, c) {
                                        return avatarBoxCard(
                                            avatarList[index],
                                            currentIndex.value == index,
                                            canChange[index]);
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 5.h),
                                    child: SizedBox(
                                        width: 100.h,
                                        child: Text(
                                          '${avatarList[index].name}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextUtil.base.w200
                                              .infoText(context)
                                              .sp(16),
                                        )),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.only(bottom: 50.h),
                      child: WButton(
                        onPressed: () async {
                          if (currentIndex.value < 0) {
                            ToastProvider.running('(›´ω`‹ )请选择一个头像框~');
                          } else {
                            FeedbackService.setAvatarBox(
                                avatarList[currentIndex.value]);
                            CommonPreferences.avatarBoxMyUrl.value =
                                avatarList[currentIndex.value].addr;
                          }
                        },
                        child: Container(
                          width: 110.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: WpyTheme.of(context)
                                .get(WpyColorKey.primaryActionColor),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.r)),
                          ),
                          child: Center(
                            child: Text(
                              '立即装扮',
                              style: TextUtil.base.reverse(context).w500.sp(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
        }
      },
    );
  }

  Widget avatarBoxCard(AvatarBox avatarBox, bool choose, bool canChange) {
    return Container(
      width: 100.w,
      height: 100.w,
      foregroundDecoration: canChange
          ? null
          : BoxDecoration(
              color: WpyTheme.of(context).get(WpyColorKey.oldListActionColor),
              backgroundBlendMode: BlendMode.saturation,
              borderRadius: BorderRadius.all(Radius.circular(10.r)),
            ),
      decoration: BoxDecoration(
        color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        borderRadius: BorderRadius.all(Radius.circular(10.r)),
        boxShadow: [
          choose == true
              ? BoxShadow(
                  color: WpyTheme.of(context).get(WpyColorKey.avatarChosenColor), blurRadius: 8, spreadRadius: 5)
              : BoxShadow(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                ),
        ],
        image: DecorationImage(
          image: NetworkImage('${avatarBox.addr}'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
