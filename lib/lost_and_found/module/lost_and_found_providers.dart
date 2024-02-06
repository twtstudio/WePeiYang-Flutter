import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:we_pei_yang_flutter/lost_and_found/view/lost_and_found_notifier.dart';
import 'package:we_pei_yang_flutter/lost_and_found/view/lost_and_found_post_page.dart';
import 'package:we_pei_yang_flutter/lost_and_found/view/lost_and_found_search_notifier.dart';

List<SingleChildWidget> lostAndFoundProviders = [
  ChangeNotifierProvider.value(
    value: LAFoundModel(),
  ),
  ChangeNotifierProvider.value(
    value: LostAndFoundModel2(),
  ),
  Provider.value(value: NewLostAndFoundPostProvider()),
];
