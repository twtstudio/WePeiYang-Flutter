import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';
import 'package:provider/provider.dart';

import '../../../feedback_router.dart';
import '../../search_result_page.dart';

//北洋热搜
class HotCard extends StatefulWidget {
  @override
  _HotCardState createState() => _HotCardState();
}

class _HotCardState extends State<HotCard> {
  _HotCardState();

  @override
  void initState() {
    super.initState();
  }

  List<SvgPicture> leads = [
    SvgPicture.asset("assets/svg_pics/lake_butt_icons/label1.svg", width: 16),
    SvgPicture.asset("assets/svg_pics/lake_butt_icons/label2.svg", width: 16),
    SvgPicture.asset("assets/svg_pics/lake_butt_icons/label3.svg", width: 16),
    SvgPicture.asset("assets/svg_pics/lake_butt_icons/label4.svg", width: 16),
    SvgPicture.asset("assets/svg_pics/lake_butt_icons/label5.svg", width: 16),
    //下面的这个是图钉
    SvgPicture.asset("assets/svg_pics/lake_butt_icons/stick_to_top.svg",
        width: 16),
  ];

  @override
  Widget build(BuildContext context) {
    var title = Row(children: [
      SvgPicture.asset("assets/svg_pics/lake_butt_icons/really_hot_fire.svg",
          width: 24),
      SizedBox(width: 3),
      SvgPicture.asset("assets/svg_pics/lake_butt_icons/pei_yang_hot.svg",
          width: 94)
    ]);

    return Container(
      // margin: EdgeInsets.fromLTRB(14, 16, 14, 2),
      // decoration: BoxDecoration(
      //     color: Colors.black12,
      //     borderRadius: BorderRadius.all(Radius.circular(16)),
      //     image: DecorationImage(
      //         alignment: Alignment.centerRight,
      //         image: NetworkImage(
      //             'https://qnhdpic.twt.edu.cn/download/origin/792172dd53ac79bda86a2859a912cde0.jpeg'),
      //         fit: BoxFit.contain)),
      // child: Container(
        margin: EdgeInsets.fromLTRB(14, 12, 14, 2),
        //width: WePeiYangApp.screenWidth * 0.52,
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title,
            SizedBox(height: 8),
            Consumer<FbHotTagsProvider>(
              builder: (_, data, __) => data.hotTagsList.length > 0
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: data.hotTagsList.length <= 5
                          ? data.hotTagsList.length
                          : 5,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => Navigator.pushNamed(
                            context,
                            FeedbackRouter.searchResult,
                            arguments: SearchResultPageArgs(
                                '',
                                '${data.hotTagsList[index].tagId}',
                                '',
                                '热搜：${data.hotTagsList[index].name}\n点击标签参加话题讨论',
                                0,
                                0),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                leads[index],
                                SizedBox(width: 5),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      data.hotTagsList[index].name,
                                      style: TextUtil.base.w400.NotoSansSC
                                          .sp(16)
                                          .black2A,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    data.hotTagsList[index].point
                                            .toString() ??
                                        '0',
                                    style: TextUtil.base.w400.NotoSansSC
                                        .sp(14)
                                        .black2A,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Text(
                      '     loading...',
                      style: TextUtil.base.w400.NotoSansSC.sp(18).black2A,
                    ),
            ),
          ],
        ),
      //),
    );
  }
}
