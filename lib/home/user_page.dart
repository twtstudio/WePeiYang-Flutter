import 'package:flutter/material.dart';

import 'package:wei_pei_yang_demo/commons/color.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 247, 1.0),
      body: Stack(
        children: <Widget>[
          Container(
            height: 320.0,
            color: MyColors.darkGrey,
          ),
          Column(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0),
                  height: 50.0,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                          child: Icon(Icons.arrow_back,
                              color: Colors.white, size: 30.0),
                          onTap: () => Navigator.pop(context)),
                      Expanded(child: Text('')),



                      ///填充
                      GestureDetector(
                          child: Icon(Icons.settings,
                              color: Colors.white, size: 25.0),

                          ///TODO: setting page
                          onTap: () => Navigator.pop(context))
                    ],
                  )),
              Container(
                height: 85.0,
                width: 85.0,
                margin: EdgeInsets.only(bottom: 15.0),
                child: ClipOval(
                  child:
                      Image(image: AssetImage('assets/images/user_image.jpg')),
                ),
              ),
              Text('BOTillya',
                  style: TextStyle(color: Colors.white, fontSize: 22.0)),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text('3019244334',
                      style:
                          TextStyle(color: MyColors.deepDust, fontSize: 13.0))),
              Container(
                height: 150.0,
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Card(
                  elevation: 1.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Icon(Icons.timeline,
                                color: Colors.grey, size: 40),
                            Padding(
                              padding: const EdgeInsets.only(top:12),
                              child: Text('GPA',
                                  style: TextStyle(
                                      color: MyColors.darkGrey,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Icon(Icons.import_contacts,
                                color: Colors.grey, size: 40),
                            Padding(
                              padding: const EdgeInsets.only(top:12),
                              child: Text('Learning',
                                  style: TextStyle(
                                      color: MyColors.darkGrey,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Icon(Icons.card_giftcard,
                                color: Colors.grey, size: 40),
                            Padding(
                              padding: const EdgeInsets.only(top:12.0),
                              child: Text('Cards',
                                  style: TextStyle(
                                      color: MyColors.darkGrey,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
