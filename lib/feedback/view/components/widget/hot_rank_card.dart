import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/view/search_result_page.dart';

/// 北洋热搜
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
    SvgPicture.asset("assets/svg_pics/lake_butt_icons/label1.svg",
        height: 18.h),
    SvgPicture.asset("assets/svg_pics/lake_butt_icons/label2.svg",
        height: 18.h),
    SvgPicture.asset("assets/svg_pics/lake_butt_icons/label3.svg",
        height: 18.h),
    SvgPicture.asset("assets/svg_pics/lake_butt_icons/label4.svg",
        height: 18.h),
    SvgPicture.asset("assets/svg_pics/lake_butt_icons/label5.svg",
        height: 18.h),
    //下面的这个是图钉
    SvgPicture.asset("assets/svg_pics/lake_butt_icons/stick_to_top.svg",
        height: 18.h),
  ];

  @override
  Widget build(BuildContext context) {
    var title = Row(children: [
      SvgPicture.asset("assets/svg_pics/lake_butt_icons/really_hot_fire.svg",
          height: 24.h),
      SizedBox(width: 4.w),
      SvgPicture.asset(
        "assets/svg_pics/lake_butt_icons/pei_yang_hot.svg",
        height: 25.h,
      )
    ]);

    return Consumer<FbHotTagsProvider>(
        builder: (_, data, __) => data.hotTagCardState == 4
            ? SizedBox(height: 14.h)
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    SizedBox(height: 8.h),
                    data.hotTagCardState == 1
                        ? Text(
                            '     loading...',
                            style: TextUtil.base.w400.NotoSansSC.sp(18).black4E,
                          )
                        : data.hotTagCardState == 2
                            ? Column(
                                children: List.generate(
                                    data.hotTagsList.length <= 5
                                        ? data.hotTagsList.length
                                        : 5,
                                    (index) => InkWell(
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
                                            padding: EdgeInsets.symmetric(
                                                vertical: 3.h),
                                            child: Row(
                                              children: [
                                                leads[index],
                                                SizedBox(width: 5),
                                                Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      data.hotTagsList[index]
                                                          .name,
                                                      style: TextUtil
                                                          .base.w400.NotoSansSC
                                                          .sp(16)
                                                          .black2A,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                    data.hotTagsList[index]
                                                            .point
                                                            .toString(),
                                                    style: TextUtil
                                                        .base.w400.NotoSansSC
                                                        .sp(14)
                                                        .black2A,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )))
                            : Text(
                                '     加载失败',
                                style:
                                    TextUtil.base.w400.NotoSansSC.sp(18).redD9,
                              ),
                  ],
                ),
              ));
  }
}
