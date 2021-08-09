import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/lounge/lounge_router.dart';
import 'package:we_pei_yang_flutter/lounge/model/classroom.dart';
import 'package:we_pei_yang_flutter/lounge/provider/provider_widget.dart';
import 'package:we_pei_yang_flutter/lounge/service/data_factory.dart';
import 'package:we_pei_yang_flutter/lounge/service/hive_manager.dart';
import 'package:we_pei_yang_flutter/lounge/service/images.dart';
import 'package:we_pei_yang_flutter/lounge/service/time_factory.dart';
import 'package:we_pei_yang_flutter/lounge/view_model/favourite_model.dart';
import 'package:we_pei_yang_flutter/lounge/view_model/lounge_time_model.dart';
import 'package:we_pei_yang_flutter/home/view/wpy_page.dart';
import 'list_load_steps.dart';

class LoungeFavourWidget extends StatefulWidget {
  final String title;
  final bool init;

  const LoungeFavourWidget({Key key, this.title, this.init = false})
      : super(key: key);

  @override
  _LoungeFavourWidgetState createState() => _LoungeFavourWidgetState();
}

class _LoungeFavourWidgetState extends State<LoungeFavourWidget> {
  // WPYPageState pageState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // pageState = context.findAncestorStateOfType<WPYPageState>();
  }

  @override
  Widget build(BuildContext context) => ProviderWidget(
        autoDispose: false,
        model: FavouriteListModel(
          timeModel: Provider.of<LoungeTimeModel>(context, listen: false),
          favouriteModel:
              Provider.of<RoomFavouriteModel>(context, listen: false),
        ),
        onModelReady: widget.init == true
            ? (model) async {
                // debugPrint("set can false");
                // pageState.canNotGoIntoLounge.value = true;
                await model.initData();
                // if (model.isIdle || model.isEmpty) {
                //   // debugPrint("set can true");
                //   pageState.canNotGoIntoLounge.value = false;
                // }
              }
            : null,
        builder: (_, FavouriteListModel model, __) {
          Widget body = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  widget.title,
                  style: FontManager.YaQiHei.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0XFF62677B),
                  ),
                ),
              ),
              FavourListWidget(
                model: model,
                init: widget.init,
              ),
            ],
          );

          Widget wrapper;
          if (widget.init) {
            wrapper = ValueListenableBuilder(
              valueListenable: context
                  .findAncestorStateOfType<WPYPageState>()
                  .canNotGoIntoLounge,
              builder: (_, bool absorbing, __) => GestureDetector(
                onTap: () {
                  // print("==================================================");
                  // print("==================================================");
                  // print("absorbing : $absorbing");
                  // print("==================================================");
                  // print("==================================================");
                  if (absorbing) {
                    context.findAncestorStateOfType<WPYPageState>().showToast(
                          custom: null,
                        );
                  } else {
                    Navigator.pushNamed(context, LoungeRouter.main).then((_) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        model.refresh();
                      });
                    });
                  }
                },
                behavior: HitTestBehavior.translucent,
                child: body,
              ),
            );
          }

          return MediaQuery.removePadding(
              context: context, removeRight: true, child: wrapper ?? body);
        },
      );
}

class FavourListWidget extends StatelessWidget {
  final FavouriteListModel model;
  final bool init;

  const FavourListWidget({Key key, this.model, this.init}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListLoadSteps(
      model: model,
      emptyV: Container(
        height: 60,
        child: Container(
          child: Center(
            child: Text(
              // init ? '没有数据，请至顶栏自习室模块添加收藏' : '暂无收藏',
              S.current.notHaveLoungeFavour,
              style: FontManager.YaQiHei.copyWith(color: Color(0xffcdcdd3), fontSize: 12),
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
                  // debugPrint(
                  //     '------------------------- favourite room -------------------------');
                  // debugPrint(classroom.toJson().toString());
                  var current = Time.week[model.currentDay - 1];
                  var currentPlan = plan[current]?.join() ?? '';
                  var isIdle = Time.availableNow(currentPlan, model.classTime);
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
      errorV: Container(
        height: 60,
        child: Container(
          child: Center(
            child: Text(
              // init ? '没有数据，请至顶栏自习室模块添加收藏' : '暂无收藏',
              "未获取到数据",
              style: FontManager.YaQiHei.copyWith(color: Color(0xffcdcdd3), fontSize: 12),
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
          // print('you tap class:' + room.name);
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
                  style: FontManager.YaQiHei.copyWith(
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
                      available ? S.current.idle : S.current.occupy,
                      style: FontManager.YaQiHei.copyWith(
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
