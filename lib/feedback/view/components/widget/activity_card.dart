import 'dart:core';
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import '../../../feedback_router.dart';

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
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, FeedbackRouter.haitang);
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(14, 12, 14, 2),
        child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            child: Stack(
              children: [
                Image.asset(
                    'assets/images/lake_butt_icons/haitang_banner.png',
                    fit: BoxFit.fitWidth),
                Positioned(bottom: 4, right: 8, child: TextPod('海棠节·活动')),
              ],
            )),
      ),
    );
  }
}
