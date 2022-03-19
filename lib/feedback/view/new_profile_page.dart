import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/profile_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

import 'components/profile_header.dart';

class NewProfilePage extends StatefulWidget{
  @override
  State<NewProfilePage> createState() => NewProfilePageState();

}
var myPost = ProfileTabButton(
  text: S.current.feedback_my_post,
);

var myFavor = ProfileTabButton(
  text: S.current.feedback_my_favorite,
);

Widget tabs = Container(
  height: 36,
  child: Card(
    color: Color.fromRGBO(246, 246, 247, 1.0),
    elevation: 0,
    child: Row(
      children: [myPost, myFavor],
    ),
  ),
);
class NewProfilePageState extends State<NewProfilePage>{
  var _refreshController = RefreshController(initialRefresh: false);
  Widget appBar = SliverToBoxAdapter(
    child: ProfileHeader(
      child: SliverToBoxAdapter(
        child: tabs,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
   return SmartRefresher(controller: _refreshController,
   child: ProfileHeader(child: appBar),);
  }
}
