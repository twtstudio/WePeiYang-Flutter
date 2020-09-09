import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/model.dart';
import 'package:wei_pei_yang_demo/more.dart';
import 'package:wei_pei_yang_demo/net_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> pages = List<Widget>();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    pages
      ..add(WPYPage())
      ..add(Center(
          child: RaisedButton(
        child: Text("kotlin button"),
        onPressed: () {},
      )))
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
                      //去除阴影效果
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

class WPYPage extends StatefulWidget {
  @override
  WPYPageState createState() => WPYPageState();
}

class WPYPageState extends State<WPYPage> {
  List<CardBean> cards = [];
  List<CourseBean> courses = [];
  List<LibraryBean> libraries = [];

  @override
  void initState() {
    super.initState();
    cards.add(CardBean(Icons.directions_bike, 'Bicycle', '/bicycle'));
    cards.add(CardBean(Icons.timeline, 'GPA', '/gpa'));
    cards.add(CardBean(Icons.import_contacts, 'Learning', '/learning'));
    cards.add(CardBean(Icons.call, 'Tel Num', '/telNum'));
    cards.add(CardBean(Icons.clear_all, 'Library', '/library'));
    cards.add(CardBean(Icons.card_giftcard, 'Cards', '/cards'));
    cards.add(CardBean(Icons.business, 'Classroom', '/classroom'));
    cards.add(CardBean(Icons.free_breakfast, 'Coffee', '/coffee'));
    cards.add(CardBean(Icons.directions_bus, 'By bus', '/byBus'));
    courses.add(CourseBean('SoftWare Engineering', '08:30-10:10', '45-B311'));
    courses.add(CourseBean('Computer Network', '10:20-11:50', '46-A108'));
    courses.add(CourseBean('College Japanese', '13:30-15:00', '47-B228'));
    courses.add(CourseBean('Free Time', null, null));
    courses.add(CourseBean('College English', '18:30-20:30', '45-B117'));
    libraries.add(LibraryBean('Design Psychology1', '2018-08-08'));
    libraries.add(LibraryBean('User Experience', '2018-07-29'));
    libraries.add(LibraryBean('The visual design', '2018-07-26'));
  }

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var week = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    var libraryCount = libraries.length >= 10
        ? libraries.length.toString()
        : '0${libraries.length}';
    return Material(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.only(top: 30.0),
            sliver: SliverPersistentHeader(
                delegate:
                    _WPYHeader(date: '${now.year}.${now.month}.${now.day}'),
                pinned: true),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 90.0,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  itemCount: cards.length + 1,
                  itemBuilder: (context, i) {
                    return GestureDetector(
                      onTap: () {
                        if (i == cards.length) {
                          Navigator.pushNamed(context, '/more',
                              arguments: CardArguments(cards));
                        } else
                          Navigator.pushNamed(context, cards[i].route);
                      },
                      child: Container(
                        height: 90.0,
                        width: 130.0,
                        padding: EdgeInsets.symmetric(horizontal: 3.0),
                        child: _getCard(i),
                      ),
                    );
                  }),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 20.0, 0.0, 12.0),
              child: Text('NO.${now.day} ${week[now.weekday - 1]}',
                  style: TextStyle(
                      fontSize: 17.0,
                      color: MyColors.deepBlue,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 180.0,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: courses.length,
                  itemBuilder: (context, i) {
                    return GestureDetector(
                      onTap: () {
//                        Navigator.push(context, MaterialPageRoute(builder: (context) => Text('123')));
                      },
                      child: Container(
                        height: 180.0,
                        width: 150.0,
                        padding: EdgeInsets.symmetric(horizontal: 7.0),
                        child: Card(
                          color: MyColors.colorList[i % 5],
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: 95.0,
                                  alignment: Alignment.centerLeft,
                                  child: Text(courses[i].course,
                                      style: TextStyle(
                                          fontSize: 17.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text(
                                      courses[i].duration ?? 'Your own time',
                                      style: TextStyle(
                                          fontSize: 13.0, color: Colors.white)),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15.0),
                                  child: Text(courses[i].classroom ?? '',
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 20.0, 0.0, 15.0),
              child: Text('Library $libraryCount',
                  style: TextStyle(
                      fontSize: 17.0,
                      color: MyColors.deepBlue,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 170.0,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: libraries.length,
                  itemBuilder: (context, i) {
                    return GestureDetector(
                      onTap: () {
//                        Navigator.push(context, MaterialPageRoute(builder: (context) => Text('123')));
                      },
                      child: Container(
                        height: 170.0,
                        width: 150.0,
                        padding: EdgeInsets.symmetric(horizontal: 7.0),
                        child: Card(
                          color: Colors.white,
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          child: Row(
                            children: <Widget>[
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: 2.0),
                                  decoration: BoxDecoration(
                                      color: MyColors.colorList[(i + 3) % 5],
                                      borderRadius: BorderRadius.only(
                                          topLeft:
                                              Radius.elliptical(60.0, 120.0),
                                          bottomLeft:
                                              Radius.elliptical(60.0, 120.0))),
                                  width: 6.0),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 11.0),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        height: 95.0,
                                        alignment: Alignment.centerLeft,
                                        child: Text(libraries[i].book,
                                            style: TextStyle(
                                                fontSize: 17.0,
                                                color: MyColors.deepBlue,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.only(top: 15.0),
                                        child: Text('Time:',
                                            style: TextStyle(
                                              fontSize: 13.0,
                                              color: MyColors.deepBlue,
                                            )),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(libraries[i].time,
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                color: MyColors.deepBlue)),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 25.0, 0.0, 15.0),
              child: Text('GPA Curve',
                  style: TextStyle(
                      fontSize: 17.0,
                      color: MyColors.deepBlue,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          SliverToBoxAdapter(
              child: GPACurve(
            gpaBean: GPABean([77.512, 92.155, 65.326, 84.682], 89.869, 3.869),
            width: GlobalModel.getInstance().screenWidth,
          )),
          SliverToBoxAdapter(
            child: Container(
              height: 180.0,
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
              child: Card(
                color: MyColors.myGrey,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Center(
                  child: GestureDetector(
                    child: Text(
                      'MORE >>',
                      style: TextStyle(
                          fontSize: 25.0,
                          color: MyColors.darkGrey2,
                          fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/more',
                          arguments: CardArguments(cards));
                    },
                  ),
                ),
              ),
            ),
          ),
//          SliverFillRemaining(
//              child: Center(
//                  child:
//                      Text('FillRemaining', style: TextStyle(fontSize: 30.0)))),
        ],
      ),
    );
  }

  Widget _getCard(int index) {
    if (index == cards.length) {
      var startColor = Color.fromRGBO(142, 147, 171, 1.0);
      var endColor = Color.fromRGBO(166, 170, 185, 1.0);
      return GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/more',
            arguments: CardArguments(cards)),
        child: Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  gradient: LinearGradient(colors: [startColor, endColor])),
              child: Center(
                  child: Text('More',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold))),
            )),
      );
    } else
      return generateCard(context, cards[index]);
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

class _WPYHeader extends SliverPersistentHeaderDelegate {
  final String date;

  _WPYHeader({@required this.date});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white, //比其他区域rgb均高了5,遮挡后方滚动区域
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(30.0, 15.0, 10.0, 0.0),
      child: Row(
        children: <Widget>[
          Text(date,
              style: TextStyle(
                  fontSize: 25.0,
                  color: MyColors.deepBlue,
                  fontWeight: FontWeight.bold)),
          Expanded(child: Text('')), //起填充作用
          Text('BOTillya',
              style: TextStyle(color: MyColors.deepBlue, fontSize: 17.0)),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/user'),
            child: Container(
              height: 40.0,
              width: 40.0,
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: ClipOval(
                  child:
                      Image(image: AssetImage('assets/images/user_image.jpg'))),
            ),
          )
//          IconButton(
//            iconSize: 40.0,
//            icon: Icon(Icons.account_circle, color: Colors.grey),
//            onPressed: () => Navigator.pushReplacementNamed(context, '/user'),
//          )
        ],
      ),
    );
  }

  @override
  double get maxExtent => 120.0;

  @override
  double get minExtent => 65.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}

class GPACurve extends StatefulWidget {
  final GPABean gpaBean;
  final double width;

  const GPACurve({@required this.gpaBean, @required this.width});

  @override
  _GPACurveState createState() => _GPACurveState();
}

class _GPACurveState extends State<GPACurve>
    with SingleTickerProviderStateMixin {
  List<Point<double>> _points = [];
  int selected = 0; //selected == 0 代表未触碰任意一点
  int _lastTaped = 1;
  int _newTaped = 1;

  @override
  void initState() {
    initPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gpaBean.gpaList == null) {
      //TODO 提示内容完善
      return Text('没有gpa数据呢亲');
    }

    return Column(
      children: <Widget>[
        GestureDetector(
            //TODO 不知道为啥不起作用
            onHorizontalDragCancel: () => setState(() => selected = 0),
            onTapCancel: () => setState(() => selected = 0),
            //点击监听
            onTapDown: (TapDownDetails detail) {
              RenderBox renderBox = context.findRenderObject();
              var localOffset = renderBox.globalToLocal(detail.globalPosition);
              setState(() {
                selected = judgeSelected(localOffset);
                if (selected != 0) _newTaped = selected;
              });
            },
            //滑动监听
            onHorizontalDragUpdate: (DragUpdateDetails detail) {
              RenderBox renderBox = context.findRenderObject();
              var localOffset = renderBox.globalToLocal(detail.globalPosition);
              setState(() {
                selected = judgeSelected(localOffset);
              });
            },
            child: Container(
              height: 160.0,
              width: widget.width,
              child: Stack(
                children: <Widget>[
                  CustomPaint(
                    painter:
                    _GPACurvePainter(points: _points, selected: selected),
                    size: Size(widget.width, 160.0),
                  ),
                  TweenAnimationBuilder(
                    duration: Duration(milliseconds: 500),
                    tween: Tween(
                        begin: 0.0, end: (_lastTaped == _newTaped) ? 0.0 : 1.0),
                    onEnd: () {
                      setState(() {
                        _lastTaped = _newTaped;
                      });
                    },
                    builder: (BuildContext context, value, Widget child) {
                      var lT = _points[_lastTaped], nT = _points[_newTaped];
                      return Transform.translate(
                        //40.0和60.0用来对准黑白圆点的圆心
                        offset: Offset(lT.x - 50.0 + (nT.x - lT.x) * value,
                            lT.y - 55.0 + (nT.y - lT.y) * value),
                        child: Container(
                          width: 100.0,
                          height: 70.0,
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 40.0,
                                child: Card(
                                  color: Colors.white,
                                  elevation: 3.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0)),
                                  child: Center(
                                    child: Text(
                                        '${widget.gpaBean.gpaList[_newTaped - 1]}',
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            color: MyColors.deepBlue,
                                            fontWeight: FontWeight.w900)),
                                  ),
                                ),
                              ),
                              CustomPaint(
                                painter: _GPAPopupPainter(),
                                size: Size(100.0, 30.0),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text('Total Weighted',
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0)),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('${widget.gpaBean.weighted}',
                      style: TextStyle(
                          color: MyColors.deepBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0)),
                )
              ],
            ),
            Column(
              children: <Widget>[
                Text('Total Grade',
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0)),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('${widget.gpaBean.grade}',
                      style: TextStyle(
                          color: MyColors.deepBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0)),
                )
              ],
            ),
          ],
        )
      ],
    );
  }

  initPoints() {
    var list = widget.gpaBean.gpaList;
    final double widthStep = widget.width / (list.length + 1);
    //对起止gpa曲线的预测值
    final double startGPA = (list[0] <= 5.0) ? 15 : list[0] - 5;
    final double endGPA = (list.last >= 95.0) ? 95 : list.last + 5;
    //求gpa最小值（算上起止）与最值差，使曲线高度符合比例
    final double minGPA = min(list.reduce(min), startGPA); //单独写出来是因为后面会用到
    final double gap = max(list.reduce(max), endGPA) - minGPA;
    _points.add(Point(0, 140 - (startGPA - minGPA) / gap * 120));
    for (var i = 1; i <= list.length; i++) {
      _points
          .add(Point(i * widthStep, 140 - (list[i - 1] - minGPA) / gap * 120));
    }
    _points.add(Point(widget.width, 140 - (endGPA - minGPA) / gap * 120));
  }

  //判断触碰位置是否在任意圆内, r应大于点的默认半径radius,使圆点易触
  int judgeSelected(Offset touchOffset, {double r = 15.0}) {
    var sx = touchOffset.dx;
    var sy = touchOffset.dy;
    for (var i = 1; i < _points.length - 1; i++) {
      var x = _points[i].x;
      var y = _points[i].y;
      if (!((sx - x) * (sx - x) + (sy - y) * (sy - y) > r * r)) return i;
    }
    return 0;
  }
}

