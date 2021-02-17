import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/studyroom/config/studyroom_router.dart';
import 'package:wei_pei_yang_demo/studyroom/model/area.dart';
import 'package:wei_pei_yang_demo/studyroom/model/building.dart';
import 'package:wei_pei_yang_demo/studyroom/model/images.dart';
import 'package:wei_pei_yang_demo/studyroom/ui/widget/base_page.dart';


class AreasPage extends StatefulWidget {
  final Building building;

  const AreasPage({Key key, this.building}) : super(key: key);

  @override
  _AreasPageState createState() => _AreasPageState();
}

class _AreasPageState extends State<AreasPage> {
  List<Color> colors = [
    Color(0xff363c54),
    Color(0xff74788a),
    Color(0xff676f96)
  ];

  @override
  Widget build(BuildContext context) {
    return StudyRoomPage(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
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
                    widget.building.name + "教学楼",
                    style: TextStyle(
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
                itemCount: widget.building.areas.values.length,
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    var area = widget.building.areas.values.toList()[index];
                    Navigator.of(context).pushNamed(
                      StudyRoomRouter.classrooms,
                      arguments: [
                        Area()
                          ..area_id = area.area_id
                          ..building = area.building
                          ..classrooms = area.classrooms,
                        widget.building.id
                      ],
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      shape: BoxShape.rectangle,
                      color: colors[Random().nextInt(colors.length)],
                    ),
                    child: Center(
                      child: Text(
                        widget.building.areas.values.toList()[index].area_id + "区",
                        style: TextStyle(
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
