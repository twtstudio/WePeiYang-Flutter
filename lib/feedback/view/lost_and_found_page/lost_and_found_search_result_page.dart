import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import '../../../commons/util/toast_provider.dart';
import '../../network/lost_and_found_post.dart';
import 'lost_and_found_home_page.dart';
import 'lost_and_found_search_notifier.dart';

class LostAndFoundSearchResultPage extends StatefulWidget {

  final LostAndFoundSearchResultPageArgs args;
  LostAndFoundSearchResultPage(this.args);

  @override
  _LostAndFoundSearchResultPageState createState()=> _LostAndFoundSearchResultPageState(args.type,
      args.category, args.keyword);
}

class LostAndFoundSearchResultPageArgs {
  final String type;
  final String category;
  final String keyword;

  LostAndFoundSearchResultPageArgs(this.type, this.category, this.keyword);
}

class _LostAndFoundSearchResultPageState extends State<LostAndFoundSearchResultPage> {

  final String type;
  final String category;
  final String keyword;

  _LostAndFoundSearchResultPageState(this.type, this.category, this.keyword);

  void _onRefresh() async{
    context.read<LostAndFoundModel2>().clearByType(type);
    await context.read<LostAndFoundModel2>().getNext(
      type: type,
      category: category,
      keyword: keyword,
      success: () {
        context.read<LostAndFoundModel2>().lostAndFoundSubPageStatus[type] =
            LostAndFoundSubPageStatus2.ready;
        context.read<LostAndFoundModel2>().refreshController[type]?.refreshCompleted();
      },
      failure: (e) {
        context.read<LostAndFoundModel2>().lostAndFoundSubPageStatus[type] =
            LostAndFoundSubPageStatus2.error;
        context.read<LostAndFoundModel2>().refreshController[type]?.refreshFailed();
        ToastProvider.error(e.error.toString());
      },
    );
  }

  void _onLoading() async{
    await context.read<LostAndFoundModel2>().getNext(
      type: type,
      category: category,
      keyword: keyword,
      success: () {
        context.read<LostAndFoundModel2>().lostAndFoundSubPageStatus[type] =
            LostAndFoundSubPageStatus2.ready;
        context.read<LostAndFoundModel2>().refreshController[type]?.loadComplete();
      },
      failure: (e) {
        context.read<LostAndFoundModel2>().lostAndFoundSubPageStatus[type] =
            LostAndFoundSubPageStatus2.error;
        context.read<LostAndFoundModel2>().refreshController[type]?.loadFailed();
        ToastProvider.error(e.error.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    if(context.read<LostAndFoundModel2>().lostAndFoundSubPageStatus[type] == LostAndFoundSubPageStatus2.unload ||
        context.read<LostAndFoundModel2>().lostAndFoundSubPageStatus[type] == LostAndFoundSubPageStatus2.error
    ) {
      context.read<LostAndFoundModel2>().clearByType(type);
      _onRefresh();
      print(100);
    };

    var appBar = LostAndFoundAppBar(
      leading: Padding(
        padding: EdgeInsetsDirectional.only(start: 8, bottom: 8),
        child: WButton(
          child: WpyPic(
            'assets/svg_pics/laf_butt_icons/back.svg',
            width: 28.w,
            height: 28.w,
          ),
          onPressed: () => Navigator.pop(context), ///to do
        ),
      ),
      action: Padding(
        padding: EdgeInsetsDirectional.only(end: 20, bottom: 12),),
      title: Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Text('搜索结果', style: TextStyle().white.NotoSansSC.w400.sp(20),),
      ),
    );


    return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            appBar,
            SizedBox(height: 7,),
            Expanded(
              child: Container(
                padding: EdgeInsetsDirectional.only(start: 17.w, end: 17.w),
                child: Selector<LostAndFoundModel2, List<LostAndFoundPost>>(
                    selector: (context, model){
                      return model.postList[context.read<LostAndFoundModel2>().currentType]!.toList();
                    },
                    builder: (context, postList, _) {
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
                        controller: context.read<LostAndFoundModel2>().refreshController[context.read<LostAndFoundModel2>().currentType]!,
                        footer: ClassicFooter(
                          idleText: '下拉以刷新',
                          noDataText: '无数据',
                          loadingText: '加载中，请稍等  ;P',
                          failedText: '加载失败（；´д｀）ゞ',
                        ),
                        onRefresh: _onRefresh,
                        onLoading: _onLoading,
                        child: WaterfallFlow.builder(
                            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.w,
                              mainAxisSpacing: 8.w,
                            ),
                            itemCount: postList.length,
                            itemBuilder: (context,index){
                              return Container(
                                color: Colors.grey,
                                child: Column(
                                  children: [
                                    postList[index].coverPhotoPath == null
                                        ? Container(
                                      child: Text(postList[index].text),
                                    )
                                        : Container(
                                        child: LayoutBuilder(
                                          builder: (context, constrains){
                                            final maxWidth = constrains.constrainWidth();
                                            final width = postList[index].coverPhotoSize?.width.toDouble() ?? 1;
                                            final height = postList[index].coverPhotoSize?.height.toDouble() ?? 0;
                                            return Container(
                                              child: WpyPic(
                                                postList[index].coverPhotoPath!,
                                                withHolder: true,
                                                holderHeight: height * maxWidth / width,
                                                width: width,
                                              ),
                                              height: height >= 3 * width
                                                  ? 3 * maxWidth
                                                  : height * maxWidth / width,
                                            );
                                          },
                                        )
                                    ),/// 后面的同学写卡片时可以用item.coverPhotoSize来在网络图片获取前获取图片大小，从而预留占位
                                    Padding(padding: EdgeInsetsDirectional.only(bottom: 20.h)),
                                    Container(
                                        child: Text(postList[index].title)
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(postList[index].uploadTime),
                                        Text('hot:${postList[index].hot.toString()}')
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }
                        ),
                      );
                    }
                ),
              ),
            )
          ],
        )
    );
  }
}
