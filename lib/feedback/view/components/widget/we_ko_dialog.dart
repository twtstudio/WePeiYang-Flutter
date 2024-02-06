import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';

import '../../../../commons/themes/template/wpy_theme_data.dart';
import '../../../../commons/themes/wpy_theme.dart';

class WeKoDialog extends StatelessWidget {
  final Post post;
  final void Function() onConfirm;
  final void Function() onCancel;
  final String baseUrl = '${EnvConfig.QNHDPIC}download/thumb/';

  WeKoDialog(
      {Key? key,
      required this.post,
      required this.onConfirm,
      required this.onCancel})
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
              color: WpyTheme.of(context).get(WpyThemeKeys.secondaryBackgroundColor)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text('有人给你分享了微口令!',
                    style: TextUtil.base.label(context).regular.sp(16).NotoSansSC),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(post.title,
                    style: TextUtil.base.label(context).bold.sp(17).NotoSansSC),
              ),
              if (post.imageUrls.isNotEmpty)
                Image.network(
                  baseUrl + post.imageUrls[0],
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  post.content,
                  style: TextUtil.base.infoText(context).regular.sp(14).NotoSansSC,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton(
                onPressed: onConfirm,
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(3),
                  overlayColor:
                      MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.pressed))
                      return WpyTheme.of(context).get(WpyThemeKeys.oldSecondaryActionColor);
                    return WpyTheme.of(context).get(WpyThemeKeys.secondaryBackgroundColor);
                  }),
                  backgroundColor: MaterialStateProperty.all(
                      WpyTheme.of(context).get(WpyThemeKeys.secondaryBackgroundColor)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
                ),
                child: Container(
                  margin: const EdgeInsets.all(7),
                  child: Text(
                    '查看详情',
                    style: TextUtil.base.label(context).regular.sp(16).NotoSansSC,
                  ),
                ),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ],
    );
  }
}
