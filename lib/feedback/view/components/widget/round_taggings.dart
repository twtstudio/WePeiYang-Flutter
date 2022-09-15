import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

import '../../../../main.dart';
import '../../../feedback_router.dart';
import '../../search_result_page.dart';

class CommentIdentificationContainer extends StatelessWidget {
  final String text;
  final bool active;

  CommentIdentificationContainer(this.text, this.active);

  @override
  Widget build(BuildContext context) {
    return text == ''
        ? SizedBox()
        : Container(
            margin: EdgeInsets.only(left: 3),
            child: Text(this.text,
                style: TextUtil.base.w500.NotoSansSC.sp(10).blue2C),
          );
  }
}

class ETagUtil {
  final Color colorA, colorB;
  final String text, fullName;

  ETagUtil._(this.colorA, this.colorB, this.text, this.fullName);

  factory ETagUtil.empty() {
    return ETagUtil._(Colors.white, Colors.white, '', '');
  }
}

class ETagWidget extends StatefulWidget {
  @required
  final String entry;
  final bool full;

  @required
  const ETagWidget({Key key, this.entry, this.full}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ETagWidgetState();
  }
}

class _ETagWidgetState extends State<ETagWidget> {
  _ETagWidgetState();

  bool colorState = false;
  Timer timer;
  Duration timeDuration = Duration(milliseconds: 1900);
  Map<String, ETagUtil> tagUtils = {
    'recommend': new ETagUtil._(Color.fromRGBO(232, 178, 27, 1.0),
        Color.fromRGBO(236, 120, 57, 1.0), '精', '精华帖'),
    'theme': new ETagUtil._(Color.fromRGBO(66, 161, 225, 1.0),
        Color.fromRGBO(57, 90, 236, 1.0), '活动', '活动帖'),
    'top': new ETagUtil._(Color.fromRGBO(223, 108, 171, 1.0),
        Color.fromRGBO(243, 16, 73, 1.0), '置顶', '置顶帖')
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(3.5, 2, 3.5, 2),
      margin: EdgeInsets.only(right: 5),
      child: Text(
        widget.full
            ? tagUtils[widget.entry].fullName
            : tagUtils[widget.entry].text ?? '',
        style: TextUtil.base.NotoSansSC.w800.sp(12).white,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment(0.4, 1.6),
          colors: [
            tagUtils[widget.entry].colorA,
            tagUtils[widget.entry].colorB
          ],
        ),
      ),
    );
  }
}

class MPWidget extends StatelessWidget {
  final String text;

  MPWidget(this.text);

  @override
  Widget build(BuildContext context) {
    return Text('#MP' + this.text,
        style: TextUtil.base.ProductSans.w400.grey97.sp(12));
  }
}

class SolveOrNotWidget extends StatelessWidget {
  final int index;

  SolveOrNotWidget(this.index);

  @override
  Widget build(BuildContext context) {
    switch (index) {
      //未分发
      case 0:
        return Image.asset(
          'assets/images/lake_butt_icons/tag_not_processed.png',
          width: 60,
          fit: BoxFit.fitWidth,
        );
      //已分发
      case 3:
        return Image.asset(
          'assets/images/lake_butt_icons/tag_processed.png',
          width: 60,
          fit: BoxFit.fitWidth,
        );
      //未解决 现在改名叫已回复
      case 1:
        return Image.asset(
          'assets/images/lake_butt_icons/tag_replied.png',
          width: 60,
          fit: BoxFit.fitWidth,
        );
      //已解决
      case 2:
        return Image.asset(
          'assets/images/lake_butt_icons/tag_solved.png',
          width: 60,
          fit: BoxFit.fitWidth,
        );
      default:
        return SizedBox();
    }
  }
}

class TagShowWidget extends StatelessWidget {
  final String tag;
  final double width;

  ///0 湖底 1 校务 2 分区
  final int type;
  final int id;
  final int tar;
  final int lakeType;

