import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keframe/keframe.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/create/create_comment.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/create_button.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/rating_theme_block_ui.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/rating_object_block_ui.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/tag_ui.dart';

import '../../../../commons/widgets/loading.dart';
import '../../../view/lake_home_page/normal_sub_page.dart';
import '../../ui/loading_dot.dart';
import '../../ui/rating_comment_block_ui.dart';
import '../../ui/rotation_route.dart';

class ObjectPage extends StatefulWidget {

  DataIndex dataIndex;
  Widget objectBlock;
  Color color;

  ObjectPage({required this.dataIndex, required this.objectBlock, required this.color});

  @override
  _ObjectPageState createState() => _ObjectPageState();
}

class _ObjectPageState extends State<ObjectPage> {

  /***************************************************************
      数据
   ***************************************************************/

  //排序方式
  late String sortType;

  /***************************************************************
      变量与函数
   ***************************************************************/
  RefreshController refreshController = RefreshController();
  ScrollController _scrollController = ScrollController();

  late Timer changingDataTimer;

  Future<void> _fakeLoadData() async {
    await Future.delayed(Duration(microseconds: 2000), () {
      refreshController.refreshCompleted();
    });
    context
        .read<RatingPageData>()
        .nowSortType
        .value =
    context
        .read<RatingPageData>()
        .nowSortType
        .value == "热度" ? "时间" : "热度";
    context
        .read<RatingPageData>()
        .getDataIndexTree(widget.dataIndex)
        .reset();
    setState(() {});
  }

  /***************************************************************
      生命周期
   ***************************************************************/

  Map<String, List<DataIndex>> commentIndexM = {'hot': [], 'time': []};

  myIndexTree() =>
      context
          .read<RatingPageData>()
          .getDataIndexTree(widget.dataIndex);

  loadUI() async {
    if (myIndexTree().isFinish()) {

      if(myIndexTree().isFinish())
        _timer.cancel();
      //debugOutput(context, myIndexTree().children.toString());
      commentIndexM = myIndexTree().children;
      setState(() {
      });
    }
    else{
      return Timer(Duration(milliseconds: 200), () {
        loadUI();
      });
    }
  }

  @override
  void initState() {

    sortType = context
        .read<RatingPageData>()
        .nowSortType
        .value;
    context
        .read<RatingPageData>()
        .nowSortType
        .addListener(() {
      setState(() {
      });
    context
        .read<RatingPageData>()
        .getDataIndexTree(widget.dataIndex)
        .UI.addListener(() {
          setState(() {
            if(myIndexTree().isFinish())
              _timer.cancel();
          });
        });
    });
    super.initState();
  }

