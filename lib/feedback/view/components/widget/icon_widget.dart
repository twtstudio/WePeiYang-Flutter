import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:like_button/like_button.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

typedef NotifierCallback = Future<void> Function(
    bool, int, Function onSuccess, Function onFailure);

enum IconType { like, bottomLike, fav, bottomFav }

extension IconTypeExt on IconType {

  Icon get iconFilled => [
        Icon(
          Icons.thumb_up,
          size: 15,
          color: Colors.redAccent,
        ),
        Icon(
          Icons.thumb_up,
          size: 16,
          color: Colors.redAccent,
        ),
        Icon(
          Icons.star,
          size: 15,
          color: Colors.amberAccent,
        ),
        Icon(
          Icons.star,
          size: 16,
          color: Colors.amberAccent,
        )
      ][index];

  Icon get iconOutlined => [
        Icon(
          Icons.thumb_up_outlined,
          size: 15,
          color: ColorUtil.boldTextColor,
        ),
        Icon(
          Icons.thumb_up_outlined,
          size: 16,
          color: ColorUtil.boldTextColor,
        ),
        Icon(
          Icons.star_border_outlined,
          size: 15,
          color: ColorUtil.lightTextColor,
        ),
        Icon(
          Icons.star_border_outlined,
          size: 16,
          color: ColorUtil.lightTextColor,
        )
      ][index];

  CircleColor get circleColor => [
    CircleColor(start: Colors.black12, end: Colors.redAccent),
    CircleColor(start: Colors.black12, end: Colors.redAccent),
    CircleColor(start: Colors.black12, end: Colors.yellow),
    CircleColor(start: Colors.black12, end: Colors.yellow),
      ][index];

  BubblesColor get bubblesColor => [
    BubblesColor(
      dotPrimaryColor: Colors.redAccent,
      dotSecondaryColor: Colors.pinkAccent,
    ),
    BubblesColor(
      dotPrimaryColor: Colors.redAccent,
      dotSecondaryColor: Colors.pinkAccent,
    ),
    BubblesColor(
      dotPrimaryColor: Colors.amber,
      dotSecondaryColor: Colors.amberAccent,
    ),
    BubblesColor(
      dotPrimaryColor: Colors.amber,
      dotSecondaryColor: Colors.amberAccent,
    ),
  ][index];

  double get textSize => [12.0, 12.0, 12.0, 12.0][index];

}

class IconWidget extends StatefulWidget {
  final int count;
  final bool isLike;
  final NotifierCallback onLikePressed;
  final IconType iconType;

  final ValueNotifier<int> countNotifier;
  final ValueNotifier<bool> isLikedNotifier;

  IconWidget(this.iconType, {this.count, this.isLike, this.onLikePressed})
      : countNotifier = ValueNotifier(count),
        isLikedNotifier = ValueNotifier(isLike);

  @override
  _IconWidgetState createState() => _IconWidgetState();
}

class _IconWidgetState extends State<IconWidget> {
  @override
  Widget build(BuildContext context) {
    var likeButton = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: ScreenUtil().setSp(11.67),
        minHeight: ScreenUtil().setSp(11.67),
      ),
      child: ValueListenableBuilder(
        valueListenable: widget.isLikedNotifier,
        builder: (_, value, __) {
          return LikeButton(
            size: 15,
            likeCountPadding: EdgeInsets.only(
                bottom: ScreenUtil().setSp(5), right: ScreenUtil().setSp(5.17)),
            likeBuilder: (bool isLiked) {
              if (isLiked) {
                return widget.iconType.iconFilled;
              } else {
                return widget.iconType.iconOutlined;
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
                widget.iconType.circleColor,
            bubblesColor: widget.iconType.bubblesColor,
            animationDuration: Duration(milliseconds: 600),
            padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
          );
        },
      ),
    );

    var likeCount = ValueListenableBuilder(
        valueListenable: widget.countNotifier,
        builder: (_, value, __) {
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              value.toString(),
              style: TextUtil.base.black2A.bold.ProductSans.sp(widget.iconType.textSize),
            ),
          );
        });

    var likeWidget = Row(
      children: [likeButton, likeCount],
    );
    return likeWidget;
  }
}