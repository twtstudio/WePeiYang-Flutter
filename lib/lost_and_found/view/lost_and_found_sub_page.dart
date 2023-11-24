import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:we_pei_yang_flutter/commons/util/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/type_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';
import 'package:we_pei_yang_flutter/lost_and_found/lost_and_found_router.dart';
import 'package:we_pei_yang_flutter/lost_and_found/network/lost_and_found_post.dart';
import 'package:we_pei_yang_flutter/lost_and_found/view/lost_and_found_notifier.dart';
import 'package:we_pei_yang_flutter/lost_and_found/view/lost_and_found_search_notifier.dart';
import 'package:we_pei_yang_flutter/main.dart';

class LostAndFoundSubPage extends StatefulWidget {
  final String type;
  final bool findOwner;

  const LostAndFoundSubPage(
      {Key? key, required this.type, required this.findOwner})
      : super(key: key);

  @override
  LostAndFoundSubPageState createState() => LostAndFoundSubPageState();
}

class LostAndFoundSubPageState extends State<LostAndFoundSubPage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  void _onRefresh() async {
    context.read<LostAndFoundModel>().clearByType(widget.type);
    await context.read<LostAndFoundModel>().getNext(
          type: widget.type,
          success: () {
            context
                    .read<LostAndFoundModel>()
                    .lostAndFoundSubPageStatus[widget.type] =
                LostAndFoundSubPageStatus.ready;
            context
                .read<LostAndFoundModel>()
                .refreshController[widget.type]
                ?.refreshCompleted();
          },
          failure: (e) {
            context
                    .read<LostAndFoundModel>()
                    .lostAndFoundSubPageStatus[widget.type] =
                LostAndFoundSubPageStatus.error;
            context
                .read<LostAndFoundModel>()
                .refreshController[widget.type]
                ?.refreshFailed();
            ToastProvider.error(e.error.toString());
          },
          category:
              context.read<LostAndFoundModel>().currentCategory[widget.type]!,
        );
  }

  void _onLoading() async {
    await context.read<LostAndFoundModel>().getNext(
          type: widget.type,
          success: () {
            context
                    .read<LostAndFoundModel>()
                    .lostAndFoundSubPageStatus[widget.type] =
                LostAndFoundSubPageStatus.ready;
            context
                .read<LostAndFoundModel>()
                .refreshController[widget.type]
                ?.loadComplete();
          },
          failure: (e) {
            context
                    .read<LostAndFoundModel>()
                    .lostAndFoundSubPageStatus[widget.type] =
                LostAndFoundSubPageStatus.error;
            context
                .read<LostAndFoundModel>()
                .refreshController[widget.type]
                ?.loadFailed();
            ToastProvider.error(e.error.toString());
          },
          category:
              context.read<LostAndFoundModel>().currentCategory[widget.type]!,
        );
  }

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

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (context
                .read<LostAndFoundModel>()
                .lostAndFoundSubPageStatus[widget.type] ==
            LostAndFoundSubPageStatus.unload ||
        context
                .read<LostAndFoundModel>()
                .lostAndFoundSubPageStatus[widget.type] ==
            LostAndFoundSubPageStatus.error) _onRefresh();

    var searchBar = InkWell(
      onTap: () {
        context.read<LostAndFoundModel2>().currentType = widget.type;
        Navigator.pushNamed(context, LostAndFoundRouter.lostAndFoundSearch);
      },
      child: Container(
        height: searchBarHeight,
        decoration: BoxDecoration(
            color: ColorUtil.greyF7F8Color,
            borderRadius: BorderRadius.all(Radius.circular(45.r))),
        child: Row(children: [
          SizedBox(width: 10.w),
          Container(
            child: WpyPic(
              'assets/svg_pics/laf_butt_icons/search.svg',
              height: 18.h,
              width: 18.w,
            ),
          ),
          SizedBox(width: 5.w),
          Consumer<FbHotTagsProvider>(
              builder: (_, data, __) => Row(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: WePeiYangApp.screenWidth - 260),
                        child: Text(
                          data.recTag == null
                              ? '天大不能没有微北洋'
                              : '#${data.recTag?.name}#',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle().grey6C.NotoSansSC.w400.sp(15),
                        ),
                      ),
                    ],
                  )),
          Spacer()
        ]),
      ),
    );

    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsetsDirectional.only(
                  top: widgetPadding,
                  bottom: widgetPadding,
                  start: 15.w,
                  end: 15.w),
              child: searchBar,
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(bottom: 5.h),
              child: Selector<LostAndFoundModel, String>(
                selector: (context, model) {
                  return model.currentCategory[widget.type]!;
                },
                builder: (context, category, _) {
                  return Flex(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsetsDirectional.only(start: 15.w, end: 7.w),
                          child: LostAndFoundTag(
                              category: '全部', type: widget.type),
                        ),
                        flex: 4,
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsetsDirectional.only(start: 7.w, end: 7.w),
                          child: LostAndFoundTag(
                              category: '生活日用', type: widget.type),
                        ),
                        flex: 5,
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsetsDirectional.only(start: 7.w, end: 7.w),
                          child: LostAndFoundTag(
                              category: '数码产品', type: widget.type),
                        ),
                        flex: 5,
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsetsDirectional.only(start: 7.w, end: 7.w),
                          child: LostAndFoundTag(
                              category: '钱包卡证', type: widget.type),
                        ),
                        flex: 5,
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsetsDirectional.only(start: 7.w, end: 15.w),
                          child: LostAndFoundTag(
                              category: '其他', type: widget.type),
                        ),
                        flex: 4,
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsetsDirectional.only(start: 12.w, end: 12.w),
                child: Selector<
                    LostAndFoundModel,
                    Tuple2<List<LostAndFoundPost>,
                        LostAndFoundSubPageStatus>>(selector: (context, model) {
                  return Tuple2(model.postList[widget.type]!.toList(),
                      model.lostAndFoundSubPageStatus[widget.type]!);
                }, builder: (context, tuple, _) {
                  return tuple.item2 == LostAndFoundSubPageStatus.error
                      ? TextButton(
                          onPressed: () {
                            context
                                    .read<LostAndFoundModel>()
                                    .lostAndFoundSubPageStatus[widget.type] =
                                LostAndFoundSubPageStatus.unload;
                            _onRefresh();
                          },
                          child: Text(
                            '点击重新加载',
                            style: TextUtil.base.normal.grey6C,
                          ))
                      : (tuple.item2 == LostAndFoundSubPageStatus.unload
                          ? Loading()
                          : SmartRefresher(
                    physics: BouncingScrollPhysics(),
                              enablePullDown: true,
                              enablePullUp: true,
                              header: ClassicHeader(
                                idleText: '下拉以刷新 (乀*･ω･)乀',
                                releaseText: '下拉以刷新',
                                refreshingText: "正在刷新喵",
                                completeText: '刷新完成 (ﾉ*･ω･)ﾉ',
                                failedText: '刷新失败（；´д｀）ゞ',
                              ),
                              controller: context
                                  .read<LostAndFoundModel>()
                        .refreshController[widget.type]!,
                    footer: ClassicFooter(
                      idleText: '下拉以刷新',
                      noDataText: '无数据',
                      loadingText: '加载中，请稍等  ;P',
                      failedText: '加载失败（；´д｀）ゞ',
                    ),
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    child: WaterfallFlow.builder(
                      gridDelegate:
                      SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 10.w,
                        crossAxisSpacing: 10.w,
                        crossAxisCount: 2,
                      ),
                      controller: _scrollController,
                      itemCount: tuple.item1.length,
                      itemBuilder: (BuildContext context,
                          int index) =>
                          InkWell(
                              onTap: () {
                                Tuple2 detailTuple = Tuple2(
                                    tuple.item1[index].id,
                                    widget.findOwner);
                                Navigator.pushNamed(
                                    context,
                                    LostAndFoundRouter
                                        .lostAndFoundDetailPage,
                                    arguments: detailTuple);
                              },
                              child: Card(
                                elevation: 3,
                                shadowColor: ColorUtil.greyB4AFColor
                                    .withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(8.r),
                                  side: const BorderSide(
                                      color: Colors.transparent,
                                      width: 0.0),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                    tuple.item1[index]
                                        .coverPhotoPath ==
                                        null
                                        ? Padding(
                                      padding:
                                      EdgeInsetsDirectional
                                          .only(
                                          bottom: 8.h,
                                          start: 3.w,
                                          end: 3.w,
                                          top: 7.h),
                                      child: SizedBox(
                                          width:
                                          double.infinity,
                                          child: Card(
                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          14.w),
                                                              // 设置所有方向的内边距为15个像素
                                                              child: Text(
                                                                  tuple.item1[index].text.length >
                                                                          32
                                                                      ? tuple.item1[index].text.substring(
                                                                              0,
                                                                              31) +
                                                                          '……'
                                                                      : tuple
                                                                          .item1[
                                                                              index]
                                                                          .text,
                                                  style: TextUtil
                                                      .base
                                                      .w400
                                                      .grey89
                                                      .sp(14)
                                                      .h(1.1)
                                                      .NotoSansSC),
                                            ),
                                            elevation: 0,
                                            color: ColorUtil
                                                .whiteF8Color,
                                          )),
                                    )
                                        : Container(
                                        padding:
                                        EdgeInsetsDirectional
                                            .only(
                                            start: 11.w,
                                            end: 11.w,
                                            bottom: 7.h,
                                            top: 7.h),
                                        child: LayoutBuilder(
                                          builder: (context,
                                              constrains) {
                                            final maxWidth =
                                            constrains
                                                .constrainWidth();
                                            final width = tuple
                                                .item1[index]
                                                .coverPhotoSize
                                                ?.width
                                                .toDouble() ??
                                                1.r;
                                            final height = tuple
                                                .item1[index]
                                                .coverPhotoSize
                                                ?.height
                                                .toDouble() ??
                                                0;
                                            return ClipRRect(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(10
                                                  .r), // 设置圆角半径为10.0
                                              child: Container(
                                                width: maxWidth,
                                                child: WpyPic(
                                                  tuple
                                                      .item1[
                                                  index]
                                                      .coverPhotoPath!,
                                                  withHolder:
                                                  true,
                                                  holderHeight:
                                                  height *
                                                      maxWidth /
                                                      width,
                                                  fit: BoxFit
                                                      .fitWidth,
                                                ),
                                                height: height >=
                                                    3 * width
                                                    ? 3 * maxWidth
                                                    : height *
                                                    maxWidth /
                                                    width,
                                              ),
                                            );
                                          },
                                        )),
                                    Padding(
                                      padding:
                                      EdgeInsetsDirectional.only(
                                          start: 12.w, end: 12.w),
                                      child: Text(
                                          tuple.item1[index].title,
                                          style: TextUtil
                                              .base.w600.black2A
                                              .sp(15)
                                              .NotoSansSC),
                                    ),
                                    Padding(
                                      padding:
                                      EdgeInsetsDirectional.only(
                                          start: 12.w,
                                          end: 25.w,
                                          bottom: 18.h,
                                          top: 10.h),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: <Widget>[
                                          Text(
                                              _timeAgo(tuple
                                                  .item1[index]
                                                  .detailedUploadTime),
                                              style: TextUtil
                                                  .base.w400.grey89
                                                  .sp(10)
                                                  .NotoSansSC),
                                          Row(
                                            children: <Widget>[
                                              SvgPicture.asset(
                                                  'assets/svg_pics/icon_flame.svg',
                                                  width: 14.w,
                                                  height: 14.h),
                                              Text(
                                                '${tuple.item1[index].hot.toString()}',
                                                style: TextUtil
                                                    .base.w400.greyHot
                                                    .sp(10)
                                                    .NotoSansSC,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                    ),
                            ));
                }),
              ),
            )
          ],
        ));
  }
}

