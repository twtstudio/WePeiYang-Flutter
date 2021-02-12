import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wei_pei_yang_demo/studyroom/model/time.dart';
import 'package:wei_pei_yang_demo/studyroom/provider/provider_widget.dart';
import 'package:wei_pei_yang_demo/studyroom/ui/widget/base_page.dart';
import 'package:wei_pei_yang_demo/studyroom/view_model/class_plan_model.dart';
import 'package:wei_pei_yang_demo/studyroom/view_model/schedule_model.dart';

class ClassPlanPage extends StatefulWidget {
  final String aId; // area id
  final String bId; // building id
  final String cId; // classroom id
  final String title;

  const ClassPlanPage({Key key, this.aId, this.bId, this.cId, this.title})
      : super(key: key);

  @override
  _ClassPlanPageState createState() => _ClassPlanPageState();
}

class _ClassPlanPageState extends State<ClassPlanPage> {
  @override
  Widget build(BuildContext context) {
    return ProviderWidget<ClassPlanModel>(
      model: ClassPlanModel(
          aId: widget.aId,
          bId: widget.bId,
          cId: widget.cId,
          scheduleModel: Provider.of<SRTimeModel>(context)),
      onModelReady: (model) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          model.initData();
        });
      },
      builder: (context, model, child) {
        return StudyRoomPage(
          body: Padding(
            padding: const EdgeInsets.all(15),
            child: Builder(builder: (_) {
              if (model.isError && model.list.isEmpty) {
                return Container(
                  child: Center(
                    child: Text('加载失败'),
                  ),
                );
              }
              return SmartRefresher(
                controller: model.refreshController,
                header: ClassicHeader(),
                onRefresh: () => model.refresh(),
                child: ListView(
                  children: <Widget>[
                    PageTitleWidget(title: widget.title),
                    if (model.plan?.isNotEmpty ?? false) ClassTableWidget()
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class PageTitleWidget extends StatelessWidget {
  final String title;

  const PageTitleWidget({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Color(0xff62677b),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(child: SizedBox()),
        InkWell(
          onTap: () {},
          child: Text(
            '收藏',
            style: TextStyle(
              color: Color(0xff62677b),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}

/// 课程表每个item之间的间距
const double cardStep = 6;
const schedulePadding = 25;

/// 这个Widget包括日期栏和下方的具体课程
class ClassTableWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width - schedulePadding * 2;
    var dayCount = false ? 7 : 6;
    var cardWidth = (width - (dayCount - 1) * cardStep) / dayCount;
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        WeekDisplayWidget(cardWidth, dayCount),
        Padding(
          padding: const EdgeInsets.only(top: cardStep),
          child: CourseDisplayWidget(cardWidth, dayCount),
        )
      ],
    );
  }
}

class WeekDisplayWidget extends StatelessWidget {
  final double cardWidth;
  final int dayCount;

  WeekDisplayWidget(this.cardWidth, this.dayCount);

  @override
  Widget build(BuildContext context) => Row(
        children: _generateCards(cardWidth, ['1', '2', '3', '4', '5', '6']),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      );

  List<Widget> _generateCards(double width, List<String> dates) {
    List<Widget> list = [];
    dates.forEach((element) {
      list.add(_getCard(width, element));
    });
    return list;
  }

  /// 因为card组件宽度会比width小一些，不好对齐，因此用container替代
  Widget _getCard(double width, String date) => Container(
        height: 28,
        width: width,
        decoration: BoxDecoration(
            color: Color.fromRGBO(236, 238, 237, 1),
            borderRadius: BorderRadius.circular(5)),
        child: Center(
          child: Text(date,
              style: TextStyle(
                  color: Color.fromRGBO(200, 200, 200, 1),
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ),
      );
}

class CourseDisplayWidget extends StatelessWidget {
  final double cardWidth;
  final int dayCount;

  CourseDisplayWidget(this.cardWidth, this.dayCount);

  @override
  Widget build(BuildContext context) {
    var singleCourseHeight = cardWidth * 136 / 96;
    return Container(
      height: singleCourseHeight * 12 + cardStep * 11,
      child: Consumer<ClassPlanModel>(builder: (_, model, __) {
        if (model.plan?.isNotEmpty ?? false) {
          return Stack(
            children:
                _generatePositioned(context, singleCourseHeight, model.plan),
          );
        }

        return Container();
      }),
    );
    // return Container();
  }

  List<Widget> _generatePositioned(BuildContext context, double courseHeight,
      Map<String, List<String>> plan) {
    List<Positioned> list = [];
    var d = 1;
    for (var wd in Time.week.getRange(0, 6)) {
      var index = 1;
      print(wd);
      print(plan[wd].toString());
      for (var c in plan[wd]) {
        print(wd);
        int day = d;
        int start = index;
        index = index + c.length;
        int end = index - 1;
        double top = (start == 1) ? 0 : (start - 1) * (courseHeight + cardStep);
        double left = (day == 1) ? 0 : (day - 1) * (cardWidth + cardStep);
        double height =
            (end - start + 1) * courseHeight + (end - start) * cardStep;

        /// 判断周日的课是否需要显示在课表上
        if (day <= 7 && c.contains('1'))
          list.add(Positioned(
              top: top,
              left: left,
              height: height,
              width: cardWidth,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  shape: BoxShape.rectangle,
                  color: Color(0xff7a778a),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '课程占',
                        style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(
                        '用',
                        style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )));
      }
      d++;
    }
    return list;
  }
}
