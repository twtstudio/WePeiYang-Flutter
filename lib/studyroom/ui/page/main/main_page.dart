import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wei_pei_yang_demo/studyroom/config/studyroom_router.dart';
import 'package:wei_pei_yang_demo/studyroom/model/building.dart';
import 'package:wei_pei_yang_demo/studyroom/model/images.dart';
import 'package:wei_pei_yang_demo/studyroom/model/search_history.dart';
import 'package:wei_pei_yang_demo/studyroom/provider/provider_widget.dart';
import 'package:wei_pei_yang_demo/studyroom/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/studyroom/ui/page/search/search_delegate.dart';
import 'package:wei_pei_yang_demo/studyroom/ui/widget/base_page.dart';
import 'package:wei_pei_yang_demo/studyroom/view_model/home_model.dart';
import 'package:wei_pei_yang_demo/studyroom/view_model/schedule_model.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  SRTimeModel scheduleModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scheduleModel.initSchedule();
    });
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    var instance = await HiveManager.instance;
    await instance.closeBoxes();
  }

  @override
  Widget build(BuildContext context) {
    scheduleModel = Provider.of<SRTimeModel>(context);
    return ProviderWidget<BuildingDataModel>(
      model: BuildingDataModel(scheduleModel),
      onModelReady: (homeModel) {
        homeModel.initData();
      },
      builder: (context, model, child) {
        return StudyRoomPage(
          body: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: SmartRefresher(
              controller: model.refreshController,
              header: ClassicHeader(),
              onRefresh: () {
                model.refresh();
              },
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CampusChangeWidget(),
                        Builder(builder: (_) {
                          var time = model.dateTime.toString().split(' ')[0];
                          return Text(
                            time,
                            style: TextStyle(
                              color: Color(0xff62677b),
                              fontSize: 10,
                            ),
                          );
                        })
                      ],
                    ),
                  ),
                  SearchBarWidget(),
                  BuildingGridWidget(),
                  FavourListWidget()
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Builder(
        builder: (_) => InkWell(
          onTap: () async {
            var result = await showASearch<SearchHistory>(
                context: context, delegate: StudyRoomSearchDelegate());
            // Scaffold.of(context).showSnackBar(SnackBar(content: Text(result.cId)));
            String title = getTitle(result);
            print('you tap class:' + result.toJson().toString());
            Navigator.of(context).pushNamed(
              StudyRoomRouter.plan,
              arguments: [result.aId, result.bId, result.cId, title],
            );
          },
          child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                color: Color(0xffecedef),
              ),
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                child: Row(
                  children: [
                    Image(image: AssetImage(Images.search), width: 16)
                  ],
                ),
              )),
        ),
      ),
    );
  }
}

class CampusChangeWidget extends StatelessWidget {
  const CampusChangeWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image(image: AssetImage(Images.direction), width: 15),
        Consumer<BuildingDataModel>(
          builder: (_, model, __) => TextButton(
            onPressed: () => model.changeCampus(),
            child: Text(
              model.campus,
              style: TextStyle(
                  color: Color(0XFF62677B),
                  fontSize: 17,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class FavourListWidget extends StatelessWidget {
  const FavourListWidget({
    Key key,
  }) : super(key: key);

  static const list = [
    {'name': '23教 208', 'available': true},
    {'name': '26教 A208', 'available': false},
    {'name': '23教 206', 'available': true},
    {'name': '23教 209', 'available': true},
    {'name': '27教 106', 'available': false}
  ];

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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: list.map((classroom) {
                return FavourListCard(
                  name: classroom['name'],
                  available: classroom['available'],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class FavourListCard extends StatelessWidget {
  final String name;
  final bool available;

  const FavourListCard({
    this.name,
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
                  name,
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

class BuildingGridWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 40, 5, 10),
      child: Container(
        child: Consumer<BuildingDataModel>(
          builder: (_, model, __) => GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              //增加
              shrinkWrap: true,
              //增加
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, //每行三列
              ),
              itemCount: model.buildings.length,
              itemBuilder: (context, index) {
                //如果显示到最后一个并且Icon总数小于200时继续获取数据
                return InkWell(
                  onTap: () {
                    var building = model.buildings[index];
                    for (var area in building.areas.values) {
                      area.building = building.name;
                    }

                    Navigator.of(context).pushNamed(StudyRoomRouter.areas,
                        arguments: Building()
                          ..id = building.id
                          ..name = building.name
                          ..areas = building.areas
                          ..campus = building.campus);
                  },
                  child: Column(
                    children: [
                      Image.asset(Images.building),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                        child: Text(
                          model.buildings[index].name + "教",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0XFF86868F),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }
}
