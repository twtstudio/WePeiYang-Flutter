import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/studyroom/config/studyroom_router.dart';
import 'package:wei_pei_yang_demo/studyroom/model/classroom.dart';
import 'package:wei_pei_yang_demo/studyroom/model/images.dart';
import 'package:wei_pei_yang_demo/studyroom/provider/provider_widget.dart';
import 'package:wei_pei_yang_demo/studyroom/service/time_factory.dart';
import 'package:wei_pei_yang_demo/studyroom/view_model/favourite_model.dart';
import 'package:wei_pei_yang_demo/studyroom/view_model/schedule_model.dart';

class SRFavourWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 5, 0, 0),
              child: Text(
                '我的收藏',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0XFF62677B)),
              ),
            ),
            FavourListWidget(),
          ],
        ));
  }
}


class FavourListWidget extends StatelessWidget {
  const FavourListWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // child: Container(),
      child: ProviderWidget<FavouriteListModel>(
          model: FavouriteListModel(
            scheduleModel: Provider.of<SRTimeModel>(context),
            favouriteModel: Provider.of<SRFavouriteModel>(context),
          ),
          onModelReady: (model) => model.initData(),
          builder: (context, model, child) {
            if (model.isError && model.list.isEmpty) {
              return Container(
                child: Center(
                  child: Text('加载失败'),
                ),
              );
            }

            return Row(
              children: model.favourList.isNotEmpty
                  ? model.favourList.map((classroom) {
                print('classroom: ' + classroom.toJson().toString());
                var plan = model.classPlan[classroom.id];
                var current = Time.week[model.currentDay - 1];
                var currentPlan = plan[current].join();
                var isIdle =
                Time.availableNow(currentPlan, model.schedule);
                return FavourListCard(
                  room: classroom,
                  available: isIdle,
                );
              }).toList()
                  : [
                Container(
                  child: Center(
                    child: Text('莫得数据，速去动动你的小手手'),
                  ),
                )
              ],
            );
          }),
    );
  }
}

class FavourListCard extends StatelessWidget {
  final Classroom room;
  final bool available;

  const FavourListCard({
    this.room,
    this.available,
    Key key,
  }) : super(key: key);

  static const list = [
    Color(0xffcccccc),
    Color(0xffb6b6c0),
    Color(0xffe5ddc8),
    Color(0xffcacbd1),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
      child: InkWell(
        onTap: (){
          print('you tap class:' +
              room.name);
          Navigator.of(context).pushNamed(
            StudyRoomRouter.plan,
            arguments: room,
          );
        },
        child: SizedBox(
          width: 100,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Images.building,
                    color: list[Random().nextInt(list.length)],
                  ),
                  SizedBox(height: 6),
                  Text(
                    room.name,
                    style: TextStyle(
                      color: Color(0XFF62677B),
                      fontSize: 11,
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: available ? Colors.lightGreen : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 3),
                      Text(
                        available ? '空闲' : '占用',
                        style: TextStyle(
                          color: available ? Colors.lightGreen : Colors.red,
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
        ),
      ),
    );
  }
}