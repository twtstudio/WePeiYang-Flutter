import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef WithCountNotifierCallback = Future<void> Function(
    bool, int, Function onSuccess, Function onFailure);

enum IconType { like, bottomLike, fav, bottomFav }

extension IconTypeExt on IconType {
  Image get iconFilled => [
        Image.asset('assets/images/lake_butt_icons/like_filled.png'),
        Image.asset('assets/images/lake_butt_icons/like_filled.png'),
        Image.asset('assets/images/lake_butt_icons/favorite_filled.png'),
        Image.asset('assets/images/lake_butt_icons/favorite_filled.png')
      ][index];

  Image get iconOutlined => [
        Image.asset('assets/images/lake_butt_icons/like_outlined.png'),
        Image.asset('assets/images/lake_butt_icons/like_outlined.png'),
        Image.asset('assets/images/lake_butt_icons/favorite_outlined.png'),
        Image.asset('assets/images/lake_butt_icons/favorite_outlined.png')
      ][index];

  double get size => [
    15.w,22.w,15.w,22.w
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

  double get textSize => [12.0, 14.0, 12.0, 14.0][index];
}

class IconWidget extends StatefulWidget {
  final int count;
  final bool isLike;
  final WithCountNotifierCallback onLikePressed;
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
        minWidth: 11.67.w,
        minHeight: 11.67.w,
      ),
      child: ValueListenableBuilder(
        valueListenable: widget.isLikedNotifier,
        builder: (_, value, __) {
          return LikeButton(
            size: widget.iconType.size,
            likeCountPadding: EdgeInsets.only(right: 5.17.w),
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
            circleColor: widget.iconType.circleColor,
            bubblesColor: widget.iconType.bubblesColor,
            animationDuration: Duration(milliseconds: 600),
          );
        },
      ),
    );

    var likeCount = ValueListenableBuilder(
        valueListenable: widget.countNotifier,
        builder: (_, value, __) {
          return Padding(
            padding: EdgeInsets.only(right: 5.17.w),
            child: SizedBox(
              width: 20.w,
              child: Text(
                value.toString(),
                style: TextUtil.base.black2A.bold.ProductSans
                    .sp(widget.iconType.textSize),
              ),
            ),
          );
        });

    var likeWidget = Row(
      children: [likeButton, likeCount],
    );
    return likeWidget;
  }
}


typedef DislikeNotifierCallback = void Function(bool);

class DislikeWidget extends StatelessWidget {
  final bool isLike;
  final bool isDislike;
  final int count;
  final DislikeNotifierCallback onDislikePressed;

  final ValueNotifier<bool> isLikedNotifier;
  final ValueNotifier<int> countNotifier;
  final ValueNotifier<bool> isDislikedNotifier;
  final double size;

  DislikeWidget({
    this.onDislikePressed,
    this.isDislike,
    this.isLike,
    this.count,
    this.size
  }) : isDislikedNotifier = ValueNotifier(isDislike),
        countNotifier = ValueNotifier(count),
        isLikedNotifier = ValueNotifier(isLike);

  @override
  Widget build(BuildContext context) {
    var dislikeButton = ValueListenableBuilder(
      valueListenable: isDislikedNotifier,
      builder: (_, value, __) {
        return LikeButton(
          size: size,
          likeBuilder: (bool isDisliked) {
            if (isDisliked) {
              return Image.asset('assets/images/lake_butt_icons/dislike_filled.png');
            } else {
              return Image.asset('assets/images/lake_butt_icons/dislike_outlined.png');
            }
          },
          onTap: (value) async {
            onDislikePressed?.call(isDislikedNotifier.value);
            return !value;
          },
          isLiked: value,
          circleColor: CircleColor(start: Colors.black12, end: Colors.blue[200]),
          bubblesColor: BubblesColor(
            dotPrimaryColor: Colors.blueGrey,
            dotSecondaryColor: Colors.black26,
          ),
          animationDuration: Duration(milliseconds: 600),
        );
      },
    );

    return dislikeButton;
  }
}
