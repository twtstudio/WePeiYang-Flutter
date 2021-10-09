import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

typedef NotifierCallback = Future<void> Function(
    bool, int, Function onSuccess, Function onFailure);

class LikeWidget extends StatefulWidget {
  final int count;
  final bool isLiked;
  final NotifierCallback onLikePressed;

  final ValueNotifier<int> countNotifier;
  final ValueNotifier<bool> isLikedNotifier;

  LikeWidget({this.count, this.isLiked, this.onLikePressed})
      : countNotifier = ValueNotifier(count),
        isLikedNotifier = ValueNotifier(isLiked);

  @override
  _LikeWidgetState createState() => _LikeWidgetState();
}

class _LikeWidgetState extends State<LikeWidget> {
  @override
  Widget build(BuildContext context) {
    var likeButton = SizedBox(
      height: 40,
      child: ValueListenableBuilder(
        valueListenable: widget.isLikedNotifier,
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
