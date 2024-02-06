import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/type_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/home/view/lost_and_found_home_page.dart';
import 'package:we_pei_yang_flutter/lost_and_found/lost_and_found_router.dart';
import 'package:we_pei_yang_flutter/lost_and_found/network/lost_and_found_post.dart';
import 'package:we_pei_yang_flutter/lost_and_found/view/lost_and_found_search_notifier.dart';

import 'lost_and_found_notifier.dart';

class LostAndFoundSearchResultPage extends StatefulWidget {
  final LostAndFoundSearchResultPageArgs args;

  LostAndFoundSearchResultPage(this.args);

  @override
  _LostAndFoundSearchResultPageState createState() =>
      _LostAndFoundSearchResultPageState(
          args.type, args.category, args.keyword);
}

class LostAndFoundSearchResultPageArgs {
  final String type;
  final String category;
  final String keyword;

  LostAndFoundSearchResultPageArgs(this.type, this.category, this.keyword);
}

class _LostAndFoundSearchResultPageState
    extends State<LostAndFoundSearchResultPage> {
  final String type;
  final String category;
  final String keyword;
  final ScrollController _scrollController = ScrollController();

  _LostAndFoundSearchResultPageState(this.type, this.category, this.keyword);

  void _onRefresh() async {
    context.read<LostAndFoundModel2>().clearByType(type);
    await context.read<LostAndFoundModel2>().getNext(
          type: type,
          category: category,
          keyword: keyword,
          success: () {
            context.read<LostAndFoundModel2>().lafSubStatus[type] =
                LAFSubStatus.ready;
            context
                .read<LostAndFoundModel2>()
                .refreshController[type]
                ?.refreshCompleted();
          },
          failure: (e) {
            context.read<LostAndFoundModel2>().lafSubStatus[type] =
                LAFSubStatus.error;
            context
                .read<LostAndFoundModel2>()
                .refreshController[type]
                ?.refreshFailed();
            ToastProvider.error(e.error.toString());
          },
        );
  }

  void _onLoading() async {
    await context.read<LostAndFoundModel2>().getNext(
          type: type,
          category: category,
          keyword: keyword,
          success: () {
            context.read<LostAndFoundModel2>().lafSubStatus[type] =
                LAFSubStatus.ready;
            context
                .read<LostAndFoundModel2>()
                .refreshController[type]
                ?.loadComplete();
          },
          failure: (e) {
            context.read<LostAndFoundModel2>().lafSubStatus[type] =
                LAFSubStatus.error;
            context
                .read<LostAndFoundModel2>()
                .refreshController[type]
                ?.loadFailed();
            ToastProvider.error(e.error.toString());
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    if (context.read<LostAndFoundModel2>().lafSubStatus[type] ==
            LAFSubStatus.ready &&
        context.read<LostAndFoundModel2>().lafSubStatus[category] !=
            LAFSubStatus.ready) {
      _onRefresh();
    }

    var appBar = LostAndFoundAppBar(
      height: 100,
      leading: Padding(
        padding: EdgeInsetsDirectional.only(start: 8.w, bottom: 8.h),
        child: WButton(
          child: WpyPic(
            'assets/svg_pics/laf_butt_icons/back.svg',
            width: 28.w,
            height: 28.w,
          ),
          onPressed: () => Navigator.pop(context),

          ///to do
        ),
      ),
      action: Padding(
        padding: EdgeInsetsDirectional.only(end: 20.w, bottom: 12.h),
      ),
      title: Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Text(
          '搜索结果',
          style: TextUtil.base.reverse(context).NotoSansSC.w400.sp(20),
        ),
      ),
    );

    //用于计算时间差
    String _timeAgo(String dateTimeStr) {
      final year = int.parse(dateTimeStr.substring(0, 4));
      final month = int.parse(dateTimeStr.substring(4, 6));
      final day = int.parse(dateTimeStr.substring(6, 8));
      final hour = int.parse(dateTimeStr.substring(8, 10));
      final minute = int.parse(dateTimeStr.substring(10, 12));
      final second = int.parse(dateTimeStr.substring(12, 14));

      final dateTime = DateTime(year, month, day, hour, minute, second);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} 天前发布';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} 小时前发布';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} 分钟前发布';
      } else {
        if (difference.inSeconds < 0) {
          return '刚刚发布';
        } else
          return '${difference.inSeconds} 秒前发布';
      }
    }

    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        appBar,
        SizedBox(
          height: 7.h,
        ),
        Expanded(
          child: Container(
            padding: EdgeInsetsDirectional.only(start: 12.w, end: 12.w),
            child: Selector<LostAndFoundModel2, List<LostAndFoundPost>>(
                selector: (context, model) {
              return model
                  .postList[context.read<LostAndFoundModel2>().currentType]!
                  .toList();
            }, builder: (context, postList, _) {
              return SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                header: ClassicHeader(
                  idleText: '下拉以刷新 (乀*･ω･)乀',
                  releaseText: '下拉以刷新',
                  refreshingText: "正在刷新喵",
                  completeText: '刷新完成 (ﾉ*･ω･)ﾉ',
                  failedText: '刷新失败（；´д｀）ゞ',
                ),
                controller:
                    context.read<LostAndFoundModel2>().refreshController[
                        context.read<LostAndFoundModel2>().currentType]!,
                footer: ClassicFooter(
                  idleText: '下拉以刷新',
                  noDataText: '无数据',
                  loadingText: '加载中，请稍等  ;P',
                  failedText: '加载失败（；´д｀）ゞ',
                ),
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: StaggeredGridView.countBuilder(
                  controller: _scrollController,
                  crossAxisCount: 2,
                  itemCount: postList.length,
                  itemBuilder: (BuildContext context, int index) => InkWell(
                      onTap: () {
                        Tuple2 tuple2 = Tuple2(false, postList[index].id);
                        Navigator.pushNamed(context, LAFRouter.lafDetailPage,
                            arguments: tuple2);
                      },
                      child: Card(
                        elevation: 3,
                        shadowColor: ColorUtil.greyB4AFColor.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: const BorderSide(
                              color: Colors.transparent, width: 0.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            postList[index].coverPhotoPath == null
                                ? SizedBox(
                                    width: double.infinity,
                                    child: Card(
                                      child: Padding(
                                        // 添加Padding组件
                                        padding: EdgeInsets.all(
                                            10.r), // 设置所有方向的内边距为15个像素
                                        child: Text(postList[index].text,
                                            style: TextUtil.base.w400
                                                .infoText(context)
                                                .sp(14)
                                                .h(1.1)
                                                .NotoSansSC
                                                .copyWith(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )),
                                      ),
                                      elevation: 0,
                                      color: Color(0xfff8f8f8),
                                    ))
                                : Container(
                                    padding: EdgeInsetsDirectional.only(
                                        start: 11.w,
                                        end: 11.w,
                                        bottom: 7.h,
                                        top: 7.h),
                                    child: LayoutBuilder(
                                      builder: (context, constrains) {
                                        final maxWidth =
                                            constrains.constrainWidth();
                                        final width = postList[index]
                                                .coverPhotoSize
                                                ?.width
                                                .toDouble() ??
                                            1;
                                        final height = postList[index]
                                                .coverPhotoSize
                                                ?.height
                                                .toDouble() ??
                                            0;
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              10.0.r), // 设置圆角半径为10.0
                                          child: Container(
                                            width: maxWidth,
                                            child: WpyPic(
                                              postList[index].coverPhotoPath!,
                                              withHolder: true,
                                              holderHeight:
                                                  height * maxWidth / width,
                                              fit: BoxFit.fitWidth,
                                            ),
                                            height: height >= 3 * width
                                                ? 3 * maxWidth
                                                : height * maxWidth / width,
                                          ),
                                        );
                                      },
                                    )),
                            Padding(
                              padding: EdgeInsetsDirectional.only(
                                  start: 12.w, end: 12.w),
                              child: Text(
                                postList[index].title,
                                style: TextUtil.base.w600
                                    .label(context)
                                    .sp(15)
                                    .NotoSansSC,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.only(
                                  start: 12.w,
                                  end: 25.w,
                                  bottom: 18.h,
                                  top: 10.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    _timeAgo(
                                        postList[index].detailedUploadTime),
                                    style: TextUtil.base.w400
                                        .infoText(context)
                                        .sp(10)
                                        .NotoSansSC,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      SvgPicture.asset(
                                          'assets/svg_pics/icon_flame.svg',
                                          width: 16.0.w,
                                          height: 16.0.h),
                                      Text(
                                        '${postList[index].hot.toString()}',
                                        style: TextUtil.base.infoText(context),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  staggeredTileBuilder: (int index) =>
                      const StaggeredTile.fit(1),
                ),
              );
            }),
          ),
        )
      ],
    ));
  }
}
