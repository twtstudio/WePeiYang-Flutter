import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/lounge/lounge_router.dart';
import 'package:wei_pei_yang_demo/lounge/model/classroom.dart';
import 'package:wei_pei_yang_demo/lounge/provider/provider_widget.dart';
import 'package:wei_pei_yang_demo/lounge/service/images.dart';
import 'package:wei_pei_yang_demo/lounge/service/time_factory.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/favourite_model.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/lounge_time_model.dart';
import 'list_load_steps.dart';

class LoungeFavourWidget extends StatelessWidget {
  final String title;

  const LoungeFavourWidget({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
        context: context,
        removeRight: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                title,
                style: TextStyle(
                    fontSize: 17,
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
    return Padding(
      padding: EdgeInsets.fromLTRB(22, 10, 0, 0),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: ProviderWidget<FavouriteListModel>(
            model: FavouriteListModel(
              timeModel: Provider.of<LoungeTimeModel>(context, listen: false),
              favouriteModel:
                  Provider.of<RoomFavouriteModel>(context, listen: false),
            ),
            onModelReady: (model) => model.initData(),
            builder: (_, model, __) => ListLoadSteps(
                  model: model,
                  emptyV: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width - 20,
                    child: Row(children: [
                      Expanded(
                        child: Container(
                          child: Center(
                            child: Text('自习室收藏存储在本地'
                            ,style: TextStyle(
                                color: Color(0xffcdcdd3),
                                fontSize: 12
                              ),),
                          ),
                        ),
                      ),
                      Container(
                        width: 20,
                      ),
                    ]),
                  ),
                  successV: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: model.favourList.isNotEmpty
                        ? model.favourList.map((classroom) {
                            // print('classroom: ' + classroom.toJson().toString());
                            var plan = model.classPlan[classroom.id];
                            var current = Time.week[model.currentDay - 1];
                            var currentPlan = plan[current].join();
                            var isIdle =
                                Time.availableNow(currentPlan, model.classTime);
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
                  ),
                )),
      ),
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
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          print('you tap class:' + room.name);
          Navigator.of(context).pushNamed(
            LoungeRouter.plan,
            arguments: room,
          );
        },
        child: Container(
          width: 87,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[100],
                    blurRadius: 5.0, //阴影模糊程度
                    spreadRadius: 5.0 //阴影扩散程度
                    )
              ],
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
              color: Colors.white),
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
    );
  }
}
