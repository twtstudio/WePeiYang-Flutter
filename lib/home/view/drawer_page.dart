import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import '../model/home_model.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:flutter/services.dart';

// TODO 暂时废弃
class DrawerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cards = GlobalModel().cards;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Container(
      padding: const EdgeInsets.only(top: 65),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 25.0,
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
        childAspectRatio: 117 / 86,
        children: _getCardsWidget(cards, context),
      ),
    );
  }

  List<Widget> _getCardsWidget(List<CardBean> cards, BuildContext context) =>
      cards
          .map((e) => generateCard(context, e, textColor: Color(0xff656b80)))
          .toList();
}

/// 此方法在wpy_page中有复用
Widget generateCard(BuildContext context, CardBean bean, {Color textColor}) {
  return Card(
    elevation: 0.3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        bean.icon,
        Container(height: 5),
        Center(
          child: Text(bean.label,
              style: FontManager.YaQiHei.copyWith(
                  color: textColor ?? MyColors.darkGrey,
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold)),
        )
      ],
    ),
  );
}
