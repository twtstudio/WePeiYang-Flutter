import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';
import 'package:provider/provider.dart';

import '../../../feedback_router.dart';
import '../../search_result_page.dart';

//北洋热搜
class ActivityCard extends StatefulWidget {
  @override
  _ActivityCardState createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  _ActivityCardState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(14, 12, 14, 2),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: InkWell(
          child: Image.asset('assets/images/lake_butt_icons/monkie.png'),
          onTap: () {
            Navigator.pushNamed(context, FeedbackRouter.haitang);
          },
        ));
  }
}