  bool _animationCompleted = false;
  Timer _timer= Timer.periodic(Duration(microseconds: 100), (timer) {
  });
  /***************************************************************
      构建
   ***************************************************************/
  @override
  Widget build(BuildContext context) {
    _timer = Timer.periodic(Duration(microseconds: 100), (timer) {
      setState(() {
      });
    });
    if(myIndexTree().isFinish())
      _timer.cancel();

    loadUI();
    var route = ModalRoute.of(context);
    if (route != null && !_animationCompleted) {
      void handler(status) {
        if (status == AnimationStatus.completed) {
          route.animation?.removeStatusListener(handler);
          setState(() {
            _animationCompleted = true;
          });
        }
      }
      route.animation?.addStatusListener(handler);
    }

    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double mm = screenWidth * 0.9 / 60; //获取现实中1毫米的像素长度

    context
        .read<RatingPageData>()
        .refreshController = refreshController;

    double getProgress() {
      try {
        return _scrollController.offset /
            (_scrollController.position.maxScrollExtent + 0.01);
      } catch (e) {
        return 0.0;
      }
    }

    /***************************************************************
        顶部的白色颜色块
     ***************************************************************/

    Widget topBlock = Container(
      width: screenWidth,
      height: 25 * mm,
      color: Colors.white,
    );
    topBlock = Positioned(
      top: 0,
      left: 0,
      child: topBlock,
    );

    /***************************************************************
        返回按钮,用于返回到上一页面
     ***************************************************************/

    Widget backButton = Container(
      width: 4 * mm,
      height: 4 * mm,
      child: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );

    backButton = Positioned(
      top: 8 * mm,
      left: 4 * mm,
      child: backButton,
    );

    /***************************************************************
        标题,粗体黑色文本
     ***************************************************************/

    Widget title = Container(
      width: screenWidth,
      height: 5 * mm,
      child: Center(
        child: Text(
          widget.dataIndex.dataId.toString(),
          style: TextStyle(fontFamily: "NotoSansHans",
            color: Colors.black,
            fontWeight: FontWeight.bold, // 设置字体为粗体
            fontSize: 22,
          ),
        ),
      ),
    );

    title = Positioned(
      top: 8 * mm,
      left: 0,
      child: title,
    );

    /***************************************************************
        创建者信息,包含圆形图片,创建者名称,创建时间
     ***************************************************************/

    Widget creatorInfo = Container(
      child: Row(
        children: [
          Container(
            width: 8 * mm,
            height: 8 * mm,
            child: CircleAvatar(
              backgroundImage: AssetImage(
                  "assets/images/feedback/rating_page/creator.jpg"),
            ),
          ),
          Container(width: 2 * mm,),
          Column(
            //靠左对齐
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "创建者名称",
                style: TextStyle(fontFamily: "NotoSansHans",
                  color: Colors.black,
                  fontSize: 3 * mm, // 设置文本字体大小
                ),
              ),
              Text(
                "创建时间",
                style: TextStyle(fontFamily: "NotoSansHans",
                  color: Colors.grey,
                  fontSize: 2.5 * mm, // 设置文本字体大小
                ),
              ),
            ],
          ),
        ],
      ),
    );

    creatorInfo = Positioned(
      top: 16 * mm,
      left: 4 * mm,
      child: creatorInfo,
    );

    /***************************************************************
        关于评分对象
     ***************************************************************/

    Widget objectBlock = widget.objectBlock;
    objectBlock = Positioned(
      top: 26 * mm,
      left: 0 * mm,
      child: objectBlock,
    );

    /***************************************************************
        底部的按钮,用于创建评分对象
     ***************************************************************/

    Widget bottomButton = Container(
        height: 8*mm,
        width: screenWidth,
        color: Colors.white,

        child: Column(
          children: [
            Container(
              height: 0.2*mm,
              color: Colors.grey.withOpacity(0.2),
            ),
            Padding(
              padding: EdgeInsets.only(top: 2*mm),
              child: Container(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cake_outlined,
                          color: widget.color,
                          size: 4*mm,
                        ),
                        Container(
                          width: 1.5*mm,
                        ),
                        Text(
                          "创建评论",
                          style: TextStyle(
                            fontFamily: "NotoSansHans",
                            color: widget.color,
                            fontWeight: FontWeight.bold, // 设置字体为粗体
                            fontSize: 3*mm, // 设置文本字体大小
                          ),
                        ),
                      ],
                    ),
                  )
              ),
            ),
          ],
        )
    );

    bottomButton = InkWell(
      onTap: () {
        Navigator.push(
          context,
          RotationRoute(page: CreateComment(dataIndex: widget.dataIndex, ratingValue: 0,)),
        );
      },
      child: bottomButton,
    );

    bottomButton = Positioned(
      bottom: 0,
      left: 0,
      child: bottomButton,
    );

    /***************************************************************
        顶部组件合并
     ***************************************************************/

    Widget topPart = Stack(
      children: [
        topBlock,
        //topWhiteBlock,
        backButton,
        title,
        creatorInfo,
        objectBlock,
      ],
    );

    topPart = Container(
      width: screenWidth,
      height: 55 * mm,
      child: topPart,
    );

    /***************************************************************
        主页面
     ***************************************************************/

    Widget mainPage = Container(
      color: Colors.white,
      child: SizeCacheWidget(
          child: SmartRefresher(
            physics: BouncingScrollPhysics(),
            controller: refreshController,
            header: ClassicHeader(
              height: 5.h,
              completeDuration: Duration(milliseconds: 300),
              idleText: '下拉以刷新推送方式',
              releaseText: '下拉以刷新推送方式',
              refreshingText: "刷新中",
              completeText: '刷新完成 (ﾉ*･ω･)ﾉ',
              failedText: '刷新失败（；´д｀）ゞ',
            ),
            cacheExtent: 11,
            enablePullDown: true,
            onRefresh: _fakeLoadData,
            footer: ClassicFooter(
              idleText: '下拉以刷新',
              noDataText: '无数据',
              loadingText: '终于写完了',
              failedText: '加载失败（；´д｀）ゞ',
            ),
            enablePullUp: true,
            onLoading: _fakeLoadData,
            child: ListView.builder(
              controller: _scrollController,
              cacheExtent: 400,
              itemCount:
              145,
              itemBuilder: (BuildContext context, int index) {

                /***************************************************************
                    顶部组件
                 ***************************************************************/
                if (index == 0) {
                  index -= 1;
                  return Column(
                    children: [
                      topPart,
                      //分割线
                      TagUI(dataIndexTree:
                      context
                          .read<RatingPageData>()
                          .getDataIndexTree(widget.dataIndex)
                      ),
                      Divider(),
                    ],
                  );
                }
                /***************************************************************
                    列表内组件
                 ***************************************************************/
                return FrameSeparateWidget(
                    index: index,
                    placeHolder: Container(
                      color: Colors.white,
                      height: 30*mm,
                    ),
                    child: Center(
                        child: ListTile(
                          title: RatingCommentBlock(
                            dataIndex: (
                                commentIndexM[transSortType[sortType]!]!.length==0)
                                ?NullDataIndex
                                :commentIndexM[transSortType[sortType]!]![index % commentIndexM[transSortType[sortType]!]!.length],),
                        )
                    )
                );
              },
            ),
          )
      ),
    );

    Widget allInOne = Stack(
      children: [
        mainPage,
        bottomButton,
        (myIndexTree().isFinish()&&_animationCompleted)
            ? Container()
            : BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),

          ///整体模糊度
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0),

                ///背景透明
                borderRadius: BorderRadius.all(Radius.circular(1.2))

              ///圆角
            ),
            child: IndexTreeLoadingDots(widget.dataIndex),
          ),
        ),
      ],
    );

    return allInOne;
  }
}
