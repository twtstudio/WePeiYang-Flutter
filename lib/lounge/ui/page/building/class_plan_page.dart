import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/lounge/model/classroom.dart';
import 'package:wei_pei_yang_demo/lounge/service/time_factory.dart';
import 'package:wei_pei_yang_demo/lounge/provider/provider_widget.dart';
import 'package:wei_pei_yang_demo/lounge/ui/widget/base_page.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/class_plan_model.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/favourite_model.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/sr_time_model.dart';

class ClassPlanPage extends StatelessWidget {
  final Classroom room;

  const ClassPlanPage({Key key, this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<ClassPlanModel>(
      model: ClassPlanModel(
          room: room, scheduleModel: Provider.of<SRTimeModel>(context)),
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
              return ListView(
                physics: BouncingScrollPhysics(),
                children: <Widget>[
                  PageTitleWidget(title: room.name, room: room),
                  if (model.plan?.isNotEmpty ?? false) ClassTableWidget()
                ],
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
  final Classroom room;

  const PageTitleWidget({Key key, this.title, this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          // color: Colors.yellow,
          padding: const EdgeInsets.only(bottom: 15),
          child: Text(
            title,
            style: TextStyle(
              color: Color(0xff62677b),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: SizedBox()),

        // article list item 中有收藏按钮的写法
        Container(
          // color: Colors.yellow,
          padding: const EdgeInsets.only(bottom: 7),
          child: ProviderWidget<FavouriteModel>(
            model: FavouriteModel(
                globalFavouriteModel: Provider.of(context, listen: false)),
            builder: (_, favouriteModel, __) => TextButton(
              // 去除默认padding
              style: ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: MaterialStateProperty.all(Size(0, 0)),
                padding: MaterialStateProperty.all(EdgeInsets.zero),
              ),
              onPressed: () async {
                if (!favouriteModel.isBusy) {
                  addFavourites(context, room: room, model: favouriteModel);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  favouriteModel.globalFavouriteModel.contains(cId: room.id)
                      ? '取消收藏'
                      : '收藏',
                  style: TextStyle(
                    color: Color(0xff62677b),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
const double countTabWidth = 22;

/// 这个Widget包括日期栏和下方的具体课程
class ClassTableWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width -
        schedulePadding * 2 -
        countTabWidth -
        cardStep;
    var dayCount = false ? 7 : 6;
    var cardWidth = (width - (dayCount - 1) * cardStep) / dayCount;
    var tabHeight = cardWidth * 136 / 96;
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Container(
          height: tabHeight * 12 + cardStep * 12 + 28,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: cardStep + countTabWidth,
                child: SizedBox(
                  height: 28,
                  width: width,
                  child: WeekDisplayWidget(cardWidth, dayCount),
                ),
              ),
              Positioned(
                top: cardStep + 28,
                left: cardStep + countTabWidth,
                child: CourseDisplayWidget(cardWidth, dayCount),
              ),
              Positioned(
                top: cardStep + 28,
                left: 0,
                child: CourseTabDisplayWidget(tabHeight, dayCount),
              )
            ],
          ),
        )
      ],
    );
  }
}

class CourseTabDisplayWidget extends StatelessWidget {
  final int dayCount;
  final double tabHeight;

  const CourseTabDisplayWidget(this.tabHeight, this.dayCount, [Key key])
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var stepHeight = tabHeight * 2 + cardStep;
    return Consumer<ClassPlanModel>(
      builder: (_, model, __) => Container(
        width: countTabWidth,
        height: tabHeight * 12 + cardStep * 11,
        child: Stack(
          children: Time.rangeList.asMap().keys.map((step) {
            var chosen = model.classTime.isNotEmpty
                ? model.classTime
                    .map((e) => e.index == step)
                    .reduce((v, e) => v || e)
                : false;
            return Positioned(
              top: (stepHeight + cardStep) * step,
              child: Container(
                height: stepHeight,
                width: countTabWidth,
                child: Column(
                  children: [
                    CourseTab(
                      tabHeight,
                      chosen,
                      step * 2,
                    ),
                    Container(height: cardStep),
                    CourseTab(
                      tabHeight,
                      chosen,
                      step * 2 + 1,
                    )
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class CourseTab extends StatelessWidget {
  final double height;
  final bool chosen;
  final int step;

  const CourseTab(this.height, this.chosen, this.step, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: countTabWidth,
      decoration: BoxDecoration(
          color: chosen ? Color(0xff303c66) : Color(0xffecedef),
          borderRadius: BorderRadius.circular(5)),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(
              color: chosen ? Color(0xfff7f7f8) : Color(0xffcfd0d5),
              fontSize: 9,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class WeekDisplayWidget extends StatelessWidget {
  final double cardWidth;
  final int dayCount;

  WeekDisplayWidget(this.cardWidth, this.dayCount);

  @override
  Widget build(BuildContext context) {
    return Consumer<ClassPlanModel>(
      builder: (_, model, __) => Row(
        children: model.dateTime.thisWeek
            .sublist(0, dayCount)
            .map((date) => Container(
                  height: 28,
                  width: cardWidth,
                  decoration: BoxDecoration(
                      color: model.dateTime.isTheSameDay(date)
                          ? Color(0xff303c66)
                          : Color(0xffecedef),
                      borderRadius: BorderRadius.circular(5)),
                  child: Center(
                    child: Text(
                      '${date.month}/${date.day}',
                      style: TextStyle(
                          color: model.dateTime.isTheSameDay(date)
                              ? Color(0xfff7f7f8)
                              : Color(0xffcfd0d5),
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ))
            .toList(),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }
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
      width: MediaQuery.of(context).size.width -
          schedulePadding * 2 -
          countTabWidth -
          cardStep,
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
      // print(wd);
      // print(plan[wd].toString());
      for (var c in plan[wd]) {
        // print(wd);
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
