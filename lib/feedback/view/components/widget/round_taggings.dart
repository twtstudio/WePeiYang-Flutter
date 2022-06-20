import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
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
            margin: EdgeInsets.only(left: 2, top: 1),
            padding: EdgeInsets.fromLTRB(4, 0.5, 4, 1.5),
            child: Text(this.text,
                style: TextUtil.base.NotoSansSC.w700.whiteFD.sp(8)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: active ? ColorUtil.mainColor : ColorUtil.grey97Color,
            ),
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
      padding: EdgeInsets.fromLTRB(3, 0.4, 2.8, 2.0),
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
        style: TextUtil.base.ProductSans.w400.mainColor.sp(12));
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
        return SvgPicture.asset(
          'assets/svg_pics/lake_butt_icons/tagNotProcessed.svg',
          width: 60,
          fit: BoxFit.fitWidth,
        );
      //已分发
      case 3:
        return SvgPicture.asset(
          'assets/svg_pics/lake_butt_icons/tagProcessed.svg',
          width: 60,
          fit: BoxFit.fitWidth,
        );
      //未解决
      case 1:
        return SvgPicture.asset(
          'assets/svg_pics/lake_butt_icons/tagNotSolved.svg',
          width: 60,
          fit: BoxFit.fitWidth,
        );
      //已解决
      case 2:
        return SvgPicture.asset(
          'assets/svg_pics/lake_butt_icons/tagSolved.svg',
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
        child: Row(
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
                    ? "assets/svg_pics/lake_butt_icons/districts.svg"
                    : type == 1
                        ? "assets/svg_pics/lake_butt_icons/flag.svg"
                        : "assets/svg_pics/lake_butt_icons/hashtag.svg",
              ),
            ),
            SizedBox(width: type == 0 ? 0 : 2),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: width - 30),
              child: Text(
                tag,
                style: TextUtil.base.NotoSansSC.w400.sp(14).grey6C,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8)
          ],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1080),
          color: Color(0xffeaeaea),
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
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black38)),
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
      child: Text(text, style: TextUtil.base.NotoSansSC.w400.sp(12).grey6C),
    );
  }
}

class ProfileImageWithDetailedPopup extends StatelessWidget {
  final int type;
  final int uid;
  final String nickname;

  ProfileImageWithDetailedPopup(this.type, this.nickname, this.uid);

  static WidgetBuilder defaultPlaceholderBuilder =
      (BuildContext ctx) => SizedBox(
            width: 24,
            height: 24,
            child: FittedBox(fit: BoxFit.fitWidth, child: Loading()),
          );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showDialog(
        context: context,
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
                      borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.fromLTRB(20, 6, 18, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${type == 1 ? '用户真名：' : '用户昵称：'}\n${nickname == '' ? '没名字的微友' : nickname}',
                        style:
                            TextUtil.base.w600.NotoSansSC.sp(16).black2A.h(2),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (CommonPreferences().isSuper.value)
                      InkWell(
                        onTap: () => Navigator.popAndPushNamed(
                            context, FeedbackRouter.openBox, arguments: uid),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_search_rounded),
                            Text(
                              '开盒',
                              style:
                                  TextUtil.base.w600.NotoSansSC.sp(12).black2A,
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
            ),
            Align(
              alignment: Alignment(0, -0.2),
              child: Padding(
                padding: EdgeInsets.only(bottom: 130),
                child: SvgPicture.network(
                  '${EnvConfig.QNHD}avatar/beam/20/${nickname}',
                  width: DateTime.now().month == 4 && DateTime.now().day == 1
                      ? 36
                      : 48,
                  height: DateTime.now().month == 4 && DateTime.now().day == 1
                      ? 36
                      : 48,
                  fit: BoxFit.contain,
                  placeholderBuilder: defaultPlaceholderBuilder,
                ),
              ),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          child: SvgPicture.network(
            '${EnvConfig.QNHD}avatar/beam/20/${nickname}',
            width:
                DateTime.now().month == 4 && DateTime.now().day == 1 ? 18 : 24,
            height:
                DateTime.now().month == 4 && DateTime.now().day == 1 ? 18 : 24,
            fit: BoxFit.contain,
            placeholderBuilder: defaultPlaceholderBuilder,
          ),
        ),
      ),
    );
  }
}
