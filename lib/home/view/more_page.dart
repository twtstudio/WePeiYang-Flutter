import 'package:flutter/material.dart';
import '../model/home_model.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';

class MorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cards = GlobalModel().cards;
    return Container(
      padding: const EdgeInsets.only(top: 65),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 25.0,
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
        childAspectRatio: 1.5,
        children: _getCardsWidget(cards, context),
      ),
    );
  }

  List<Widget> _getCardsWidget(List<CardBean> cards, BuildContext context) =>
      cards.map((e) => generateCard(context, e)).toList();
}

/// 此方法在wpy_page中有复用
Widget generateCard(BuildContext context, CardBean bean) {
  return GestureDetector(
    onTap: () => Navigator.pushNamed(context, bean.route),
    child: Card(
      elevation: 0.3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        children: <Widget>[
          Padding(
            child: Icon(
              bean.icon,
              color: Colors.grey,
              size: 30.0,
            ),
            padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 5.0),
          ),
          Center(
            child: Text(bean.label,
                style: TextStyle(
                    color: MyColors.darkGrey,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold)),
          )
        ],
      ),
    ),
  );
}
