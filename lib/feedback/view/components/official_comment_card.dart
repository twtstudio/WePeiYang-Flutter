import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/clip_copy.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import '../new_post_page.dart';

enum Official { detail, reply }

typedef LikeCallback = void Function(bool, int);
typedef ContentPressedCallback = void Function(void Function(Floor));

List<String> rate = ["较差", "一般", "非常漂亮"];

class OfficialReplyCard extends StatefulWidget {
  final Floor comment;
  final String title;
  final Official type;
  final int ancestorId;
  final ContentPressedCallback onContentPressed;
  final LikeCallback onLikePressed;
  final int placeAppeared;
  int ratings;

  OfficialReplyCard.detail({
    this.comment,
    this.title,
    this.ancestorId,
    this.onLikePressed,
    this.placeAppeared,
  })  : type = Official.detail,
        onContentPressed = null;

  OfficialReplyCard.reply({
    this.comment,
    this.title,
    this.ancestorId,
    this.onContentPressed,
    this.onLikePressed,
    this.placeAppeared,
  }) : type = Official.reply;

  @override
  _OfficialReplyCardState createState() => _OfficialReplyCardState();
}

class _OfficialReplyCardState extends State<OfficialReplyCard> {
  @override
  Widget build(BuildContext context) {
    List<Widget> column = [];
    var OfficalLogo = Row(
      children: [
        Image.asset(
          'assets/images/school.png',
          scale: 2.5.w,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text("官方",
                  style: TextUtil.base.NotoSansSC.black2A.normal.w500.sp(14)),
              CommentIdentificationContainer('官方', true),
            ]),
            Text(
              DateTime.now().difference(widget.comment.createAt).inDays >= 1
                  ? widget.comment.createAt
                      .toLocal()
                      .toIso8601String()
                      .replaceRange(10, 11, ' ')
                      .substring(0, 19)
                  : DateTime.now()
                      .difference(widget.comment.createAt)
                      .dayHourMinuteSecondFormatted(),
              style: TextUtil.base.ProductSans.grey97.regular.sp(10),
            ),
          ],
        )
      ],
    );
    var box = SizedBox(height: 8);
    var createTime = Row(
      children: [
        OfficalLogo,
        Spacer(),
        PopupMenuButton(
          padding: EdgeInsets.zero,
          shape: RacTangle(),
          offset: Offset(0, 0),
          child: SvgPicture.asset(
            'assets/svg_pics/lake_butt_icons/more_horizontal.svg',
            width: 16,
          ),
          onSelected: (value) async {
            if (value == '分享') {
              String weCo =
                  '我在微北洋发现了个有趣的问题，你也来看看吧~\n将本条微口令复制到微北洋校务专区打开问题 wpy://school_project/${widget.ancestorId}\n【${widget.comment.nickname}】';
              ClipboardData data = ClipboardData(text: weCo);
              Clipboard.setData(data);
              CommonPreferences().feedbackLastWeCo.value =
                  widget.ancestorId.toString();
              ToastProvider.success('微口令复制成功，快去给小伙伴分享吧！');
            }
          },
          itemBuilder: (context) {
            return <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: '分享',
                child: Center(
                  child: Text(
                    '分享',
                    style: TextUtil.base.black2A.regular.NotoSansSC.sp(12),
                  ),
                ),
              ),
              widget.comment.isOwner
                  ? PopupMenuItem<String>(
                      value: '删除',
                      child: Center(
                        child: Text(
                          '删除',
                          style:
                              TextUtil.base.black2A.regular.NotoSansSC.sp(12),
                        ),
                      ),
                    )
                  : PopupMenuItem<String>(
                      value: '举报',
                      child: Center(
                        child: Text(
                          '举报',
                          style:
                              TextUtil.base.black2A.regular.NotoSansSC.sp(12),
                        ),
                      ),
                    ),
            ];
          },
        ),
      ],
    );

    Widget starWidget;
    if (widget.comment.rating == -1) {
      starWidget = Text(
        S.current.feedback_no_rating,
        style: FontManager.YaHeiRegular.copyWith(
          fontSize: 12,
          color: ColorUtil.lightTextColor,
        ),
      );
    } else {
      starWidget = GestureDetector(
        onTap: () {
          if (widget.comment.isOwner) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return DialogWidget(
                      title: "",
                      content: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(rate[widget.ratings],
                              style: TextUtil.base.normal.black2A.NotoSansSC
                                  .sp(14)
                                  .w400),
                          RatingBar.builder(
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: Colors.yellow,
                            ),
                            allowHalfRating: true,
                            glow: false,
                            initialRating: widget.ratings.toDouble(),
                            itemCount: 5,
                            itemSize: 40.w,
                            ignoreGestures: true,
                            unratedColor: ColorUtil.lightTextColor,
                            onRatingUpdate: (rating) {
                              setState(() {
                                if(rating==-1);
                                if(0<=rating&&rating<=4)
                                widget.ratings = 0;
                                if(4<=rating&&rating<6)
                                  widget.ratings = 1;
                                if(6<=rating&&rating<10||rating ==10)
                                  widget.ratings = 2;
                                FeedbackService.rate(
                                  id: widget.comment.id,
                                  rating: rating,
                                  onSuccess: () {
                                    ToastProvider.success(S.current.feedback_post_success);
                                    Navigator.pop(context);
                                  },
                                  onFailure: (e) {
                                    ToastProvider.error(e.error.toString());
                                  },
                                );
                              });
                            },
                          ),
                        ],
                      ),
                      cancelText: "取消",
                      confirmTextStyle:
                          TextUtil.base.normal.black2A.NotoSansSC.sp(14).w400,
                      cancelTextStyle:
                          TextUtil.base.normal.black2A.NotoSansSC.sp(14).w400,
                      confirmText: "提交",
                      cancelFun: () {
                        Navigator.pop(context);
                      },
                      confirmFun: () {
                        Navigator.pop(context);
                      });
                });
          }
        },
        child: Row(children: [
          Text(
            S.current.feedback_rating,
            style: TextUtil.base.NotoSansSC.black2A.normal.w500.sp(14),
          ),
          RatingBar.builder(
            itemBuilder: (context, index) => Icon(
              Icons.star,
              color: Colors.yellow,
            ),
            allowHalfRating: true,
            glow: false,
            initialRating: -1,
            itemCount: 5,
            itemSize: 16.w,
            ignoreGestures: true,
            unratedColor: ColorUtil.lightTextColor,
            onRatingUpdate: (_) {},
          ),
        ]),
      );
    }

    var bottomWidget = Row(
      children: [starWidget, Spacer()],
    );

    switch (widget.type) {
      case Official.detail:
        var title = Text(
          widget.title,
          style: FontManager.YaHeiRegular.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: ColorUtil.boldTextColor,
          ),
        );
        var divider = Divider(
          height: 0.6,
          color: Color(0xffacaeba),
        );

        column.addAll([
          box,
          title,
          box,
          divider,
          box,
          createTime,
          box,
          box,
          bottomWidget
        ]);

        break;
      case Official.reply:
        var comment = RichText(
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
          text: HTML.toTextSpan(
            context,
            widget.comment.content,
            defaultTextStyle:
                TextUtil.base.w400.normal.black2A.NotoSansSC.sp(16),
          ),
        );

        column.addAll([
          box,
          createTime,
          box,
          box,
          comment,
          bottomWidget,
        ]);

        break;
    }

    Widget list = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: column,
    );

    list = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: list,
    );

    var decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
            blurRadius: 5,
            color: Color.fromARGB(64, 236, 237, 239),
            offset: Offset(0, 0),
            spreadRadius: 3),
      ],
    );
    return DefaultTextStyle(
      style: FontManager.YaHeiRegular,
      child: InkWell(
        onTap: () {
          widget.onContentPressed?.call((comment) {
            setState(() {
              widget.comment.isLike = comment.isLike;
              widget.comment.likeCount = comment.likeCount;
              widget.comment.rating = comment.rating;
            });
          });
        },
        child: ClipCopy(
          copy: widget.comment.content,
          toast: '复制评论成功',
          child: Container(
            padding: EdgeInsets.fromLTRB(2, 8, 2, 8),
            margin: EdgeInsets.symmetric(vertical: 9, horizontal: 20),
            child: list,
            decoration: decoration,
          ),
        ),
      ),
    );
  }
}