double get searchBarHeight => 30.h;

double get widgetPadding => 12.h;

class LostAndFoundTag extends StatefulWidget {
  final String type;
  final String category;
  final String? tag;

  const LostAndFoundTag({
    Key? key,
    required this.type,
    required this.category,
    this.tag,
  }) : super(key: key);

  @override
  LostAndFoundTagState createState() => LostAndFoundTagState();
}

class LostAndFoundTagState extends State<LostAndFoundTag> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: WButton(
        onPressed: () async {
          context
                  .read<LostAndFoundModel>()
                  .lostAndFoundSubPageStatus[widget.type] =
              LostAndFoundSubPageStatus.unload;
          context
              .read<LostAndFoundModel>()
              .resetCategory(type: widget.type, category: widget.category);
          context.read<LostAndFoundModel>().clearByType(widget.type);
          await context.read<LostAndFoundModel>().getNext(
                type: widget.type,
                success: () {
                  context
                          .read<LostAndFoundModel>()
                          .lostAndFoundSubPageStatus[widget.type] =
                      LostAndFoundSubPageStatus.ready;
                  context
                      .read<LostAndFoundModel>()
                      .refreshController[widget.type]
                      ?.refreshCompleted();
                },
                failure: (e) {
                  context
                          .read<LostAndFoundModel>()
                          .lostAndFoundSubPageStatus[widget.type] =
                      LostAndFoundSubPageStatus.error;
                  context
                      .read<LostAndFoundModel>()
                      .refreshController[widget.type]
                      ?.refreshFailed();
                  ToastProvider.error(e.error.toString());
                },
                category: context
                    .read<LostAndFoundModel>()
                    .currentCategory[widget.type]!,
              );
        },
        child: Container(
          height: 28.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: widget.category ==
                    context
                        .read<LostAndFoundModel>()
                        .currentCategory[widget.type]
                ? ColorUtil.blue2CColor.withOpacity(0.1)
                : ColorUtil.whiteF8Color,
          ),
          child: Center(
            child: Text(widget.category,
                style: widget.category ==
                        context
                            .read<LostAndFoundModel>()
                            .currentCategory[widget.type]
                    ? TextUtil.base.normal.PingFangSC.w400.sp(10.sp).blue2C
                    : TextUtil.base.normal.PingFangSC.w400.sp(10.sp).black2A),
          ),
        ),
      ),
    );
  }
}
