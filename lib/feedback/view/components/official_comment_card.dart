import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/PopMenuShape.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/clip_copy.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';

import '../../feedback_router.dart';

import '../report_question_page.dart';


enum Official { detail, reply }

typedef LikeCallback = void Function(bool, int);
typedef ContentPressedCallback = void Function(void Function(List<Floor>));



class OfficialReplyCard extends StatefulWidget {
  final String tag;
  final Floor comment;
  final String title;
  final Official type;
  final int ancestorId;
  final ContentPressedCallback onContentPressed;
  final LikeCallback onLikePressed;
  final int placeAppeared;
  final String ImageUrl;
  int ratings;

  OfficialReplyCard.detail({
    this.tag,
    this.comment,
    this.title,
    this.ratings,
    this.ancestorId,
    this.ImageUrl,
    this.onLikePressed,
    this.placeAppeared,
  })  : type = Official.detail,
        onContentPressed = null;

  OfficialReplyCard.reply({
    this.tag,
    this.comment,
    this.ratings,
    this.title,
    this.ancestorId,
    this.ImageUrl,
    this.onContentPressed,
    this.onLikePressed,
    this.placeAppeared,
  }) : type = Official.reply;

  @override
  _OfficialReplyCardState createState() => _OfficialReplyCardState();
}

