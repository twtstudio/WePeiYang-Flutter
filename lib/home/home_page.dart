import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/color.dart';
import 'model/home_model.dart';
import 'net_page.dart';
import 'wpy_page.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// bottomNavigationBar对应的分页
  List<Widget> pages = List<Widget>();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    pages
      ..add(WPYPage())
      ..add(Center(child: RaisedButton(child: Text('test'),onPressed: (){
        Navigator.pushNamed(context, '/bind');
      },),))
      ..add(CPage());
  }

  @override
  Widget build(BuildContext context) {
    double width = GlobalModel.getInstance().screenWidth / 3;
    var currentStyle = TextStyle(
        fontSize: 20.0, color: MyColors.deepBlue, fontWeight: FontWeight.w800);
    var otherStyle = TextStyle(
        fontSize: 20.0, color: MyColors.deepDust, fontWeight: FontWeight.w800);
    return Scaffold(
        bottomNavigationBar: BottomAppBar(
          child: Row(
            children: <Widget>[
              Container(
                  height: 60.0,
                  width: width,
                  child: RaisedButton(
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(),
                      color: Colors.white,
                      child: Text('WPY',
                          style:
                              _currentIndex == 0 ? currentStyle : otherStyle),
                      onPressed: () => setState(() => _currentIndex = 0))),
              Container(
                  height: 60.0,
                  width: width,
                  child: RaisedButton(
                      elevation: 0.0,
                      color: Colors.white,
                      child: Text('News',
                          style:
                              _currentIndex == 1 ? currentStyle : otherStyle),
                      onPressed: () => setState(() => _currentIndex = 1))),
              Container(
                  height: 60.0,
                  width: width,
                  child: RaisedButton(
                      elevation: 0.0,
                      color: Colors.white,
                      child: Container(
                        padding: EdgeInsets.only(left: width / 4.5),
                        child: Row(
                          children: <Widget>[
                            Text('Tju',
                                style: _currentIndex == 2
                                    ? currentStyle
                                    : otherStyle),
                            Icon(
                              Icons.near_me,
                              color: _currentIndex == 2
                                  ? MyColors.deepBlue
                                  : MyColors.deepDust,
                            )
                          ],
                        ),
                      ),
                      onPressed: () => setState(() => _currentIndex = 2))),
            ],
          ),
        ),
        body: pages[_currentIndex]);
  }
}