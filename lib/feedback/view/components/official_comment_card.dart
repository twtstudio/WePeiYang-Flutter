import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/clip_copy.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/long_text_shower.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/pop_menu_shape.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/feedback/view/report_question_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

import '../../../commons/themes/template/wpy_theme_data.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/widgets/w_button.dart';

enum Official { subFloor, reply }

typedef LikeCallback = void Function(bool, int);
typedef ContentPressedCallback = void Function(void Function(List<Floor>));

class OfficialReplyCard extends StatefulWidget {
  final String tag;
  final Floor comment;
  final Official type;
  final int ancestorId;
  final ContentPressedCallback? onContentPressed;
  final LikeCallback? onLikePressed;

  ///是否显示楼中楼
  final bool detail;
  final int placeAppeared;

  ///评分数
  final int ratings;

  OfficialReplyCard.reply({
    this.tag = '',
    required this.comment,
    required this.ratings,
    required this.ancestorId,
    this.onContentPressed,
    this.onLikePressed,
    required this.placeAppeared,
  })  : type = Official.reply,
        detail = false;

  OfficialReplyCard.subFloor({
    this.tag = '',
    required this.comment,
    required this.ratings,
    required this.ancestorId,
    this.onContentPressed,
    this.onLikePressed,
    required this.placeAppeared,
  })  : type = Official.subFloor,
        detail = true;

  @override
  _OfficialReplyCardState createState() => _OfficialReplyCardState();
}

class _OfficialReplyCardState extends State<OfficialReplyCard> {
  late double _rating;
  late double _initialRating;

