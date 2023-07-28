import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/network/lost_and_found_post.dart';
import 'package:we_pei_yang_flutter/feedback/view/lost_and_found_page/lost_and_found_notifier.dart';
import '../../../main.dart';
import '../../feedback_router.dart';
import '../../util/color_util.dart';
import '../lake_home_page/lake_notifier.dart';
import 'lost_and_found_search_notifier.dart';

class LostAndFoundSubPage extends StatefulWidget {
  final String type;

  const LostAndFoundSubPage({Key? key, required this.type}) : super(key: key);

  @override
  LostAndFoundSubPageState createState() => LostAndFoundSubPageState();
}
double get searchBarHeight => 42.h;

class LostAndFoundSubPageState extends State<LostAndFoundSubPage>{
  void _onRefresh() async{
    context.read<LostAndFoundModel>().clearByType(widget.type);
    await context.read<LostAndFoundModel>().getNext(
      type: widget.type,
      success: () {
        context.read<LostAndFoundModel>().lostAndFoundSubPageStatus[widget.type] =
            LostAndFoundSubPageStatus.ready;
        context.read<LostAndFoundModel>().refreshController[widget.type]?.refreshCompleted();
      },
      failure: (e) {
        context.read<LostAndFoundModel>().lostAndFoundSubPageStatus[widget.type] =
            LostAndFoundSubPageStatus.error;
        context.read<LostAndFoundModel>().refreshController[widget.type]?.refreshFailed();
        ToastProvider.error(e.error.toString());
      },
      category:  context.read<LostAndFoundModel>().currentCategory[widget.type]!,
    );
  }

  void _onLoading() async{
    await context.read<LostAndFoundModel>().getNext(
      type: widget.type,
      success: () {
        context.read<LostAndFoundModel>().lostAndFoundSubPageStatus[widget.type] =
            LostAndFoundSubPageStatus.ready;
        context.read<LostAndFoundModel>().refreshController[widget.type]?.loadComplete();
      },
      failure: (e) {
        context.read<LostAndFoundModel>().lostAndFoundSubPageStatus[widget.type] =
            LostAndFoundSubPageStatus.error;
        context.read<LostAndFoundModel>().refreshController[widget.type]?.loadFailed();
        ToastProvider.error(e.error.toString());
      },
      category:  context.read<LostAndFoundModel>().currentCategory[widget.type]!,
    );
  }

  @override
  Widget build(BuildContext context) {
    if(context.read<LostAndFoundModel>().lostAndFoundSubPageStatus[widget.type] == LostAndFoundSubPageStatus.unload ||
        context.read<LostAndFoundModel>().lostAndFoundSubPageStatus[widget.type] == LostAndFoundSubPageStatus.error
    ) _onRefresh();

    var searchBar = InkWell(
      onTap: (){
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
                      '天大不能没有微北洋',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          searchBar,
          SizedBox(height: 7,),
          Padding(
            padding: EdgeInsetsDirectional.only(bottom: 8.h),
            child: Selector<LostAndFoundModel,String>(
              selector: (context, model){
                return model.currentCategory[widget.type]!;
              },
              builder:(context, category, _){
                return Flex(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Expanded(child: LostAndFoundTag(category: '全部',type: widget.type), flex: 4,),
                    Expanded(child: LostAndFoundTag(category: '生活日用',type: widget.type), flex: 5,),
                    Expanded(child: LostAndFoundTag(category: '数码产品',type: widget.type), flex: 5,),
                    Expanded(child: LostAndFoundTag(category: '钱包卡证',type: widget.type), flex: 5,),
                    Expanded(child: LostAndFoundTag(category: '其他',type: widget.type), flex: 4,),
                  ],
                );
              },
            ),
          ),

          Expanded(
            child: Container(
              padding: EdgeInsetsDirectional.only(start: 17.w, end: 17.w),
              child: Selector<LostAndFoundModel, List<LostAndFoundPost>>(
                selector: (context, model){
                  return model.postList[widget.type]!.toList();
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
                    controller: context.read<LostAndFoundModel>().refreshController[widget.type]!,
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

class LostAndFoundTag extends StatefulWidget {
  final String type;
  final String category;
  final String? tag;
  const LostAndFoundTag({Key? key, required this.type, required this.category, this.tag,}) : super(key: key);

  @override
  LostAndFoundTagState createState() => LostAndFoundTagState();
}

class LostAndFoundTagState extends State<LostAndFoundTag> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w,right: 8.w),
      child: WButton(
        onPressed: () async{
          context.read<LostAndFoundModel>().resetCategory(type: widget.type, category: widget.category);
          context.read<LostAndFoundModel>().clearByType(widget.type);
          await context.read<LostAndFoundModel>().getNext(
            type: widget.type,
            success: () {
              context.read<LostAndFoundModel>().lostAndFoundSubPageStatus[widget.type] = LostAndFoundSubPageStatus.ready;
              context.read<LostAndFoundModel>().refreshController[widget.type]?.refreshCompleted();
            },
            failure: (e) {
              context.read<LostAndFoundModel>().lostAndFoundSubPageStatus[widget.type] = LostAndFoundSubPageStatus.error;
              context.read<LostAndFoundModel>().refreshController[widget.type]?.refreshFailed();
              ToastProvider.error(e.error.toString());
            },
            category:  context.read<LostAndFoundModel>().currentCategory[widget.type]!,
          );
        },
        child: Container(
          height: 30.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: widget.category == context.read<LostAndFoundModel>().currentCategory[widget.type]
                ? Color.fromARGB(255, 234, 243, 254)
                : Color.fromARGB(248, 248, 248, 248)
          ),
          child: Center(
            child: Text(
                widget.category,
                style: widget.category == context.read<LostAndFoundModel>().currentCategory[widget.type]
                    ? TextUtil.base.normal.NotoSansSC.w400.sp(8.5.sp).blue2C
                    : TextUtil.base.normal.NotoSansSC.w400.sp(8.5.sp).black2A
            ),
          ),
        ),
      ),
    );
  }
}
