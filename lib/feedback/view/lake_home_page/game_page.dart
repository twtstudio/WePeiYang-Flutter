import 'dart:math';

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/home/home_router.dart';
import 'package:we_pei_yang_flutter/main.dart';

// ignore: must_be_immutable
class GamePage extends StatelessWidget {
  List<String> _title = ['大学重开模拟器', '北洋维基', '反馈问题可以到青年湖底内测群，QQ：563107013', '如果有404叠在我头上是正常现象，无需反馈'];
  List<String> _uri = [HomeRouter.restartGame, HomeRouter.wiki, '', ''];
  List<bool> _used = [true, true, false, false];

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
  final random = Random();

  final List<Color> colorOfMonkey = [Color.fromRGBO(
      223, 214, 255, 0.5019607843137255),Color.fromRGBO(
      241, 184, 255, 0.5),Color.fromRGBO(
      184, 197, 255, 0.5),Color.fromRGBO(
      184, 255, 251, 0.5),Color.fromRGBO(
      184, 255, 220, 0.5),Color.fromRGBO(
      186, 255, 184, 0.5),Color.fromRGBO(
      247, 255, 184, 0.5),Color.fromRGBO(
      255, 199, 184, 0.5),];

  GameCard(this.title, this.uri, this.used);

  @override
  Widget build(BuildContext context) {
    final Color _color = colorOfMonkey[random.nextInt(colorOfMonkey.length)];
    return SizedBox(
      height: 130,
      child: InkWell(
        onTap: () => used ? Navigator.pushNamed(context, this.uri) : {},
        child: Container(
            margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            padding: EdgeInsets.fromLTRB(16.0, 20.0, 10.0, 8.0),
            decoration: BoxDecoration(
              color: ColorUtil.white253,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: WePeiYangApp.screenWidth - 160,child: Text(this.title,style: TextUtil.base.w600.black2A.NotoSansSC.sp(18), maxLines: 3,)),
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                      color: _color,
                    borderRadius: BorderRadius.all(Radius.circular(13)),
                      image: DecorationImage(image: AssetImage('assets/images/lake_butt_icons/monkie.png'),fit: BoxFit.scaleDown)
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
