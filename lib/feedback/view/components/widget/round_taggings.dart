import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/view/person_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/search_result_page.dart';

import '../../../../commons/preferences/common_prefs.dart';
import '../../../../commons/themes/template/wpy_theme_data.dart';
import '../../../../commons/themes/wpy_theme.dart';
import '../../../../commons/widgets/w_button.dart';

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
                style: TextUtil.base.w500.NotoSansSC
                    .sp(10)
                    .primaryAction(context)),
          );
  }
}

class ETagUtil {
  final Color colorA, colorB;
  final String text, fullName;

  ETagUtil(this.colorA, this.colorB, this.text, this.fullName);
}

class ETagWidget extends StatefulWidget {
  final String entry;
  final bool full;

  const ETagWidget({Key? key, required this.entry, required this.full})
      : super(key: key);

  State<StatefulWidget> createState() => _ETagWidgetState();
}

class _ETagWidgetState extends State<ETagWidget> {
  bool colorState = false;
  var timeDuration = Duration(milliseconds: 1900);

  @override
  Widget build(BuildContext context) {
    Map<String, ETagUtil> tagUtils = {
      'recommend': ETagUtil(
        WpyTheme.of(context).get(WpyColorKey.elegantPostTagColor),
        WpyTheme.of(context).get(WpyColorKey.elegantLongPostTagColor),
        '精',
        '精华帖',
      ),
      'theme': ETagUtil(
        WpyTheme.of(context).get(WpyColorKey.activityPostTagColor),
        WpyTheme.of(context).get(WpyColorKey.activityPostLongTagColor),
        '活动',
        '活动帖',
      ),
      'top': ETagUtil(
        WpyTheme.of(context).get(WpyColorKey.pinedPostTagAColor),
        WpyTheme.of(context).get(WpyColorKey.pinedPostTagDColor),
        '置顶',
        '置顶帖',
      )
    };
    return Container(
      padding: EdgeInsets.fromLTRB(3.5, 2, 3.5, 2),
      margin: EdgeInsets.only(right: 5),
      child: Text(
        widget.full
            ? tagUtils[widget.entry]!.fullName
            : tagUtils[widget.entry]!.text,
        style: TextUtil.base.NotoSansSC.w800.sp(12).reverse(context),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment(0.4, 1.6),
          colors: [
            tagUtils[widget.entry]!.colorA,
            tagUtils[widget.entry]!.colorB
          ],
        ),
      ),
    );
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
        if (id == -1) {
          Navigator.pushNamed(
            context,
            FeedbackRouter.searchResult,
            arguments: SearchResultPageArgs('$tag', '', '', '模糊搜索#$tag', 2, 0),
          );
        } else if (type == 0) {
          Navigator.pushNamed(
            context,
            FeedbackRouter.searchResult,
            arguments: SearchResultPageArgs('', '', '', '$tag 分区详情', tar, 0),
          );
        } else if (type == 1) {
          Navigator.pushNamed(
            context,
            FeedbackRouter.searchResult,
            arguments: SearchResultPageArgs('', '', '$id', '部门 #$tag', 1, 0),
          );
        } else {
          Navigator.pushNamed(
            context,
            FeedbackRouter.searchResult,
            arguments:
                SearchResultPageArgs('', '$id', '', '标签 #$tag', 0, lakeType),
          );
        }
      },
      child: Container(
        height: 20,
        child: (tag != '')
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
                          ? WpyTheme.of(context).get(WpyColorKey.tagLabelColor)
                          : type == 1
                              ? WpyTheme.of(context)
                                  .get(WpyColorKey.defaultActionColor)
                              : WpyTheme.of(context)
                                  .get(WpyColorKey.primaryBackgroundColor),
                    ),
                    child: SvgPicture.asset(
                      type == 0
                          ? "assets/svg_pics/lake_butt_icons/hashtag.svg"
                          : type == 1
                              ? "assets/svg_pics/lake_butt_icons/flag.svg"
                              : "assets/svg_pics/lake_butt_icons/hashtag.svg",
                      colorFilter: ColorFilter.mode(
                          WpyTheme.of(context)
                              .get(WpyColorKey.primaryActionColor),
                          BlendMode.srcIn),
                    ),
                  ),
                  SizedBox(width: type == 0 ? 0 : 2),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: width - 30),
                    child: Text(
                      tag,
                      style: TextUtil.base.NotoSansSC.w400
                          .sp(14)
                          .primaryAction(context),
                      strutStyle: StrutStyle(
                        forceStrutHeight: true,
                        fontSize: 14,
                        height: 1.4,
                      ),
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
          color:
              WpyTheme.of(context).get(WpyColorKey.backgroundGradientEndColor),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: WpyTheme.of(context)
                  .get(WpyColorKey.reverseBackgroundColor)
                  .withValues(alpha: 0.38))),
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
      child: Text(text,
          style: TextUtil.base.NotoSansSC.w400.sp(12).infoText(context)),
    );
  }
}

