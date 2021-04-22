import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/lounge/lounge_router.dart';
import 'package:wei_pei_yang_demo/lounge/model/classroom.dart';
import 'package:wei_pei_yang_demo/lounge/provider/provider_widget.dart';
import 'package:wei_pei_yang_demo/lounge/service/data_factory.dart';
import 'package:wei_pei_yang_demo/lounge/service/images.dart';
import 'package:wei_pei_yang_demo/lounge/service/time_factory.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/favourite_model.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/lounge_time_model.dart';
import 'package:wei_pei_yang_demo/home/view/wpy_page.dart';
import 'list_load_steps.dart';

class LoungeFavourWidget extends StatelessWidget {
  final String title;
  final bool init;

  const LoungeFavourWidget({Key key, this.title, this.init = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeRight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0XFF62677B)),
            ),
          ),
          FavourListWidget(init: init),
        ],
      ),
    );
  }
}

class FavourListWidget extends StatefulWidget {
  final bool init;

  const FavourListWidget({
    Key key,
    this.init,
  }) : super(key: key);

  @override
  _FavourListWidgetState createState() => _FavourListWidgetState();
}

class _FavourListWidgetState extends State<FavourListWidget> {
  WPYPageState pageState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    pageState = context.findAncestorStateOfType<WPYPageState>();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<FavouriteListModel>(
      autoDispose: false,
      model: FavouriteListModel(
        timeModel: Provider.of<LoungeTimeModel>(context, listen: false),
        favouriteModel: Provider.of<RoomFavouriteModel>(context, listen: false),
      ),
      onModelReady: widget.init == true
          ? (model) async {
              debugPrint("set can false");
              pageState.canNotGoIntoLounge.value = true;
              await model.initData();
              if (model.isIdle || model.isEmpty) {
                debugPrint("set can true");
                pageState.canNotGoIntoLounge.value = false;
              }
            }
          : null,
      builder: (_, model, __) => ListLoadSteps(
        model: model,
        emptyV: Container(
          height: 40,
          child: Container(
            child: Center(
              child: Text(
                '暂无收藏',
                style: TextStyle(color: Color(0xffcdcdd3), fontSize: 12),
              ),
            ),
          ),
        ),
        successV: Padding(
          padding: EdgeInsets.fromLTRB(22, 10, 0, 0),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: model.favourList.map(
                (classroom) {
                  // print('classroom: ' + classroom.toJson().toString());
                  var plan = model.classPlan[classroom.id];
                  if (plan != null) {
                    debugPrint(
                        '------------------------- favourite room -------------------------');
                    debugPrint(classroom.toJson().toString());
                    var current = Time.week[model.currentDay - 1];
                    var currentPlan = plan[current]?.join() ?? '';
                    var isIdle =
                        Time.availableNow(currentPlan, model.classTime);
                    return FavourListCard(
                      room: classroom,
                      available: isIdle,
                    );
                  }
                  return Container();
                },
              ).toList(),
            ),
          ),
        ),
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
                  DataFactory.getRoomTitle(room),
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
