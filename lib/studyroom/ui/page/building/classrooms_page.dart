import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wei_pei_yang_demo/studyroom/config/studyroom_router.dart';
import 'package:wei_pei_yang_demo/studyroom/model/area.dart';
import 'package:wei_pei_yang_demo/studyroom/model/classroom.dart';
import 'package:wei_pei_yang_demo/studyroom/model/images.dart';
import 'package:wei_pei_yang_demo/studyroom/model/search_history.dart';
import 'package:wei_pei_yang_demo/studyroom/service/time_factory.dart';
import 'package:wei_pei_yang_demo/studyroom/provider/provider_widget.dart';
import 'package:wei_pei_yang_demo/studyroom/ui/widget/base_page.dart';
import 'package:wei_pei_yang_demo/studyroom/view_model/classroom_model.dart';
import 'package:wei_pei_yang_demo/studyroom/view_model/schedule_model.dart';

class ClassroomsPage extends StatefulWidget {
  final Area area;
  final String id;

  ClassroomsPage({this.area, this.id});

  @override
  _ClassroomsPageState createState() => _ClassroomsPageState();
}

class _ClassroomsPageState extends State<ClassroomsPage> {
  Area area;
  Map<String, List<Classroom>> floors;

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<ClassroomsDataModel>(
        model: ClassroomsDataModel(
            scheduleModel: Provider.of<SRTimeModel>(context)),
        onModelReady: (model) {
          model.setBaseData(widget.area, widget.id);
          model.initData();
        },
        builder: (context, model, child) {
          area = model.area;
          floors = model.floors;
          return StudyRoomPage(
              body: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Builder(builder: (_) {
                    if (model.isBusy) {
                      return Container();
                    } else {
                      return SmartRefresher(
                        controller: model.refreshController,
                        header: ClassicHeader(),
                        onRefresh: () => model.refresh(),
                        child: ListView(
                          children: [
                            _PathTitle(),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: floors.length,
                                itemBuilder: (context, index) => FloorWidget(
                                  aId: widget.area.area_id,
                                  bId: widget.id,
                                  floor: floors.keys.toList()[index],
                                  classrooms:
                                      floors[floors.keys.toList()[index]],
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    }
                  })));
        });
  }
}

class _PathTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: Row(
        children: [
          SizedBox(width: 1),
          Image.asset(
            Images.building,
            height: 17,
          ),
          SizedBox(width: 7),
          Consumer<ClassroomsDataModel>(builder: (_, model, __) {
            final area = model.area;
            return Text(
              area.area_id != null
                  ? area.building + "教学楼" + area.area_id
                  : area.building + "教学楼",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xff62677b),
              ),
            );
          })
        ],
      ),
    );
  }
}

class FloorWidget extends StatelessWidget {
  final List<Classroom> classrooms;
  final String floor;
  final String aId;
  final String bId;

  const FloorWidget({
    this.aId,
    this.bId,
    this.floor,
    this.classrooms,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
          child: Row(
            children: [
              SizedBox(width: 1),
              Text(
                floor + "F",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff62677b),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Consumer<ClassroomsDataModel>(builder: (_, model, __) {
            Map<String, Map<String, String>> classPlan = model.classPlan;
            int currentDay = model.currentDay;
            Schedule schedule = model.schedule;
            return GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                // crossAxisSpacing: 13,
                // mainAxisSpacing: 18,
                childAspectRatio: 68 / 54,
              ),
              itemCount: classrooms.length,
              itemBuilder: (context, index) {
                // TODO: 优化逻辑
                var classroom = classrooms[index];
                print('classroom: ' + classroom.toJson().toString());
                var plan = classPlan[classroom.id];
                String current;
                String currentPlan;
                bool isIdle;
                if (plan != null) {
                  current = Time.week[currentDay - 1];
                  currentPlan = plan[current];
                  if (currentPlan != null) {
                    isIdle = Time.availableNow(currentPlan, schedule);
                  } else {
                    isIdle = false;
                  }
                } else {
                  current = null;
                  classPlan = null;
                  isIdle = false;
                }
                String title;
                if (aId == null) {
                  title = model.area.building + '教' + classroom.name;
                } else {
                  title =
                      model.area.building + '教' + aId + '区' + classroom.name;
                }

                return InkWell(
                  onTap: () {
                    print('you tap class:' +
                        SearchHistory(
                          model.area.building,
                          classroom.name,
                          aId,
                          bId,
                          classroom.id,
                          '123123',
                        ).toJson().toString());
                    Navigator.of(context).pushNamed(
                      StudyRoomRouter.plan,
                      arguments: Classroom(
                          id: classroom.id, name: title, bId: bId, aId: aId),
                    );
                  },
                  child: _RoomItem(classroom: classroom, isIdle: isIdle),
                );
              },
            );
          }),
        )
      ],
    );
  }
}

class _RoomItem extends StatelessWidget {
  const _RoomItem({
    Key key,
    @required this.classroom,
    @required this.isIdle,
  }) : super(key: key);

  final Classroom classroom;
  final bool isIdle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 7, 6, 7),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0xffe6e6e6),
              blurRadius: 7,
            )
          ],
          borderRadius: BorderRadius.circular(6),
          shape: BoxShape.rectangle,
          color: Color(0xfffcfcfa),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                classroom.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff62677b),
                  fontSize: 10,
                ),
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
