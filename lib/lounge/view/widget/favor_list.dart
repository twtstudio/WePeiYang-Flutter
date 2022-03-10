// @dart = 2.12
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/room_favor_provider.dart';
import 'package:we_pei_yang_flutter/lounge/model/classroom.dart';
import 'package:we_pei_yang_flutter/lounge/util/data_util.dart';
import 'package:we_pei_yang_flutter/lounge/util/image_util.dart';
import 'package:we_pei_yang_flutter/lounge/lounge_router.dart';
import 'package:we_pei_yang_flutter/lounge/util/theme_util.dart';
import 'package:we_pei_yang_flutter/lounge/util/time_util.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/room_state.dart';

import '../../../commons/widgets/loading.dart';

class LoungeFavorList extends StatefulWidget {
  final String title;

  const LoungeFavorList(this.title, {Key? key}) : super(key: key);

  @override
  _LoungeFavorListState createState() => _LoungeFavorListState();
}

class _LoungeFavorListState extends State<LoungeFavorList> {
  @override
  Widget build(BuildContext context) {
    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24.w,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 7.w),
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).favorListTitle,
            ),
          ),
        ),
        const FavourListWidget(),
      ],
    );

    return body;
  }
}

class FavourListWidget extends StatelessWidget {
  const FavourListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<RoomFavorProvider>();

    late Widget body;

    if (model.success) {
      if (model.favourList.isEmpty) {
        body = SizedBox(
          height: 60.w,
          child: const Center(
            child: Text(
                // init ? '没有数据，请至顶栏自习室模块添加收藏' : '暂无收藏',
                '没有数据'
                // S.current.notHaveLoungeFavour,
                // style: FontManager.YaHeiLight.copyWith(
                //     color: Color(0xffcdcdd3), fontSize: 14),
                ),
          ),
        );
      } else {
        body = Padding(
          padding: EdgeInsets.fromLTRB(0, 12.w, 0, 0),
          child: const SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: _FavorList(),
          ),
        );
      }
    } else {
      final height = MediaQuery.of(context).size.height / 3;
      body = SizedBox(
        height: height,
        child: const Center(
          child: Loading(),
        ),
      );
    }

    return body;
  }
}

class _FavorList extends StatelessWidget {
  const _FavorList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<RoomFavorProvider>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: model.favourList.values.map(
        (classroom) {
          var plan = model.classPlan[classroom.id];
          if (plan != null) {
            var currentPlan = plan[4]?.join() ?? '';
            var isIdle = Time.availableNow(currentPlan, []);
            return FavourListCard(classroom, isIdle);
          }
          return Container();
        },
      ).toList(),
    );
  }
}

class FavourListCard extends StatelessWidget {
  final Classroom room;
  final bool avaliable;

  const FavourListCard(
    this.room,
    this.avaliable, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roomState = RoomState(room);
    final iconColors = Theme.of(context).favorRoomIconColors;
    final color = iconColors[Random().nextInt(iconColors.length)];

    Widget itemContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          Images.building,
          height: 24.w,
          color: color,
        ),
        SizedBox(height: 12.w),
        Text(
          DataFactory.getRoomTitle(room),
          style: TextStyle(
            color: Theme.of(context).favorListTitle,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 9.w),
        roomState,
      ],
    );

    debugPrint(DataFactory.getRoomTitle(room));

    itemContent = Container(
      width: 82.w,
      height: 120.w,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).favorRoomItemShadow,
            blurRadius: 47.w,
          )
        ],
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.w),
        color: Theme.of(context).favorCardBackground,
      ),
      alignment: Alignment.center,
      child: itemContent,
    );

    return Padding(
      padding: EdgeInsets.all(8.5.w),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            LoungeRouter.plan,
            arguments: room,
          );
        },
        child: itemContent,
      ),
    );
  }
}
