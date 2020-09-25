import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/home/model/home_model.dart';
import 'package:wei_pei_yang_demo/schedule/model/schecule_extension.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';
import 'schedule_page.dart' show schedulePadding;

class ClassTableWidget extends StatelessWidget {
  static const double cardStep = 6;

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleNotifier>(builder: (context, notifier, _) {
      var width = GlobalModel.getInstance().screenWidth - schedulePadding * 2;
      var count = notifier.showSevenDay ? 7 : 6;
      var cardWidth = (width - (count - 1) * cardStep) / count;
      return Column(
        children: [WeekDisplayWidget(cardWidth, notifier, count)],
      );
    });
  }
}

class WeekDisplayWidget extends StatelessWidget {
  final double cardWidth;
  final ScheduleNotifier notifier;
  final int count;

  WeekDisplayWidget(this.cardWidth, this.notifier, this.count);

  @override
  Widget build(BuildContext context) => Row(
        children: _generateCards(cardWidth,
            getWeekDayString(notifier.termStart, notifier.selectedWeek, count)),
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

class CourseDisplayWidget extends StatelessWidget{
  final double cardWidth;
  final ScheduleNotifier notifier;
  final int count;

  CourseDisplayWidget(this.cardWidth, this.notifier, this.count);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _generatePositioned(),
    );
  }

  List<Widget> _generatePositioned(){
    List<Positioned> list = [];
    notifier.coursesWithNotify.forEach((element) {
      list.add(Positioned(

      ));
    });
    return list;
  }
}