class _GPAPopupPainter extends CustomPainter {
  static const outerWidth = 4.0;
  static const innerRadius = 5.0;
  static const outerRadius = 7.0;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final Paint outerPaint = Paint()
      ..color = MyColors.deepBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerWidth;
    canvas.drawCircle(size.center(Offset.zero), innerRadius, innerPaint);
    canvas.drawCircle(size.center(Offset.zero), outerRadius, outerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) => false;
}

class _GPACurvePainter extends CustomPainter {
  final List<Point<double>> points;
  final int selected;

  const _GPACurvePainter({@required this.points, @required this.selected});

  drawLine(Canvas canvas, List<Point<double>> points) {
    final Paint paint = Paint()
      ..color = MyColors.dust
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    final Path path = Path()
      ..moveTo(0, points[0].y)
      ..cubicThrough(points);
    canvas.drawPath(path, paint);
  }

  drawPoint(Canvas canvas, List<Point<double>> points, int selected,
      {double radius = 6.0}) {
    final Paint paint = Paint()
      ..color = MyColors.darkGrey2
      ..style = PaintingStyle.fill;
    for (var i = 1; i < points.length - 1; i++) {
      if (i == selected)
        canvas.drawCircle(
            Offset(points[i].x, points[i].y), radius + 3.0, paint);
      else
        canvas.drawCircle(Offset(points[i].x, points[i].y), radius, paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawLine(canvas, points);
    drawPoint(canvas, points, selected);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) => false;
}

extension Cubic on Path {
  cubicThrough(List<Point<double>> list) {
    for (var i = 0; i < list.length - 1; i++) {
      var point1 = list[i];
      var point2 = list[i + 1];
      var bias = (point2.x - point1.x) * 0.5;
      var cp1 = Point(point1.x + bias, point1.y);
      var cp2 = Point(point2.x - bias, point2.y);
      cubicTo(cp1.x, cp1.y, cp2.x, cp2.y, point2.x, point2.y);
    }
  }
}
