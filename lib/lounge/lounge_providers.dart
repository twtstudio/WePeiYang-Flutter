import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'view_model/favourite_model.dart';
import 'view_model/lounge_time_model.dart';

List<SingleChildWidget> loungeProviders = [
  ChangeNotifierProvider<LoungeTimeModel>(
    create: (context) => LoungeTimeModel()..setTime(init: true),
  ),
  ChangeNotifierProvider<RoomFavouriteModel>(
      create: (context) => RoomFavouriteModel()),
];
