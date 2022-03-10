// @dart = 2.12
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/lounge/model/area.dart';
import 'package:we_pei_yang_flutter/lounge/model/classroom.dart';
import 'package:we_pei_yang_flutter/lounge/util/theme_util.dart';

import '../room_state.dart';

class RoomList extends StatelessWidget {
  final List<Classroom> rooms;
  const RoomList(
    this.rooms, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        rooms.length,
        (index) => _RoomItem(rooms[index]),
      ),
    );
  }
}

class _RoomItem extends StatelessWidget {
  final Classroom room;

  const _RoomItem(
    this.room, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = Text(
      room.aId == '-1'
          ? '${room.bName}教${room.name}'
          : '${room.bName}${room.aId}${room.name}',
      style: TextStyle(
        fontSize: 12.sp,
        color: Theme.of(context).searchResultRoomItemText,
        fontWeight: FontWeight.bold,
      ),
    );

    final idle = RoomState(room);

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [title, idle],
    );

    final decoration = BoxDecoration(
      shape: BoxShape.rectangle,
      color: Theme.of(context).searchResultRoomItemBackground, // different
      borderRadius: BorderRadius.circular(8.w),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).searchResultRoomItemShadow,
          blurRadius: 47.w, //阴影模糊程度
        )
      ],
    );

    content = Container(
      height: 33.w,
      width: 314.w,
      decoration: decoration,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: content,
        ),
      ),
    );

    content = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.w),
      child: InkWell(
        onTap: () {
          // ResultEntry entry = list[index];
          // var room = entry.room!..bId = entry.building!.id;
          // Navigator.of(context).pushNamed(
          //   LoungeRouter.plan,
          //   arguments: room,
          // );
        },
        child: content,
      ),
    );

    return content;
  }
}

class AreasGrid extends StatelessWidget {
  final List<Area> areas;
  const AreasGrid(this.areas, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gridView = GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 21.w,
        crossAxisSpacing: 21.w,
      ),
      itemCount: areas.length,
      itemBuilder: (context, index) {
        return _AreaItem(areas[index]);
      },
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: gridView,
    );
  }
}

class _AreaItem extends StatelessWidget {
  final Area area;
  const _AreaItem(
    this.area, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8.w),
      shape: BoxShape.rectangle,
      color: areaItems[Random().nextInt(areaItems.length)],
    );

    final buildingText = TextStyle(
      fontWeight: FontWeight.w800,
      color: Theme.of(context).searchResultAreaItemBuildingText,
      fontSize: 15.w,
    );

    final topText = InkWell(
      onTap: () {
        // Navigator.of(context).pushNamed(
        //   LoungeRouter.classrooms,
        //   arguments: [
        //     Area(
        //       id: entry.area!.id,
        //       building: entry.building!.name,
        //       classrooms: entry.area!.classrooms,
        //     ),
        //     entry.building!.id
        //   ],
        // );
      },
      child: DecoratedBox(
        decoration: decoration,
        child: Center(
          child: Text(
            area.building + "教",
            style: buildingText,
          ),
        ),
      ),
    );

    final waterMark = Align(
      alignment: Alignment.bottomRight,
      child: CustomPaint(
        painter: _WaterMark(area.id, context),
      ),
    );

    return Center(
      child: SizedBox(
        height: 81.w,
        width: 91.w,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [topText, waterMark],
        ),
      ),
    );
  }
}

class _WaterMark extends CustomPainter {
  final String letter;
  final BuildContext context;

  _WaterMark(this.letter, this.context);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final style = TextStyle(
      color: Theme.of(context).searchResultAreaItemWaterMark,
      fontWeight: FontWeight.w900,
      fontSize: 84,
    );

    TextPainter painter = TextPainter()
      ..textDirection = TextDirection.ltr
      ..text = TextSpan(
        text: letter,
        style: style,
      );

    painter.layout();
    LineMetrics lineMetrics = painter.computeLineMetrics()[0];
    var descent = lineMetrics.descent;
    var ascent = lineMetrics.ascent;
    var leading = lineMetrics.height - ascent - descent;
    var width = lineMetrics.width;
    painter.paint(canvas, Offset(-width, -leading - ascent));
  }
}
