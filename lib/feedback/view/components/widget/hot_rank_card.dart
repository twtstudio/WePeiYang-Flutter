import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
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
        width: 16, color: Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    var title = Row(children: [
      SvgPicture.asset("assets/svg_pics/lake_butt_icons/really_hot_fire.svg",
          width: 22),
      SizedBox(width: 3),
      SvgPicture.asset("assets/svg_pics/lake_butt_icons/pei_yang_hot.svg",
          width: 95)
    ]);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16, 16, 16, 2),
      padding: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          SizedBox(height: 8),
          ///定时发布年度总结
          if (DateTime.now().isAfter(DateTime(2022, 3, 25)))
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, FeedbackRouter.summary);
              },
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: leads[5],
                    ),
                    SizedBox(width: 5),
                    Text(
                      '点击查看年度总结',
                      style: TextUtil.base.w400.NotoSansSC.sp(16).black2A,
                    ),
                  ],
                ),
              ),
            ),
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
                              S.current.feedback_search_result,
                              0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Row(
                            children: [
                              leads[index],
                              SizedBox(width: 5),
                              Center(
                                  child: Text(
                                data.hotTagsList[index].name,
                                style: TextUtil.base.w400.NotoSansSC
                                    .sp(16)
                                    .black2A,
                              )),
                              Spacer(),
                              Text(
                                data.hotTagsList[index].point.toString() ?? '0',
                                style: TextUtil.base.w400.NotoSansSC
                                    .sp(14)
                                    .black2A,
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Text(
                    '     loading...',
                    style: TextUtil.base.w400.NotoSansSC.sp(16).black2A,
                  ),
          ),
        ],
      ),
    );
  }
}
