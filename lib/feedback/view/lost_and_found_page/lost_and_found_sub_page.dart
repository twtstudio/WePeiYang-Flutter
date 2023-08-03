import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/type_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/network/lost_and_found_post.dart';
import 'package:we_pei_yang_flutter/feedback/view/lost_and_found_page/lost_and_found_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/view/lost_and_found_page/lost_and_found_search_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/view/lost_and_found_page/lost_and_found_detail_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/main.dart';

class LostAndFoundSubPage extends StatefulWidget {
  final String type;

  const LostAndFoundSubPage({Key? key, required this.type}) : super(key: key);

  @override
  LostAndFoundSubPageState createState() => LostAndFoundSubPageState();
}

double get searchBarHeight => 42.h;

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
                LostAndFoundSubPageStatus.idle;
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
                LostAndFoundSubPageStatus.idle;
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
        Navigator.pushNamed(context, FeedbackRouter.lostAndFoundSearch);
      },
      child: Container(
        height: searchBarHeight - 8,
        margin: EdgeInsets.fromLTRB(15, 8, 15, 0),
        decoration: BoxDecoration(
            color: ColorUtil.greyEAColor,
            borderRadius: BorderRadius.all(Radius.circular(15))),
        child: Row(children: [
          SizedBox(width: 14),
          Icon(
            Icons.search,
            size: 19,
            color: ColorUtil.grey108,
          ),
          SizedBox(width: 12),
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
            searchBar,
            SizedBox(
              height: 7,
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(bottom: 8.h),
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
                        child:
                            LostAndFoundTag(category: '全部', type: widget.type),
                        flex: 4,
                      ),
                      Expanded(
                        child: LostAndFoundTag(
                            category: '生活日用', type: widget.type),
                        flex: 5,
                      ),
                      Expanded(
                        child: LostAndFoundTag(
                            category: '数码产品', type: widget.type),
                        flex: 5,
                      ),
                      Expanded(
                        child: LostAndFoundTag(
                            category: '钱包卡证', type: widget.type),
                        flex: 5,
                      ),
                      Expanded(
                        child:
                            LostAndFoundTag(category: '其他', type: widget.type),
                        flex: 4,
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsetsDirectional.only(start: 17.w, end: 17.w),
                child: Selector<
                    LostAndFoundModel,
                    Tuple2<List<LostAndFoundPost>,
                        LostAndFoundSubPageStatus>>(selector: (context, model) {
                  return Tuple2(model.postList[widget.type]!.toList(),
                      model.lostAndFoundSubPageStatus[widget.type]!);
                }, builder: (context, tuple, _) {
                  return tuple.item2 == LostAndFoundSubPageStatus.error
                      ? TextButton(
                      onPressed: (){
                        context.read<LostAndFoundModel>().lostAndFoundSubPageStatus[widget.type] = LostAndFoundSubPageStatus.unload;
                        _onRefresh();
                      },
                      child: Text(
                        '点击重新加载',
                        style: TextUtil.base.normal.grey6C,
                      ))
                      : (tuple.item2 == LostAndFoundSubPageStatus.unload
                          ? Loading()
                          : SmartRefresher(
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
                              child: StaggeredGridView.countBuilder(
                                controller: _scrollController,
                                crossAxisCount: 2,
                                itemCount: tuple.item1.length,
                                itemBuilder: (BuildContext context,
                                        int index) =>
                                    InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LostAndFoundDetailPage(
                                                        postId: tuple
                                                            .item1[index].id,
                                                        findOwner: true,
                                                      )));
                                        },
                                        child: Card(
                                          elevation: 0.5,
                                          margin: const EdgeInsets.all(16.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
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
                                                  ? SizedBox(
                                                      width: double.infinity,
                                                      child: Card(
                                                        child: Padding(
                                                          // 添加Padding组件
                                                          padding: EdgeInsets.all(
                                                              10), // 设置所有方向的内边距为15个像素
                                                          child: Text(
                                                            tuple.item1[index]
                                                                .text,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Color(
                                                                  0xff898989),
                                                            ),
                                                          ),
                                                        ),
                                                        elevation: 0,
                                                        color:
                                                            Color(0xfff8f8f8),
                                                      ))
                                                  : Container(
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
                                                            1;
                                                        final height = tuple
                                                                .item1[index]
                                                                .coverPhotoSize
                                                                ?.height
                                                                .toDouble() ??
                                                            0;
                                                        return ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  10.0), // 设置圆角半径为10.0
                                                          child: Container(
                                                            width: maxWidth,
                                                            child: WpyPic(
                                                              tuple.item1[index]
                                                                  .coverPhotoPath!,
                                                              withHolder: true,
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
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  tuple.item1[index].title,
                                                  style: const TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      _timeAgo(tuple
                                                          .item1[index]
                                                          .detailedUploadTime),
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xff898989),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        SvgPicture.asset(
                                                            'assets/svg_pics/icon_flame.svg',
                                                            width: 16.0,
                                                            height: 16.0),
                                                        Text(
                                                          '${tuple.item1[index].hot.toString()}',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xff898989),
                                                          ),
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
                            ));
                }),
              ),
            )
          ],
        ));
  }
}

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
    return Padding(
      padding: EdgeInsets.only(left: 8.w, right: 8.w),
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
          height: 30.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: widget.category ==
                      context
                          .read<LostAndFoundModel>()
                          .currentCategory[widget.type]
                  ? Color.fromARGB(255, 234, 243, 254)
                  : Color.fromARGB(248, 248, 248, 248)),
          child: Center(
            child: Text(widget.category,
                style: widget.category ==
                        context
                            .read<LostAndFoundModel>()
                            .currentCategory[widget.type]
                    ? TextUtil.base.normal.NotoSansSC.w400.sp(8.5.sp).blue2C
                    : TextUtil.base.normal.NotoSansSC.w400.sp(8.5.sp).black2A),
          ),
        ),
      ),
    );
  }
}
