import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/lounge/lounge_router.dart';
import 'package:we_pei_yang_flutter/lounge/model/building.dart';
import 'package:we_pei_yang_flutter/lounge/model/classroom.dart';
import 'package:we_pei_yang_flutter/lounge/model/search_entry.dart';
import 'package:we_pei_yang_flutter/lounge/provider/provider_widget.dart';
import 'package:we_pei_yang_flutter/lounge/service/data_factory.dart';
import 'package:we_pei_yang_flutter/lounge/service/images.dart';
import 'package:we_pei_yang_flutter/lounge/ui/page/search/search_delegate.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/base_page.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/building_grid_view.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/favour_list.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/list_load_steps.dart';
import 'package:we_pei_yang_flutter/lounge/view_model/home_model.dart';
import 'package:we_pei_yang_flutter/lounge/view_model/lounge_time_model.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  LoungeTimeModel timeModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await timeModel.setTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    timeModel = Provider.of<LoungeTimeModel>(context, listen: false);
    return ProviderWidget<BuildingDataModel>(
      model: BuildingDataModel(timeModel),
      onModelReady: (homeModel) => homeModel.setBusy(),
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
                        style: FontManager.YaHeiRegular.copyWith(
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
              LoungeFavourWidget(title: S.current.myFavour)
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
              String title = DataFactory.getRoomTitle(Classroom(
                name: result.cName,
                aId: result.aId,
                bName: result.bName,
              ));
              // print('you tap class:' + result.toJson().toString());
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
                children: [Image(image: AssetImage(Images.search), width: 16)],
              ),
            ),
          ),
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
              style: FontManager.YaQiHei.copyWith(
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
            model: model,
            errorHeight: 80,
            successV: _successView(model),
            errorV: RetryWidget(),
          ),
        ),
      ),
    );
  }
}

class RetryWidget extends StatefulWidget {
  @override
  _RetryWidgetState createState() => _RetryWidgetState();
}

class _RetryWidgetState extends State<RetryWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.transparent,
      child: Center(
        child: FlatButton(
          onPressed: () {
            Provider.of<LoungeTimeModel>(context, listen: false).setTime();
          },
          color: Colors.blue,
          highlightColor: Colors.blue[700],
          colorBrightness: Brightness.dark,
          splashColor: Colors.grey,
          shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Text("重试"),
        ),
      ),
    );
  }
}
