import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

typedef NotifierCallback = void Function(ValueNotifier<bool>);

class LikeWidget extends StatelessWidget {
  final int count;
  final bool isLiked;
  final NotifierCallback onLikePressed;

  final ValueNotifier<int> countNotifier;
  final ValueNotifier<bool> isLikedNotifier;

  LikeWidget({this.count, this.isLiked, this.onLikePressed})
      : countNotifier = ValueNotifier(count),
        isLikedNotifier = ValueNotifier(isLiked);

  @override
  Widget build(BuildContext context) {
    var likeButton = SizedBox(
      height: 40,
      child: ValueListenableBuilder(
        valueListenable: isLikedNotifier,
        builder: (_, value, __) {
          return LikeButton(
            likeBuilder: (bool isLiked) {
              if (isLiked) {
                return Icon(
                  Icons.thumb_up,
                  size: 16,
                  color: Colors.redAccent,
                );
              } else {
                return Icon(
                  Icons.thumb_up_outlined,
                  size: 16,
                  color: ColorUtil.lightTextColor,
                );
              }
            },
            onTap: (value) async {
              onLikePressed(isLikedNotifier);
              if (value) {
                countNotifier.value = countNotifier.value - 1;
              } else {
                countNotifier.value = countNotifier.value + 1;
              }
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
        valueListenable: countNotifier,
        builder: (_, value, __) {
          return Text(
            value.toString(),
            style: FontManager.YaHeiRegular.copyWith(
                fontSize: 14, color: ColorUtil.lightTextColor),
          );
        });

    var likeWidget = Row(
      children: [likeButton, likeCount],
    );
    return likeWidget;
  }
}
