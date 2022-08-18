// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/lounge/lounge_router.dart';
import 'package:we_pei_yang_flutter/lounge/model/classroom.dart';
import 'package:we_pei_yang_flutter/lounge/provider/load_state_notifier.dart';
import 'package:we_pei_yang_flutter/lounge/provider/room_favor_provider.dart';
import 'package:we_pei_yang_flutter/lounge/util/data_util.dart';
import 'package:we_pei_yang_flutter/lounge/util/image_util.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/room_state.dart';

class LoungeFavorList extends StatefulWidget {
  final String title;

  const LoungeFavorList(
    this.title, {
    Key? key,
  }) : super(key: key);

  @override
  _LoungeFavorListState createState() => _LoungeFavorListState();
}

class _LoungeFavorListState extends State<LoungeFavorList> {
  @override
  Widget build(BuildContext context) {
    final title = Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.w),
      child: Text(
        widget.title,
        style: TextUtil.base.PingFangSC.black2A.bold.sp(14),
      ),
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.w),
        Row(children: [title]),
        const _FavourWidget(),
      ],
    );

    return body;
  }
}

class _FavourWidget extends LoadStateListener<RoomFavour> {
  const _FavourWidget({Key? key}) : super(key: key);

  @override
  Widget init(BuildContext context, _) {
    return SizedBox(
      height: 149.w,
      child: const Center(child: Loading()),
    );
  }

  @override
  Widget refresh(BuildContext context, _) {
    return SizedBox(
      height: 149.w,
      child: const Center(child: Loading()),
    );
  }

  @override
  Widget success(BuildContext context, RoomFavour data) {
    late Widget body;
    context.select((RoomFavour data) => data.favourList.length);
    final favours = context.read<RoomFavour>().favourList.values;
    if (data.favourList.isEmpty) {
      body = SizedBox(
        height: 80.w,
        child: MediaQuery.removePadding(
          context: context,
          removeLeft: true,
          child: Center(
            child: Text('暂无收藏', style: TextUtil.base.greyAA.sp(14)),
          ),
        ),
      );
    } else {
      body = _FavorList(favours);
    }

    return body;
  }

  @override
  Widget error(BuildContext context, RoomFavour data) {
    late Widget body;
    context.select((RoomFavour data) => data.favourList.length);
    final favours = context.read<RoomFavour>().favourList.values;
    if (data.favourList.isEmpty) {
      body = SizedBox(
        height: 80.w,
        child: MediaQuery.removePadding(
          context: context,
          removeLeft: true,
          child: Center(
            child: Text('同步数据失败', style: TextUtil.base.greyB2.sp(14)),
          ),
        ),
      );
    } else {
      body = _FavorList(favours);
    }

    return body;
  }
}

/// 收藏列表
class _FavorList extends StatelessWidget {
  final Iterable<Classroom> favours;

  const _FavorList(this.favours, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Widget body = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: favours.map((classroom) => _FavourListCard(classroom)).toList(),
    );

    body = Padding(
      padding: EdgeInsets.fromLTRB(0, 12.w, 0, 0),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: body,
      ),
    );

    return body;
  }
}

/// 收藏列表的每一个item
class _FavourListCard extends StatelessWidget {
  final Classroom room;

  const _FavourListCard(
    this.room, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roomState = RoomState(room);

    Widget itemContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          Images.collectedBuilding,
          height: 62.w,
        ),
        Text(
          DataFactory.getRoomTitle(room),
          style: TextUtil.base.Swis.w400.orange6B.sp(10),
        ),
        SizedBox(height: 9.w),
        roomState,
      ],
    );

    itemContent = Container(
      width: 70.w,
      alignment: Alignment.center,
      child: itemContent,
    );

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          LoungeRouter.plan,
          arguments: room,
        );
      },
      child: itemContent,
    );
  }
}
