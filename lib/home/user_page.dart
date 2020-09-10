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
          ListView(
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
                              color: Colors.white, size: 30.0),

                          ///TODO: setting page
                          onTap: () => Navigator.pop(context))
                    ],
                  )),
              Container(
                alignment: Alignment.center,
                //height: 85.0,
                 //width: 85.0,
                margin: EdgeInsets.only(bottom: 15.0),
                child: ClipOval(
                    child: Image.asset(
                  'assets/images/user_image.jpg',
                  fit: BoxFit.cover,
                  width: 110,
                  height: 110,
                )),
              ),
              Text('BOTillya',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  )),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text('3019244334',
                      textAlign: TextAlign.center,
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
                            Image.asset(
                              "assets/images/gradicon1.png",
                              width: 60,
                              height: 60,
                            ),
                            Text(
                              "GPA",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 19.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(99, 101, 115, 1)),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Image.asset(
                              "assets/images/gradicon2.png",
                              width: 60,
                              height: 60,
                            ),
                            Text(
                              "Library",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19.0,
                                  color: Color.fromRGBO(99, 101, 115, 1)),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Image.asset(
                              "assets/images/gradicon3.png",
                              width: 60,
                              height: 60,
                            ),
                            Text(
                              "E-card",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19.0,
                                  color: Color.fromRGBO(99, 101, 115, 1)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 80,
                margin: EdgeInsets.only(left: 30.0, right: 30.0),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9.0))),
                  disabledColor: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.calendar_today),
                      Text(
                        "Portal acoount",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Color.fromRGBO(99, 101, 115, 1)),
                      ),
                      Expanded(
                        child: Container(
                          height: 80,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 80,
                margin: EdgeInsets.only(left: 30.0, right: 30.0),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9.0))),
                  color: Colors.white,
                  disabledColor: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.credit_card),
                      Text(
                        "E-card acoount",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Color.fromRGBO(99, 101, 115, 1)),
                      ),
                      Expanded(
                        child: Container(
                          height: 80,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 80,
                margin: EdgeInsets.only(left: 30.0, right: 30.0),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9.0))),
                  color: Colors.white,
                  disabledColor: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.book,
                      ),
                      Text(
                        "Library acoount",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Color.fromRGBO(99, 101, 115, 1)),
                      ),
                      Expanded(
                        child: Container(
                          height: 80,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 70,
                margin: EdgeInsets.only(left: 30.0, right: 30.0),
                alignment: Alignment.center,
                //width: 10,
                child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    disabledColor: Color.fromRGBO(99, 101, 115, 1),
                    color: Color.fromRGBO(99, 101, 115, 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        Text(
                          "SIGN ME OUT",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