  TagShowWidget(
      this.tag, this.width, this.type, this.id, this.tar, this.lakeType);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        id == -1
            ? Navigator.pushNamed(
                context,
                FeedbackRouter.searchResult,
                arguments:
                    SearchResultPageArgs('$tag', '', '', '模糊搜索#$tag', 2, 0),
              )
            : type == 0
                ? {
                    Navigator.pushNamed(
                      context,
                      FeedbackRouter.searchResult,
                      arguments:
                          SearchResultPageArgs('', '', '', '$tag 分区详情', tar, 0),
                    )
                  }
                : type == 1
                    ? Navigator.pushNamed(
                        context,
                        FeedbackRouter.searchResult,
                        arguments: SearchResultPageArgs(
                            '', '', '$id', '部门 #$tag', 1, 0),
                      )
                    : Navigator.pushNamed(
                        context,
                        FeedbackRouter.searchResult,
                        arguments: SearchResultPageArgs(
                            '', '$id', '', '标签 #$tag', 0, lakeType),
                      );
      },
      child: Container(
        height: 20,
        child: (tag != null && tag != "")
            ? Row(
                children: [
                  Container(
                    height: 14,
                    width: 14,
                    alignment: Alignment.center,
                    margin: EdgeInsets.fromLTRB(3, 3, 2, 3),
                    padding: EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: type == 0
                          ? Color(0xffeaeaea)
                          : type == 1
                              ? ColorUtil.mainColor
                              : Colors.white,
                    ),
                    child: SvgPicture.asset(
                      type == 0
                          ? "assets/svg_pics/lake_butt_icons/hashtag.svg"
                          : type == 1
                              ? "assets/svg_pics/lake_butt_icons/flag.svg"
                              : "assets/svg_pics/lake_butt_icons/hashtag.svg",
                    ),
                  ),
                  SizedBox(width: type == 0 ? 0 : 2),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: width - 30),
                    child: Text(
                      tag ?? '',
                      style: TextUtil.base.NotoSansSC.w400.sp(14).blue2C,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8)
                ],
              )
            : SizedBox(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1080),
        ),
      ),
    );
  }
}

class TextPod extends StatelessWidget {
  final String text;

  TextPod(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white54,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black38)),
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
      child: Text(text, style: TextUtil.base.NotoSansSC.w400.sp(12).grey6C),
    );
  }
}

class ProfileImageWithDetailedPopup extends StatelessWidget {
  final int type;
  final int uid;
  final String avatar;
  final String nickName;

  ProfileImageWithDetailedPopup(
      this.type, this.avatar, this.uid, this.nickName);

  static WidgetBuilder defaultPlaceholderBuilder =
      (BuildContext ctx) => SizedBox(
            width: 24,
            height: 24,
            child: FittedBox(fit: BoxFit.fitWidth, child: Loading()),
          );

