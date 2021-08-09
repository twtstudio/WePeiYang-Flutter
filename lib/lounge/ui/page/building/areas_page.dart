import 'dart:math';
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/lounge/lounge_router.dart';
import 'package:we_pei_yang_flutter/lounge/model/area.dart';
import 'package:we_pei_yang_flutter/lounge/model/building.dart';
import 'package:we_pei_yang_flutter/lounge/service/images.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/base_page.dart';

class AreasPage extends StatelessWidget {
  final Building building;

  const AreasPage({Key key, this.building}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StudyRoomPage(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Container(
              child: Row(
                children: [
                  SizedBox(width: 1),
                  Image.asset(
                    Images.building,
                    height: 17,
                  ),
                  SizedBox(width: 7),
                  Text(
                    building.name + S.current.teachingBuilding,
                    style: FontManager.Aspira.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xff62677b),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 9 / 8,
                ),
                itemCount: building.areas.values.length,
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    var area = building.areas.values.toList()[index];
                    Navigator.of(context).pushNamed(
                      LoungeRouter.classrooms,
                      arguments: [
                        Area()
                          ..id = area.id
                          ..building = area.building
                          ..classrooms = area.classrooms,
                        building.id
                      ],
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      shape: BoxShape.rectangle,
                      color: FavorColors.scheduleColor[Random().nextInt(FavorColors.scheduleColor.length)],
                    ),
                    child: Center(
                      child: Text(
                        building.areas.values.toList()[index].id +
                            S.current.area,
                        style: FontManager.Aspira.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
