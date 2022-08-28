import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

import '../feedback_router.dart';
import 'components/post_card.dart';
import 'new_post_page.dart';

class SearchResultPage extends StatefulWidget {
  final SearchResultPageArgs args;

  SearchResultPage(this.args);

  @override
  _SearchResultPageState createState() => _SearchResultPageState(args.keyword,
      args.tagId, args.departmentId, args.title, args.type, args.lakeType);
}

class SearchResultPageArgs {
  final String keyword;
  final String tagId;
  final String departmentId;
  final String title;
  final int lakeType;
  final int type;

  SearchResultPageArgs(this.keyword, this.tagId, this.departmentId, this.title,
      this.type, this.lakeType);
}

enum SearchPageStatus {
  loading,
  idle,
  error,
}

class _SearchResultPageState extends State<SearchResultPage> {
  final String keyword;
  final String tagId;
  final int lakeType;
  final String departmentId;
  final String title;
  final int type;

  int currentPage = 1, totalPage = 1;
  SearchPageStatus status;

  RefreshController _refreshController;
  ScrollController _sc;

  List<Post> _list = [];

  _SearchResultPageState(this.keyword, this.tagId, this.departmentId,
      this.title, this.type, this.lakeType);

  _onRefresh() {
    currentPage = 1;
    FeedbackService.getPosts(
      type: '$type',
      departmentId: departmentId,
      page: currentPage,
      tagId: tagId,
      keyword: keyword,
      onSuccess: (list, page) {
        totalPage = page;
        _list.clear();
        setState(() => _list.addAll(list));
        _refreshController.refreshCompleted();
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
        _refreshController.refreshFailed();
      },
    );
  }

  _onLoading() {
    if (currentPage != totalPage) {
      currentPage++;
      FeedbackService.getPosts(
        departmentId: departmentId,
        type: '$type',
        page: currentPage,
        tagId: tagId,
        keyword: keyword,
        onSuccess: (list, page) {
          totalPage = page;
          setState(() => _list.addAll(list));
          _refreshController.loadComplete();
          if (list.isEmpty) _refreshController.loadNoData();
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
          _refreshController.loadFailed();
        },
      );
    } else {
      _refreshController.loadNoData();
    }
  }

  @override
  void initState() {
    super.initState();
    status = SearchPageStatus.loading;
    _refreshController = RefreshController(initialRefresh: false);
    _sc = ScrollController();
    currentPage = 1;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FeedbackService.getPosts(
        departmentId: departmentId,
        type: '$type',
        page: currentPage,
        tagId: tagId,
        keyword: keyword,
        onSuccess: (list, page) {
          totalPage = page;
          setState(() {
            _list.addAll(list);
            status = SearchPageStatus.idle;
          });
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget appBar = AppBar(
        titleSpacing: 0,
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        leading: IconButton(
          icon: Image.asset(
            "assets/images/lake_butt_icons/back.png",
            color: ColorUtil.mainColor,
            width: 12,
          ),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: GestureDetector(
          onTap: () {
            if (_sc.offset > 1000) {
              _sc.jumpTo(800);
              _refreshController.requestRefresh();
            } else
              _sc.animateTo(-180,
                  duration: Duration(milliseconds: 600),
                  curve: Curves.easeInOut);
          },
          child: Center(
              child: Text(title, style: TextUtil.base.bold.black2A.sp(16)),
            ),
        ),
        actions: [
          if (lakeType != 0)
            InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('跟帖', style: TextUtil.base.bold.blue303C.sp(12)),
                    SizedBox(width: 4),
                    Container(
                        height: 24,
                        width: 24,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/lake_butt_icons/add_post.png")))),
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(context, FeedbackRouter.newPost,
                      arguments: NewPostArgs(true, tagId, lakeType, title));
                }),
          if(lakeType !=0) SizedBox(width: 14),

          if(lakeType == 0) SizedBox(width: 40,),
        ]);

    Widget body;

    switch (status) {
      case SearchPageStatus.loading:
        body = Center(child: Loading());
        break;
      case SearchPageStatus.idle:
        if (_list.isNotEmpty) {
          body = SmartRefresher(
              controller: _refreshController,
              header: ClassicHeader(),
              enablePullDown: true,
              onRefresh: _onRefresh,
              footer: ClassicFooter(),
              enablePullUp: true,
              onLoading: _onLoading,
              child: ListView.custom(
                key: Key('searchResultView'),
                physics: BouncingScrollPhysics(),
                controller: _sc,
                childrenDelegate: SliverChildBuilderDelegate(
                  (context, index) {
                    Widget post = PostCard.simple(_list[index]);
                    return post;
                  },
                  childCount: _list.length,
                  findChildIndexCallback: (key) {
                    final ValueKey<String> valueKey = key;
                    return _list
                        .indexWhere((m) => 'srm-${m.id}' == valueKey.value);
                  },
                ),
              ));
        } else {
          body = Center(
            child: Text(S.current.feedback_no_post,
                style: TextUtil.base.regular
                    .customColor(Color.fromARGB(255, 145, 145, 145))),
          );
        }
        break;
      case SearchPageStatus.error:
        body = Center(child: Text("error"));
        break;
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return true;
      },
      child: Scaffold(
          appBar: appBar,
          body: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: body,
          )),
    );
  }
}
