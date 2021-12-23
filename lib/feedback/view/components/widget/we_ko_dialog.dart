import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

class WeKoDialog extends StatelessWidget {
  final Post post;
  final void Function() onConfirm;
  final void Function() onCancel;

  WeKoDialog(
      {Key key,
      @required this.post,
      @required this.onConfirm,
      @required this.onCancel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromRGBO(237, 240, 244, 1)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Text('有人给你分享了微口令',
                  style: FontManager.YaHeiRegular.copyWith(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none)),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                child: Text(post.title,
                    style: FontManager.YaHeiRegular.copyWith(
                        color: Color.fromRGBO(79, 88, 107, 1),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none)),
              ),
              if(post.topImgUrl != null) Image.network(
                post.topImgUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(post.content,
                    style: FontManager.YaHeiRegular.copyWith(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: onConfirm,
                child: Container(
                  margin: const EdgeInsets.all(10),
                    child: Text(
                      '查看详情',
                      style: FontManager.YaQiHei.copyWith(
                        color: ColorUtil.boldTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
