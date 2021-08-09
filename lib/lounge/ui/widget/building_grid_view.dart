import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/lounge/lounge_router.dart';
import 'package:we_pei_yang_flutter/lounge/model/building.dart';
import 'package:we_pei_yang_flutter/lounge/service/images.dart';

class BuildingGridView extends StatelessWidget {
  final List<Building> list;

  const BuildingGridView({
    Key key,
    this.list,
  }) : super(key: key);

  Widget _item(Building building) => Column(
        children: [
          Image.asset(Images.building),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
            child: Text(
              building.name + "教",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0XFF86868F),
              ),
            ),
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, //每行三列
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Building building = list[index];
              for (var area in building.areas.values) {
                area.building = building.name;
              }

              Navigator.of(context).pushNamed(LoungeRouter.areas,
                  arguments: Building()
                    ..id = building.id
                    ..name = building.name
                    ..areas = building.areas
                    ..campus = building.campus);
            },
            child: _item(list[index]),
          );
        });
  }
}
