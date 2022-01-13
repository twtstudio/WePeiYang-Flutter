import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:like_button/like_button.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

typedef NotifierCallback = Future<void> Function(
    bool, int, Function onSuccess, Function onFailure);

class LikeWidget extends StatefulWidget {
  final int count;
  final bool isLike;
  final NotifierCallback onLikePressed;

  final ValueNotifier<int> countNotifier;
  final ValueNotifier<bool> isLikedNotifier;

  LikeWidget({this.count, this.isLike, this.onLikePressed})
      : countNotifier = ValueNotifier(count),
        isLikedNotifier = ValueNotifier(isLike);

  @override
  _LikeWidgetState createState() => _LikeWidgetState();
}

class _LikeWidgetState extends State<LikeWidget> {
  @override
  Widget build(BuildContext context) {
    var likeButton = ConstrainedBox(

      constraints: BoxConstraints(
        minWidth:ScreenUtil().setSp(11.67),
        minHeight:ScreenUtil().setSp(11.67),
      ),
      child: ValueListenableBuilder(
        valueListenable: widget.isLikedNotifier,
        builder: (_, value, __) {
          return LikeButton(
            size: 15,
           likeCountPadding: EdgeInsets.only(bottom:  ScreenUtil().setSp(5),right: ScreenUtil().setSp(5.17) ),
            likeBuilder: (bool isLiked) {
              if (isLiked) {
                return Icon(
                  Icons.thumb_up,
                  size: 15,
                  color: Colors.redAccent,
                );
              } else {
                return Icon(
                  Icons.thumb_up_outlined,
                  size: 15,
                  color: ColorUtil.boldTextColor,
                );
              }
            },
            onTap: (value) async {
              if (value) {
                widget.countNotifier.value = widget.countNotifier.value - 1;
              } else {
                widget.countNotifier.value = widget.countNotifier.value + 1;
              }
              widget.onLikePressed(value, widget.countNotifier.value, () {
                widget.isLikedNotifier.value = !value;
              }, () {
                if (value) {
                  widget.countNotifier.value = widget.countNotifier.value + 1;
                } else {
                  widget.countNotifier.value = widget.countNotifier.value - 1;
                }
                setState(() {});
              });
              return !value;
            },
            isLiked: value,
            circleColor:
                CircleColor(start: Colors.black12, end: Colors.redAccent),
            bubblesColor: BubblesColor(
              dotPrimaryColor: Colors.redAccent,
              dotSecondaryColor: Colors.pinkAccent,
            ),
            animationDuration: Duration(milliseconds: 600),
            padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
          );
        },
      ),
    );

    var likeCount = ValueListenableBuilder(
        valueListenable: widget.countNotifier,
        builder: (_, value, __) {
          return Text(
            value.toString(),
            style: TextUtil.base.black2A.bold.ProductSans.sp(12),
          );
        });

    var likeWidget = Row(
      children: [likeButton, likeCount],
    );
    return likeWidget;
  }
}
class BottomLikeWidget extends StatefulWidget {
  final int count;
  final bool isLike;
  final NotifierCallback onLikePressed;

  final ValueNotifier<int> countNotifier;
  final ValueNotifier<bool> isLikedNotifier;

  BottomLikeWidget({this.count, this.isLike, this.onLikePressed})
      : countNotifier = ValueNotifier(count),
        isLikedNotifier = ValueNotifier(isLike);

  @override
  _BottomLikeWidgetState createState() => _BottomLikeWidgetState();
}

class _BottomLikeWidgetState extends State<BottomLikeWidget> {
  @override
  Widget build(BuildContext context) {
    var likeButton = ConstrainedBox(

      constraints: BoxConstraints(
        minWidth:ScreenUtil().setSp(11.67),
        minHeight:ScreenUtil().setSp(11.67),
      ),
      child: ValueListenableBuilder(
        valueListenable: widget.isLikedNotifier,
        builder: (_, value, __) {
          return LikeButton(
            size: 22,
            likeCountPadding: EdgeInsets.only(bottom:  ScreenUtil().setSp(5),right: ScreenUtil().setSp(5.17) ),
            likeBuilder: (bool isLiked) {
              if (isLiked) {
                return Icon(
                  Icons.thumb_up,
                  size: 22,
                  color: Colors.redAccent,
                );
              } else {
                return Icon(
                  Icons.thumb_up_outlined,
                  size: 22,
                  color: ColorUtil.boldTextColor,
                );
              }
            },
            onTap: (value) async {
              if (value) {
                widget.countNotifier.value = widget.countNotifier.value - 1;
              } else {
                widget.countNotifier.value = widget.countNotifier.value + 1;
              }
              widget.onLikePressed(value, widget.countNotifier.value, () {
                widget.isLikedNotifier.value = !value;
              }, () {
                if (value) {
                  widget.countNotifier.value = widget.countNotifier.value + 1;
                } else {
                  widget.countNotifier.value = widget.countNotifier.value - 1;
                }
                setState(() {});
              });
              return !value;
            },
            isLiked: value,
            circleColor:
            CircleColor(start: Colors.black12, end: Colors.redAccent),
            bubblesColor: BubblesColor(
              dotPrimaryColor: Colors.redAccent,
              dotSecondaryColor: Colors.pinkAccent,
            ),
            animationDuration: Duration(milliseconds: 600),
            padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
          );
        },
      ),
    );

    var likeCount = ValueListenableBuilder(
        valueListenable: widget.countNotifier,
        builder: (_, value, __) {
          return Text(
            value.toString(),
            style: TextUtil.base.black2A.bold.ProductSans.sp(12),
          );
        });

    var bottomlikeWidget = Row(
      children: [likeButton,SizedBox(width: 10,), likeCount],
    );
    return bottomlikeWidget;
  }
}