  Future<bool?> _showDeleteConfirmDialog() {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('提示'),
            content: Text('您确定要删除这条评论吗?'),
            actions: <Widget>[
              WButton(
                child: Text('确定'),
                onPressed: () {
                  //关闭对话框并返回true
                  Navigator.of(context).pop(true);
                },
              ),
              WButton(
                child: Text('取消'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _initialRating = widget.ratings.toDouble();
    _rating = _initialRating;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> column = [];
    var OfficialLogo = widget.comment.sender == 1
        ? Row(
            children: [
              Image.asset(
                widget.tag == '天外天'
                    ? 'assets/images/twt.png'
                    : 'assets/images/school.png',
                height: widget.tag == '天外天' ? 18 : 24,
                width: 30,
                fit: BoxFit.contain,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(widget.tag,
                            style: TextUtil.base.NotoSansSC
                                .label(context)
                                .normal
                                .w500
                                .sp(14)),
                        CommentIdentificationContainer('官方', true),
                      ]),
                  Text(
                    DateTime.now()
                                .difference(widget.comment.createAt!)
                                .inHours >=
                            11
                        ? widget.comment.createAt!
                            .toLocal()
                            .toIso8601String()
                            .replaceRange(10, 11, ' ')
                            .substring(0, 19)
                        : DateTime.now()
                            .difference(widget.comment.createAt!)
                            .dayHourMinuteSecondFormatted(),
                    style: TextUtil.base.ProductSans
                        .secondaryInfo(context)
                        .regular
                        .sp(10),
                  ),
                ],
              )
            ],
          )
        : Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: SvgPicture.network(
                  '${EnvConfig.QNHD}avatar/beam/20/${widget.comment.nickname}',
                  width: 30,
                  height: 24,
                  fit: BoxFit.fitHeight,
                  placeholderBuilder: (_) => Loading(),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('帖主',
                            style: TextUtil.base.NotoSansSC
                                .label(context)
                                .normal
                                .w500
                                .sp(14)),
                      ]),
                  Text(
                    DateTime.now()
                                .difference(widget.comment.createAt!)
                                .inHours >=
                            11
                        ? widget.comment.createAt!
                            .toLocal()
                            .toIso8601String()
                            .replaceRange(10, 11, ' ')
                            .substring(0, 19)
                        : DateTime.now()
                            .difference(widget.comment.createAt!)
                            .dayHourMinuteSecondFormatted(),
                    style: TextUtil.base.ProductSans
                        .secondaryInfo(context)
                        .regular
                        .sp(10),
                  ),
                ],
              )
            ],
          );

    ///举报/删除区
    var popMenu = PopupMenuButton(
      padding: EdgeInsets.zero,
      shape: RacTangle(),
      offset: Offset(0, 0),
      child: SvgPicture.asset(
        'assets/svg_pics/lake_butt_icons/more_horizontal.svg',
        width: 16,
      ),
      onSelected: (value) async {
        if (value == '举报') {
          Navigator.pushNamed(context, FeedbackRouter.report,
              arguments: ReportPageArgs(widget.ancestorId, false,
                  floorId: widget.comment.id));
        } else if (value == '删除') {
          bool? confirm = await _showDeleteConfirmDialog();
          if (confirm ?? false) {
            FeedbackService.deleteFloor(
              id: widget.comment.id,
              onSuccess: () {
                ToastProvider.success(S.current.feedback_delete_success);
                setState(() {});
              },
              onFailure: (e) {
                ToastProvider.error(e.error.toString());
              },
            );
          }
        }
      },
      itemBuilder: (context) {
        return <PopupMenuEntry<String>>[
          CommonPreferences.lakeUid.value.toString() == widget.comment.postId
              ? PopupMenuItem<String>(
                  value: '删除',
                  child: Center(
                    child: Text(
                      '删除',
                      style: TextUtil.base
                          .label(context)
                          .regular
                          .NotoSansSC
                          .sp(12),
                    ),
                  ),
                )
              : PopupMenuItem<String>(
                  value: '举报',
                  child: Center(
                    child: Text(
                      '举报',
                      style: TextUtil.base
                          .label(context)
                          .regular
                          .NotoSansSC
                          .sp(12),
                    ),
                  ),
                ),
        ];
      },
    );

    ///致敬lxx的box封装
    var box = SizedBox(height: 6);

    ///头像区
    var createTime = Row(
      children: [
        OfficialLogo,
        Spacer(),
        if (widget.comment.sender == 0) popMenu
      ],
    );

    ///评分系统，只有楼主可评分
    Widget starWidget;
    if (CommonPreferences.lakeUid.value.toString() ==
        widget.ancestorId.toString()) {
      starWidget = WButton(
        onPressed: () async {
          ratingCard();
        },
        child: Row(children: [
          Text(
            S.current.feedback_rating,
            style: TextUtil.base.NotoSansSC.label(context).normal.w500.sp(14),
          ),
          RatingBar.builder(
            itemBuilder: (context, index) => Icon(
              Icons.star,
              color: WpyTheme.of(context).get(WpyColorKey.FavorColor),
            ),
            allowHalfRating: true,
            glow: false,
            initialRating: _rating,
            itemCount: 5,
            itemSize: 16.w,
            ignoreGestures: true,
            unratedColor:
                WpyTheme.of(context).get(WpyColorKey.secondaryTextColor),
            onRatingUpdate: (_) {},
          ),
        ]),
      );
    } else {
      starWidget = Row(children: [
        Text(
          S.current.feedback_rating,
          style: TextUtil.base.NotoSansSC.label(context).normal.w500.sp(14),
        ),
        RatingBar.builder(
          itemBuilder: (context, index) => Icon(
            Icons.star,
            color: WpyTheme.of(context).get(WpyColorKey.FavorColor),
          ),
          allowHalfRating: true,
          glow: false,
          initialRating: _initialRating,
          itemCount: 5,
          itemSize: 16.w,
          ignoreGestures: true,
          unratedColor:
              WpyTheme.of(context).get(WpyColorKey.secondaryTextColor),
          onRatingUpdate: (_) {},
        ),
      ]);
    }

    ///楼中楼笨方法，建议先去看lyx版本
    var bottomWidget = Row(
      children: [if (widget.comment.sender == 1) starWidget, Spacer()],
    );
    var detailWidget = Padding(
        padding: EdgeInsets.only(left: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WButton(
              onPressed: () {
                widget.onContentPressed?.call((comment) {
                  setState(() {
                    Navigator.pushNamed(
                      context,
                      FeedbackRouter.officialCommentDetail,
                      arguments: comment,
                    );
                  });
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Chip(
                  padding: const EdgeInsets.all(0),
                  labelPadding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  backgroundColor: WpyTheme.of(context).get(WpyColorKey.tagLabelColor),
                  label: Text('查看回复详情 >',
                      style: TextUtil.base.ProductSans.w400.sp(14).infoText(context)),
                ),
              ),
            )
          ],
        ));
    switch (widget.type) {
      case Official.reply:
        var comment = ExpandableText(
          text: widget.comment.content,
          maxLines: 5,
          style: TextUtil.base.w400.normal.label(context).NotoSansSC.sp(16),
          expand: false,
          buttonIsShown: true,
          isHTML: true,
        );

        column.addAll([
          box,
          createTime,
          box,
          comment,
          box,
          bottomWidget,
          box,
        ]);

        break;
      case Official.subFloor:
        var comment = RichText(
          overflow: TextOverflow.ellipsis,
          maxLines: 4,
          text: HTML.toTextSpan(
            context,
            widget.comment.content,
            defaultTextStyle:
                TextUtil.base.w400.normal.label(context).NotoSansSC.sp(16),
          ),
        );

        column.addAll([
          box,
          createTime,
          box,
          comment,
          box,
          bottomWidget,
          box,
        ]);

        break;
    }

    Widget list = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: column),
    );
    Widget card = CommentCardGestureDetector(
      isOfficial: true,
      id: widget.comment.id,
      copy: widget.comment.content,
      toast: '复制评论成功',
      child: Container(
        padding: EdgeInsets.fromLTRB(2, 8, 2, 8),
        margin: widget.detail == true
            ? EdgeInsets.fromLTRB(40, 3, 20, 3)
            : EdgeInsets.symmetric(vertical: 6, horizontal: 20),
        child: list,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          boxShadow: [
            BoxShadow(
                blurRadius: 5,
                color: WpyTheme.of(context).get(WpyColorKey.backgroundMaskColor),
                offset: Offset(0, 0),
                spreadRadius: 3),
          ],
        ),
      ),
    );
    return WButton(
      onPressed: () {
        widget.onContentPressed?.call((comment) {
          setState(() {
            Navigator.pushNamed(
              context,
              FeedbackRouter.officialCommentDetail,
              arguments: comment,
            );
          });
        });
      },
      child: widget.detail == true
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [card, detailWidget],
            )
          : card,
    );
  }

  ratingCard() {
    final checkedNotifier = ValueNotifier(_rating);
    final List<String> comments = [
      '请对官方回复态度进行评分',
      '很差',
      '较差',
      '一般',
      '较好',
      '非常满意'
    ];
    Widget ratingBars = RatingBar.builder(
      initialRating: _initialRating,
      minRating: 0,
      allowHalfRating: true,
      unratedColor: WpyTheme.of(context).get(WpyColorKey.oldListActionColor),
      itemCount: 5,
      itemSize: 47.w,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: WpyTheme.of(context).get(WpyColorKey.FavorBubbleStartColor),
      ),
      onRatingUpdate: (rating) {
        setState(() {
          _rating = rating;
          checkedNotifier.value = rating;
        });
      },
      updateOnDrag: true,
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return LakeDialogWidget(
              title: "",
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ValueListenableBuilder<double>(
                      valueListenable: checkedNotifier,
                      builder: (context, type, _) {
                        return Text(
                            '「' +
                                (checkedNotifier.value < 1
                                    ? comments[0]
                                    : comments[checkedNotifier.value.toInt()]) +
                                '」',
                            style: TextUtil.base.normal
                                .primary(context)
                                .NotoSansSC
                                .sp(16)
                                .w400);
                      }),
                  ratingBars,
                ],
              ),
              cancelText: "取消",
              confirmTextStyle:
                  TextUtil.base.normal.label(context).NotoSansSC.sp(14).w400,
              cancelTextStyle:
                  TextUtil.base.normal.label(context).NotoSansSC.sp(14).w400,
              confirmText: "提交",
              cancelFun: () {
                Navigator.pop(context);
              },
              confirmFun: () {
                FeedbackService.rate(
                    id: widget.comment.postId.toString(),
                    rating: _rating.toInt().toString(),
                    onSuccess: () {
                      ToastProvider.success("评分成功！");
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                    onFailure: (e) {
                      ToastProvider.error("204 no content");
                      Navigator.pop(context);
                    });
              });
        });
  }
}
