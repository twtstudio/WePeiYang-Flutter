import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/lounge/lounge_router.dart';
import 'package:wei_pei_yang_demo/lounge/model/building.dart';
import 'package:wei_pei_yang_demo/lounge/model/classroom.dart';
import 'package:wei_pei_yang_demo/lounge/service/data_factory.dart';
import 'package:wei_pei_yang_demo/lounge/service/images.dart';
import 'package:wei_pei_yang_demo/lounge/model/search_entry.dart';
import 'package:wei_pei_yang_demo/lounge/provider/provider_widget.dart';
import 'package:wei_pei_yang_demo/lounge/ui/page/search/search_delegate.dart';
import 'package:wei_pei_yang_demo/lounge/ui/widget/base_page.dart';
import 'package:wei_pei_yang_demo/lounge/ui/widget/building_grid_view.dart';
import 'package:wei_pei_yang_demo/lounge/ui/widget/favour_list.dart';
import 'package:wei_pei_yang_demo/lounge/ui/widget/list_load_steps.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/home_model.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/sr_time_model.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderWidget<BuildingDataModel>(
      model:
          BuildingDataModel(Provider.of<SRTimeModel>(context, listen: false)),
      onModelReady: (homeModel) {
        homeModel.initData();
      },
      builder: (_, model, __) {
        return StudyRoomPage(
          body: ListView(
            physics: BouncingScrollPhysics(),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
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
              SRFavourWidget(title: '我的收藏')
            ],
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
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Builder(
        builder: (_) => InkWell(
          onTap: () async {
            var result = await customShowSearch<HistoryEntry>(
                context: context, delegate: SRSearchDelegate());
            // Scaffold.of(context).showSnackBar(SnackBar(content: Text(result.cId)));
            if (result != null) {
              String title = DataFactory.getTitle(result);
              print('you tap class:' + result.toJson().toString());
              Navigator.of(context).pushNamed(
                LoungeRouter.plan,
                arguments: Classroom(
                    id: result.cId,
                    name: title,
                    bId: result.bId,
                    aId: result.aId),
              );
            }
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
              model.campus.name,
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
  Widget _successView(BuildingDataModel model) =>
      BuildingGridView(list: model.list.cast<Building>());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 40, 15, 10),
      child: Container(
        child: Consumer<BuildingDataModel>(
            builder: (_, model, __) => ListLoadSteps(
                  errorHeight: 80,
                  model: model,
                  successV: _successView(model),
                )),
      ),
    );
  }
}