class _OfficialReplyCardState extends State<OfficialReplyCard> with SingleTickerProviderStateMixin{
  double _rating;
  double _initialRating = 0;
  String postRating;
  String postId;
  final String picBaseUrl = 'https://qnhdpic.twt.edu.cn/download/';
  bool _picFullView = false;
  static WidgetBuilder defaultPlaceholderBuilder =
      (BuildContext ctx) => Loading();
  @override
  void initState() {
    _initialRating = widget.ratings.toDouble();
    _rating = _initialRating;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> column = [];
    var commentImage = Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: AnimatedSize(
          vsync: this,
          duration: Duration(milliseconds: 150),
          curve: Curves.decelerate,
          child: InkWell(
              onTap: () {
                setState(() {
                  _picFullView = true;
                });
              },
              child: _picFullView
                  ? InkWell(
                onTap: () {
                  Navigator.pushNamed(context, FeedbackRouter.imageView,
                      arguments: {
                        "urlList": [widget.ImageUrl],
                        "urlListLength": 1,
                        "indexNow": 0
                      });
                },
                child: Image.network(
                  picBaseUrl + 'origin/' + widget.ImageUrl,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace stackTrace) {
                    return Text(
                      '💔[图片加载失败]' +
                          widget.ImageUrl.replaceRange(10,
                              widget.ImageUrl.length - 6, '...'),
                      style: TextUtil.base.grey6C.w400.sp(12),
                    );
                  },
                ),
              )
                  : Row(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      child: Image.network(
                          picBaseUrl + 'thumb/' + widget.ImageUrl,
                          width: 70,
                          height: 64,
                          fit: BoxFit.cover, loadingBuilder:
                          (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 40,
                          width: 40,
                          padding: EdgeInsets.all(4),
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes !=
                                null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes
                                : null,
                          ),
                        );
                      }, errorBuilder: (BuildContext context,
                          Object exception, StackTrace stackTrace) {
                        return Text(
                          '💔[加载失败，可尝试点击继续加载原图]\n    ' +
                              widget.ImageUrl.replaceRange(
                                  10,
                                  widget.ImageUrl.length - 6,
                                  '...'),
                          style: TextUtil.base.grey6C.w400.sp(12),
                        );
                      })),
                  Spacer()
                ],
              )),
        ));

    var OfficialLogo = widget.comment.sender==1?Row(
      children: [
        Image.asset(
          widget.tag == '天外天' ? 'assets/images/twt.png' : 'assets/images/school.png',
          height: widget.tag == '天外天' ? 18 : 24,
          width: 30,
          fit: BoxFit.contain,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text(widget.tag ?? '官方',
                  style: TextUtil.base.NotoSansSC.black2A.normal.w500.sp(14)),
              CommentIdentificationContainer('官方', true),
            ]),
            Text(
              DateTime.now().difference(widget.comment.createAt).inHours >= 11
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
    ): Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          child: SvgPicture.network(
            'https://qnhd.twt.edu.cn/avatar/beam/20/${widget.comment.postId}+${widget.comment.nickname}',
            width: 30,
            height: 24,
            fit: BoxFit.fitHeight,
            placeholderBuilder: defaultPlaceholderBuilder,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text(widget.tag ?? '用户'+CommonPreferences().feedbackUid.value.toString(),
                  style: TextUtil.base.NotoSansSC.black2A.normal.w500.sp(14)),
            ]),
            Text(
              DateTime.now().difference(widget.comment.createAt).inHours >= 11
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
    var box = SizedBox(height: 6);
    var createTime = Row(
      children: [
        OfficialLogo,
        Spacer(),
        if(widget.comment.sender==0)
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
              if (value == '举报') {
                Navigator.pushNamed(context, FeedbackRouter.report,
                    arguments: ReportPageArgs(widget.ancestorId, false,
                        floorId: widget.comment.id));
              } else if (value == '删除') {
                bool confirm = await _showDeleteConfirmDialog();
                if (confirm) {
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
                PopupMenuItem<String>(
                  value: '分享',
                  child: Center(
                    child: Text(
                      '分享',
                      style: TextUtil.base.black2A.regular.NotoSansSC.sp(12),
                    ),
                  ),
                ),
                CommonPreferences().feedbackUid.value.toString() == widget.comment.postId
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
    if (CommonPreferences().feedbackUid.value.toString() == widget.ancestorId.toString()) {
      starWidget = GestureDetector(
        onTap: ()async{
          ratingCard();
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
            initialRating: _rating,
            itemCount: 5,
            itemSize: 16.w,
            ignoreGestures: true,
            unratedColor: ColorUtil.lightTextColor,
            onRatingUpdate: (_) {},
          ),
        ]),
      );
    } else {
      starWidget = Row(children: [
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
          initialRating: _initialRating,
          itemCount: 5,
          itemSize: 16.w,
          ignoreGestures: true,
          unratedColor: ColorUtil.lightTextColor,
          onRatingUpdate: (_) {},
        ),
      ]);
    }

    var bottomWidget = Row(
      children: [if(widget.comment.sender==1)starWidget, Spacer()],
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
          comment,
          box,
          if (widget.comment.imageUrl != '') commentImage,
          _picFullView == true
              ? TextButton(
              style: ButtonStyle(
                  alignment: Alignment.topRight,
                  padding: MaterialStateProperty.all(EdgeInsets.zero)),
              onPressed: () {
                setState(() {
                  _picFullView = false;
                });
              },
              child: Row(
                children: [
                  Spacer(),
                  Text('收起',
                      style: TextUtil.base.greyA8.w800.NotoSansSC.sp(12)),
                ],
              ))
              : SizedBox(height: 8),
          bottomWidget,
          box
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

    return InkWell(
      onTap: () {
        widget.onContentPressed?.call((comment) {
          setState(() {
            Navigator.pushNamed(
              context,
              FeedbackRouter.offcialCommentDetail,
              arguments: comment,
            );
          });
        });
      },
      child: ClipCopy(
        copy: widget.comment.content,
        toast: '复制评论成功',
        child: Container(
          padding: EdgeInsets.fromLTRB(2, 8, 2, 8),
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
          child: list,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  blurRadius: 5,
                  color: Color.fromARGB(64, 236, 237, 239),
                  offset: Offset(0, 0),
                  spreadRadius: 3),
            ],
          ),
        ),
      ),
    );
  }

  ratingCard()  {
    final checkedNotifier = ValueNotifier(_rating);
    final List<String> comments= ['请对官方回复态度进行评分','很差','较差','一般','较好','非常满意'];
    Widget ratingBars =  RatingBar.builder(
      initialRating: _initialRating,
      minRating: 0,
      allowHalfRating: true,
      unratedColor: Colors.grey,
      itemCount: 5,
      itemSize: 47.w,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        setState(() {
          _rating = rating;
          checkedNotifier.value =rating;
        });
      },
      updateOnDrag: true,
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogWidget(
              title: "",
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ValueListenableBuilder<double>(
                      valueListenable: checkedNotifier,
                      builder: (context, type, _) {
                      return Text('「'+(checkedNotifier.value<1?comments[0]:comments[checkedNotifier.value.toInt()])+'」',
                          style:
                              TextUtil.base.normal.black00.NotoSansSC.sp(16).w400);
                    }
                  ),
                  ratingBars,
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
                postRating = _rating.toInt().toString();
                postId = widget.comment.postId.toString();
               FeedbackService.rate(
                   id:postId,
                   rating: postRating,
                   onSuccess: (){
                     ToastProvider.success("评分成功！");
                     setState(() {
                       Navigator.pop(context);
                     });
                   },
                   onFailure:(e) {
                     ToastProvider.error("204 no content");
                     Navigator.pop(context);
                   });
              });
        });
  }
  Future<bool> _showDeleteConfirmDialog() {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('提示'),
            content: Text('您确定要删除这条评论吗?'),
            actions: <Widget>[
              TextButton(
                child: Text('确定'),
                onPressed: () {
                  //关闭对话框并返回true
                  Navigator.of(context).pop(true);
                },
              ),
              TextButton(
                child: Text('取消'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }

}

