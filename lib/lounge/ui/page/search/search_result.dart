import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/lounge/lounge_router.dart';
import 'package:wei_pei_yang_demo/lounge/model/area.dart';
import 'package:wei_pei_yang_demo/lounge/model/building.dart';
import 'package:wei_pei_yang_demo/lounge/model/search_entry.dart';
import 'package:wei_pei_yang_demo/lounge/provider/provider_widget.dart';
import 'package:wei_pei_yang_demo/lounge/service/data_factory.dart';
import 'package:wei_pei_yang_demo/lounge/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/lounge/ui/widget/building_grid_view.dart';
import 'package:wei_pei_yang_demo/lounge/ui/widget/list_load_steps.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/search_model.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/sr_time_model.dart';

class SearchResult extends StatelessWidget {
  final String query;
  final SearchHistoryModel searchHistoryModel;

  const SearchResult({this.query, this.searchHistoryModel});

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<SearchResultModel>(
      model: SearchResultModel(
          query: query, searchHistoryModel: searchHistoryModel),
      onModelReady: (model) {
        model.initData();
      },
      builder: (_, model, __) => ListLoadSteps(
        model: model,
        successV: Builder(
          builder: (_) {
            Widget body;
            List<ResultEntry> result = model.list.cast<ResultEntry>();
            switch (DataFactory.getResultType(model.list.first)) {
              case ResultType.building:
                List<Building> list = result.map((e) => e.building).toList();
                body = ListView(
                  physics: BouncingScrollPhysics(),
                  children: [BuildingGridView(list: list)],
                );
                break;
              case ResultType.room:
                body = ResultRoomsListView(list: result);
                break;
              case ResultType.area:
                body = ResultAreasGridView(list: result);
                break;
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: body,
            );
          },
        ),
      ),
    );
  }
}

class ResultRoomsListView extends StatelessWidget {
  final List<ResultEntry> list;

  const ResultRoomsListView({Key key, this.list}) : super(key: key);

  Widget _room(ResultEntry entry, SRTimeModel model) {
    var b = entry.building?.name ?? '';
    var a = entry.area?.id ?? '';
    var c = entry.room?.name ?? '';
    String title = DataFactory.getTitle(HistoryEntry(b, c, a));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              color: Color(0xff62677c),
              fontWeight: FontWeight.bold,
              fontSize: 12),
        ),
        FutureBuilder(
          future: HiveManager.instance.getRoomPlans(
            r: entry.room..bId = entry.building.id,
            dateTime: model.dateTime,
          ),
          builder: (_, AsyncSnapshot<Map<String, List<String>>> snapshot) {
            var widget;
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                widget = Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 48,
                );
              } else {
                Map<String, String> plan = snapshot.data
                    .map((key, value) => MapEntry(key, value.join()));
                bool isIdle = DataFactory.roomIsIdle(
                    plan, model.classTime, model.dateTime.weekday);

                widget = Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isIdle ? Colors.lightGreen : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 3),
                    Text(
                      isIdle ? '空闲' : '占用',
                      style: TextStyle(
                        color: isIdle ? Colors.lightGreen : Colors.red,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }
            } else {
              widget = Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              );
            }

            return widget;
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SRTimeModel>(
      builder:(_,model,__)=> ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.all(5),
              child: InkWell(
                onTap: (){
                  ResultEntry entry = list[index];
                  var room  = entry.room..bId = entry.building.id;
                  Navigator.of(context).pushNamed(
                    LoungeRouter.plan,
                    arguments: room,
                  );
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.white, // different
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey[100],
                          blurRadius: 3.0, //阴影模糊程度
                          spreadRadius: 3.0 //阴影扩散程度
                          )
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: _room(list[index],model),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}

class ResultAreasGridView extends StatelessWidget {
  final List<ResultEntry> list;

  const ResultAreasGridView({Key key, this.list}) : super(key: key);

  Widget _item(ResultEntry entry, BuildContext context) => Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Container(
            child: InkWell(
              onTap: () {
                print(entry.area.toJson());
                Navigator.of(context).pushNamed(
                  LoungeRouter.classrooms,
                  arguments: [
                    Area()
                      ..id = entry.area.id
                      ..building = entry.building.name
                      ..classrooms = entry.area.classrooms,
                    entry.building.id
                  ],
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  shape: BoxShape.rectangle,
                  color: colors[Random().nextInt(colors.length)],
                ),
                child: Center(
                  child: Text(
                    entry.building.name + "教",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              child: CustomPaint(
                painter: WaterMark(entry.area.id),
              ),
            ),
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      children: [
        GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 9 / 8,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) => _item(list[index], context),
        ),
      ],
    );
  }
}

const List<Color> colors = [
  Color(0xff363c54),
  Color(0xff74788a),
  Color(0xff676f96)
];

class WaterMark extends CustomPainter {
  final String letter;

  WaterMark(this.letter);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    TextPainter painter = TextPainter()
      ..textDirection = TextDirection.ltr
      ..text = TextSpan(
        text: letter,
        style: TextStyle(
          color: Color(0x25f7f7f8),
          fontWeight: FontWeight.w900,
          fontSize: 70,
        ),
      );
    painter.layout();
    LineMetrics lineMetrics = painter.computeLineMetrics()[0];
    var descent = lineMetrics.descent;
    var ascent = lineMetrics.ascent;
    var leading = lineMetrics.height - ascent - descent;
    var width = lineMetrics.width;
    painter.paint(canvas, Offset(-width, -leading - ascent));
  }
}
