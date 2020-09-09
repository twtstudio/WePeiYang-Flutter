import 'package:flutter/material.dart';

import 'home_model.dart';
import 'package:wei_pei_yang_demo/commons/color.dart';

class MorePage extends StatefulWidget {
  @override
  _MorePageState createState() => _MorePageState();
}

///传递cards参数（Extract方法）
class CardArguments {
  final List<CardBean> cards;

  CardArguments(this.cards);
}

class _MorePageState extends State<MorePage> {
  @override
  Widget build(BuildContext context) {
    final CardArguments args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 247, 1.0),
      body: Column(
        children: <Widget>[
          Container(
              margin: EdgeInsets.fromLTRB(20.0, 30.0, 0, 0),
              height: 50.0,
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                  child: Icon(Icons.arrow_back,
                      color: MyColors.deepBlue, size: 30.0),
                  onTap: () => Navigator.pop(context))),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 25.0,
              padding: EdgeInsets.symmetric(horizontal: 50.0,vertical: 10.0),
              childAspectRatio: 1.5,
              children: getMoreCards(args.cards),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> getMoreCards(List<CardBean> cards) {
    return cards.map((e) => generateCard(context,e)).toList();
  }
}

Widget generateCard(BuildContext context, CardBean bean) {
  return GestureDetector(
    onTap: () => Navigator.pushNamed(context, bean.route),
    child: Card(
      elevation: 0.5,
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
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold)),
          )
        ],
      ),
    ),
  );
}