  @override
  Widget build(BuildContext ctx) {
    return InkWell(
      onTap: () => showDialog(
        context: ctx,
        barrierDismissible: true,
        builder: (BuildContext context) => Stack(
          children: [
            Align(
              alignment: Alignment(0, -0.2),
              child: Container(
                  constraints:
                      BoxConstraints(maxWidth: WePeiYangApp.screenWidth - 40),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (avatar != '')
                            Navigator.pushNamed(
                                context, FeedbackRouter.imageView, arguments: {
                              "urlList": [avatar],
                              "urlListLength": 1,
                              "indexNow": 0
                            });
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: avatar == ""
                              ? SvgPicture.network(
                                  '${EnvConfig.QNHD}avatar/beam/20/${uid}',
                                  width: DateTime.now().month == 4 &&
                                          DateTime.now().day == 1
                                      ? 150
                                      : 200,
                                  height: DateTime.now().month == 4 &&
                                          DateTime.now().day == 1
                                      ? 150
                                      : 200,
                                  fit: BoxFit.contain,
                                  placeholderBuilder: defaultPlaceholderBuilder,
                                )
                              : Image.network(
                                  'https://qnhdpic.twt.edu.cn/download/origin/${avatar}',
                                  width: DateTime.now().month == 4 &&
                                          DateTime.now().day == 1
                                      ? 150
                                      : 200,
                                  height: DateTime.now().month == 4 &&
                                          DateTime.now().day == 1
                                      ? 150
                                      : 200,
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${type == 1 ? '用户真名：' : '用户昵称：'}\n${nickName == '' ? '没名字的微友' : nickName}',
                        style:
                            TextUtil.base.w600.NotoSansSC.sp(14).black2A.h(1.8),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      if (CommonPreferences.isSuper.value ||
                          CommonPreferences.isStuAdmin.value)
                        InkWell(
                          onTap: () =>
                              _showResetConfirmDialog(context, '昵称').then((value) {
                            if (value)
                              FeedbackService.adminResetName(
                                  id: uid,
                                  onSuccess: () {
                                    ToastProvider.success('重置成功');
                                    Navigator.pop(ctx);
                                  },
                                  onFailure: (e) {
                                    ToastProvider.error(e.message);
                                  });
                          }),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh,
                                size: 18,
                              ),
                              Text(
                                '重置昵称',
                                style: TextUtil.base.w600.NotoSansSC
                                    .sp(12)
                                    .black2A,
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 6),
                      if (CommonPreferences.isSuper.value ||
                          CommonPreferences.isStuAdmin.value)
                        InkWell(
                          onTap: () =>
                              _showResetConfirmDialog(context, '头像').then((value) {
                                if (value)
                                  FeedbackService.adminResetAva(
                                      id: uid,
                                      onSuccess: () {
                                        ToastProvider.success('重置成功');
                                        Navigator.pop(ctx);
                                      },
                                      onFailure: (e) {
                                        ToastProvider.error(e.message);
                                      });
                              }),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh,
                                size: 18,
                              ),
                              Text(
                                '重置头像',
                                style: TextUtil.base.w600.NotoSansSC
                                    .sp(12)
                                    .black2A,
                              ),
                            ],
                          ),
                        ),
                      if (CommonPreferences.isSuper.value)
                        InkWell(
                          onTap: () => Navigator.popAndPushNamed(
                              context, FeedbackRouter.openBox,
                              arguments: uid),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_search_rounded),
                              Text(
                                '开盒',
                                style: TextUtil.base.w600.NotoSansSC
                                    .sp(12)
                                    .black2A,
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 5),
                    ],
                  )),
            ),
          ],
        ),
      ),
      child: ClipRRect(
        // 保证圆角
        borderRadius: BorderRadius.all(Radius.circular(100)),
        child: avatar == ""
            ? SvgPicture.network(
                '${EnvConfig.QNHD}avatar/beam/20/${uid}',
                width: DateTime.now().month == 4 && DateTime.now().day == 1
                    ? 20.w
                    : 34.w,
                height: DateTime.now().month == 4 && DateTime.now().day == 1
                    ? 20.w
                    : 34.w,
                fit: BoxFit.contain,
                placeholderBuilder: defaultPlaceholderBuilder,
              )
            : Image.network(
                'https://qnhdpic.twt.edu.cn/download/origin/${avatar}',
                width: DateTime.now().month == 4 && DateTime.now().day == 1
                    ? 20.w
                    : 34.w,
                height: DateTime.now().month == 4 && DateTime.now().day == 1
                    ? 18.w
                    : 32.w,
                fit: BoxFit.contain,
              ),
      ),
    );
  }

  Future<bool> _showResetConfirmDialog(BuildContext context, String quote) {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return LakeDialogWidget(
              title: '重置$quote',
              content: Text('您确定要重置该用户$quote吗？'),
              cancelText: "取消",
              confirmTextStyle:
                  TextUtil.base.normal.black2A.NotoSansSC.sp(16).w400,
              cancelTextStyle:
                  TextUtil.base.normal.black2A.NotoSansSC.sp(16).w600,
              confirmText: '确认',
              cancelFun: () {
                Navigator.of(context).pop();
              },
              confirmFun: () {
                Navigator.of(context).pop(true);
              });
        });
  }
}
