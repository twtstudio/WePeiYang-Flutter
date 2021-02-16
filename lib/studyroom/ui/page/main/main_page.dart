import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wei_pei_yang_demo/studyroom/config/studyroom_router.dart';
import 'package:wei_pei_yang_demo/studyroom/model/building.dart';
import 'package:wei_pei_yang_demo/studyroom/model/classroom.dart';
import 'package:wei_pei_yang_demo/studyroom/model/images.dart';
import 'package:wei_pei_yang_demo/studyroom/model/search_history.dart';
import 'package:wei_pei_yang_demo/studyroom/service/time_factory.dart';
import 'package:wei_pei_yang_demo/studyroom/provider/provider_widget.dart';
import 'package:wei_pei_yang_demo/studyroom/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/studyroom/ui/page/search/search_delegate.dart';
import 'package:wei_pei_yang_demo/studyroom/ui/widget/base_page.dart';
import 'package:wei_pei_yang_demo/studyroom/ui/widget/favour_list.dart';
import 'package:wei_pei_yang_demo/studyroom/view_model/favourite_model.dart';
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
                  SRFavourWidget()
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
              arguments: Classroom(id: result.cId,name: title,bId: result.bId,aId: result.aId),
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
