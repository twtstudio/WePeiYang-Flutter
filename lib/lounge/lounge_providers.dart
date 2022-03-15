// @dart = 2.12

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:we_pei_yang_flutter/lounge/provider/building_data_provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/config_provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/room_favor_provider.dart';
import 'package:we_pei_yang_flutter/lounge/util/time_util.dart';

List<SingleChildWidget> loungeProviders = [
  // 需要按照如下顺序排列！
  ChangeNotifierProvider(create: (_) => LoungeConfig()),
  ChangeNotifierProvider(create: (_) => RoomFavour()),
  ChangeNotifierProxyProvider<LoungeConfig, BuildingData>(
    create: (context) => BuildingData(context),
    update: (context, config, data) {
      // 每次更改完时间后，就会重新请求数据
      if (data == null) {
        return BuildingData(context);
      }
      final updateTime = data.updateTime;
      final currentTime = config.dateTime;
      final isSameWeek = updateTime?.isTheSameWeek(currentTime);

      if (isSameWeek == null || !isSameWeek) {
        data.getDataOfWeek();
      }
      return data;
    },
  ),
];
