import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

typedef NotifierCallback = void Function(ValueNotifier<bool>);

class CollectWidget extends StatelessWidget {
  final bool isCollect;
  final NotifierCallback onCollectPressed;
  final ValueNotifier<bool> isLiked;

  CollectWidget({
    this.onCollectPressed,
    this.isCollect,
  }) : isLiked = ValueNotifier(isCollect);

  @override
  Widget build(BuildContext context) {
    var collectButton = ValueListenableBuilder(
      valueListenable: isLiked,
      builder: (_, value, __) {
        return LikeButton(
          likeBuilder: (bool isCollect) {
            if (isCollect) {
              return Icon(
                Icons.star,
                size: 19,
                color: Colors.amberAccent,
              );
            } else {
              return Icon(
                Icons.star_border_outlined,
                size: 19,
                color: ColorUtil.lightTextColor,
              );
            }
          },
          onTap: (value) async {
            onCollectPressed?.call(isLiked);
            return !value;
          },
          isLiked: value,
          circleColor: CircleColor(start: Colors.black12, end: Colors.yellow),
          bubblesColor: BubblesColor(
            dotPrimaryColor: Colors.amber,
            dotSecondaryColor: Colors.amberAccent,
          ),
          animationDuration: Duration(milliseconds: 600),
          padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
        );
      },
    );

    return collectButton;
  }
}
class BottomCollectWidget extends StatelessWidget {
  final bool isCollect;
  final NotifierCallback onCollectPressed;
  final ValueNotifier<bool> isLiked;

  BottomCollectWidget({
    this.onCollectPressed,
    this.isCollect,
  }) : isLiked = ValueNotifier(isCollect);

  @override
  Widget build(BuildContext context) {
    var collectButton = ValueListenableBuilder(
      valueListenable: isLiked,
      builder: (_, value, __) {
        return LikeButton(
          likeBuilder: (bool isCollect) {
            if (isCollect) {
              return Icon(
                Icons.star,
                size: 22,
                color: Colors.amberAccent,
              );
            } else {
              return Icon(
                Icons.star_border_outlined,
                size: 22,
                color: ColorUtil.lightTextColor,
              );
            }
          },
          onTap: (value) async {
            onCollectPressed?.call(isLiked);
            return !value;
          },
          isLiked: value,
          circleColor: CircleColor(start: Colors.black12, end: Colors.yellow),
          bubblesColor: BubblesColor(
            dotPrimaryColor: Colors.amber,
            dotSecondaryColor: Colors.amberAccent,
          ),
          animationDuration: Duration(milliseconds: 600),
          padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
        );
      },
    );

    return collectButton;
  }
}