class AvatarPlaceholder extends StatelessWidget {
  const AvatarPlaceholder(
      {super.key, required this.nickname, required this.uid});

  final String nickname;
  final int uid;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: () {
        final colorList =
            WpyTheme.of(context).getColorSet(WpyColorSetKey.levelColors);
        int random = uid % colorList.length;
        return colorList[random];
      }(),
      child: Center(
        child: Text(
          () {
            String shortName = nickname
                .replaceAll(RegExp(r'[\d\*\s]'), '')
                .replaceAll(RegExp(r'[^\u4e00-\u9fa5]'), '');

            return shortName.isNotEmpty
                ? shortName.substring(0, 1)
                : nickname.substring(0, 1);
          }(),
          style: TextUtil.base.NotoSansSC.w400
              .sp(16)
              .bright(context)
              .copyWith(height: 0.8),
        ),
      ),
    );
  }
}

class ProfileImageWithDetailedPopup extends StatefulWidget {
  final int postOrCommentId;
  final bool fromPostCard;
  final int type;
  final int uid;
  final String avatar;
  final String nickName;
  final String level;
  final String heroTag;
  final String avatarBox;

  ProfileImageWithDetailedPopup(
      this.postOrCommentId,
      this.fromPostCard,
      this.type,
      this.avatar,
      this.uid,
      this.nickName,
      this.level,
      this.heroTag,
      this.avatarBox);

  static WidgetBuilder defaultPlaceholderBuilder =
      (BuildContext ctx) => SizedBox(
            width: 24.h,
            height: 24.h,
            child: FittedBox(fit: BoxFit.fitWidth, child: Loading()),
          );

  @override
  State<ProfileImageWithDetailedPopup> createState() =>
      _ProfileImageWithDetailedPopupState();
}

class _ProfileImageWithDetailedPopupState
    extends State<ProfileImageWithDetailedPopup> {
  bool get hasAdmin =>
      CommonPreferences.isSchAdmin.value ||
      CommonPreferences.isStuAdmin.value ||
      CommonPreferences.isSuper.value;

  @override
  Widget build(BuildContext ctx) {
    return WButton(
      onPressed: () {
        if ((widget.type != 1) || hasAdmin)
          Navigator.pushNamed(context, FeedbackRouter.person,
              arguments: PersonPageArgs(
                  widget.postOrCommentId,
                  widget.fromPostCard,
                  widget.type,
                  widget.uid,
                  widget.avatar,
                  widget.nickName,
                  widget.level,
                  widget.heroTag));
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            child: SizedBox(
              height: 32,
              width: 32,
              child: (widget.type == 1 || widget.avatar == '')
                  ? AvatarPlaceholder(
                      nickname: widget.nickName, uid: widget.uid)
                  : WpyPic(
                      width: 32,
                      height: 32,
                      'https://qnhdpic.twt.edu.cn/download/origin/${widget.avatar}',
                      fit: BoxFit.cover,
                      withCache: true,
                      withHolder: false,
                    ),
            ),
          ),
          if (widget.avatarBox != '' &&
              widget.avatarBox != 'Error' &&
              widget.type != 1 &&
              widget.avatarBox.length > 5)
            SizedBox(
              width: 32,
              height: 32,
              child: OverflowBox(
                maxWidth: 60,
                maxHeight: 60,
                child: WpyPic(
                  width: 60,
                  height: 60,
                  widget.avatarBox,
                  fit: BoxFit.contain,
                  reduce: false,
                  withCache: true,
                  withHolder: false,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
