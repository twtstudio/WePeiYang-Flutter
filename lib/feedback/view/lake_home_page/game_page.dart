import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/home/home_router.dart';
import 'package:we_pei_yang_flutter/main.dart';

import '../../../commons/widgets/w_button.dart';

class GamePage extends StatelessWidget {
  final List<String> _title = ['大学重开模拟器', '北洋维基', '敬请期待'];
  final List<String> _uri = [HomeRouter.restartGame, HomeRouter.wiki, ''];
  final List<bool> _used = [true, true, false];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _title.length,
      itemBuilder: (BuildContext context, int index) {
        return GameCard(_title[index], _uri[index], _used[index]);
      },
    );
  }
}

class GameCard extends StatelessWidget {
  final String title;
  final String uri;
  final bool used;

  GameCard(this.title, this.uri, this.used);

  @override
  Widget build(BuildContext context) {
    final Color _color = ColorUtil.iconAnimationStartColor;
    return SizedBox(
      height: 130,
      child: WButton(
        onPressed: () => used ? Navigator.pushNamed(context, this.uri) : {},
        child: Container(
            margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            padding: EdgeInsets.fromLTRB(16.0, 20.0, 10.0, 8.0),
            decoration: BoxDecoration(
              color: ColorUtil.whiteFDFE,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                    width: WePeiYangApp.screenWidth - 160,
                    child: Text(
                      this.title,
                      style: TextUtil.base.w600.label.NotoSansSC.sp(18),
                      maxLines: 3,
                    )),
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: _color,
                    borderRadius: BorderRadius.all(Radius.circular(13)),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
