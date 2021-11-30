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
              SizedBox(height: 5),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 26),
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
                          fontSize: 13,
                        ),
                      );
                    })
                  ],
                ),
              ),
              SizedBox(height: 5),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
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
            padding: EdgeInsets.only(left: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              shape: BoxShape.rectangle,
              color: Color(0xffecedef),
            ),
            child: Image(image: AssetImage(Images.search), width: 16,alignment: Alignment.centerLeft,),
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
      padding: const EdgeInsets.fromLTRB(15, 25, 15, 10),
      child: Consumer<BuildingDataModel>(
        builder: (_, model, __) => ListLoadSteps(
          model: model,
          errorHeight: 80,
          emptyV: SizedBox(
            height: 60,
            child: Center(
              child: Text(
                //S.current.notHaveLounge,
                "暂无自习室在线数据，请连接网络",
                style: FontManager.YaHeiLight.copyWith(
                    color: Color(0xffcdcdd3), fontSize: 14),
              ),
            ),
          ),
          successV: _successView(model),
          errorV: RetryWidget(),
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
    return SizedBox(
      height: 80,
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            Provider.of<LoungeTimeModel>(context, listen: false).setTime();
          },
          child: Text("重试"),
          style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20))),
            elevation: MaterialStateProperty.all(0),
            overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.pressed)) return Colors.grey;
              return Colors.blue;
            }),
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (states) {
                // 采用这种和overlayColor 效果于原来splashColor稍微有点点区别
                if (states.contains(MaterialState.pressed))
                  return Color(0xFF1976D2);
                return Colors.blue; // 默认的背景颜色.
              },
            ),
          ),
        ),
      ),
    );
  }
}
