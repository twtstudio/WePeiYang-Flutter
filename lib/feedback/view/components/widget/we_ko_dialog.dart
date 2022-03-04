import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';

class WeKoDialog extends StatelessWidget {
  final Post post;
  final void Function() onConfirm;
  final void Function() onCancel;
  final String baseUrl = 'https://qnhd.twt.edu.cn/';
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
              Text('有人给你分享了微口令!',
                  style: TextUtil.base.black2A.regular.sp(14).NotoSansSC),
              Padding(
                padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                child: Text(post.title,
                    style: TextUtil.base.black2A.bold.sp(17).NotoSansSC),
              ),
              if(post.imageUrls.isNotEmpty) Image.network(
                baseUrl + post.imageUrls[0],
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(post.content,
                    style: TextUtil.base.grey6C.regular.sp(12).NotoSansSC,
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
                      style: TextUtil.base.black2A.regular.sp(14).NotoSansSC,
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
