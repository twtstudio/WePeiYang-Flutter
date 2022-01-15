import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';

List<Text> tags = List.filled(
    5,
    Text(
      "此条暂无热搜",
      style: TextUtil.base.w400.NotoSansSC.sp(14).grey97,
    ));
List<Text> hotIndex = List.filled(
    5,
    Text(
      "0",
      style: TextUtil.base.w400.NotoSansSC.sp(14).grey97,
    ));

List<Tag> tagUtil = [];

class HotCard extends StatefulWidget {
  @override
  _HotCardState createState() => _HotCardState();
}

class _HotCardState extends State<HotCard> {
  _HotCardState();

  @override
  void initState() {
    initHotRankCards();
    super.initState();
  }

  List<SvgPicture> leads = [
    SvgPicture.asset("assets/svg_pics/lake_butt_icons/label1.svg"),
    SvgPicture.asset("assets/svg_pics/lake_butt_icons/label2.svg"),
    SvgPicture.asset("assets/svg_pics/lake_butt_icons/label3.svg"),
    SvgPicture.asset("assets/svg_pics/lake_butt_icons/label4.svg"),
    SvgPicture.asset("assets/svg_pics/lake_butt_icons/label5.svg"),
  ];

  _setHotTags(List<Tag> list) {
    tagUtil = list;
    for (int total = 0; list.isNotEmpty; total++) {
      tags[total] = Text(
        tagUtil[total].name,
        style: TextUtil.base.w500.NotoSansSC.sp(14).grey6C,
      );
      hotIndex[total] = Text(
        tagUtil[total].point.toString(),
        style: TextUtil.base.w500.NotoSansSC.sp(14).black2A,
      );
    }
  }

  initHotRankCards() {
    FeedbackService.getHotTags(onResult: (list) {
      setState(() {
        _setHotTags(list);
      });
    }, onFailure: (e) {
      ToastProvider.error(e.error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    var title = Row(children: [
      SvgPicture.asset("assets/svg_pics/lake_butt_icons/really_hot_fire.svg",
          width: 22),
      SizedBox(width: 2),
      SvgPicture.asset("assets/svg_pics/lake_butt_icons/pei_yang_hot.svg",
          width: 100)
    ]);

    return InkWell(
      onTap: initHotRankCards,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Column(
          children: [
            title,
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Row(
                    children: [
                      leads[index],
                      SizedBox(width: 5),
                      tags[index],
                      Spacer(),
                      hotIndex[index]
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
