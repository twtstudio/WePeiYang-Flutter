import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

import '../../commons/themes/wpy_theme.dart';
import '../../commons/widgets/w_button.dart';
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
  int searchMode = 1;
  int currentPage = 1, totalPage = 1;
  SearchPageStatus status = SearchPageStatus.loading;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ScrollController _sc = ScrollController();

  List<Post> _list = [];

  _SearchResultPageState(this.keyword, this.tagId, this.departmentId,
      this.title, this.type, this.lakeType);

  _refreshPost() async {
    await FeedbackService.getPosts(
      type: '$type',
      departmentId: departmentId,
      page: currentPage,
      tagId: tagId,
      keyword: keyword,
      searchMode: searchMode,
      onSuccess: (list, page) {
        status = SearchPageStatus.idle;
        totalPage = page;
        _list.clear();
        setState(() => _list.addAll(list));
      },
      onFailure: (e) {
        status = SearchPageStatus.idle;
        ToastProvider.error(e.error.toString());
        _refreshController.refreshFailed();
      },
    );
  }

  _onRefresh() async {
    currentPage = 1;
    setState(() {
      status = SearchPageStatus.loading;
    });
    _refreshPost();
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
        searchMode: searchMode,
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FeedbackService.getPosts(
        departmentId: departmentId,
        type: '$type',
        page: currentPage,
        tagId: tagId,
        keyword: keyword,
        searchMode: searchMode,
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
    var appBar = AppBar(
        titleSpacing: 0,
        elevation: 0,
        centerTitle: true,
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: WpyTheme.of(context).get(WpyColorKey.defaultActionColor),
          ),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: WButton(
          onPressed: () {
            if (_sc.offset > 1000) {
              _sc.jumpTo(800);
              _refreshController.requestRefresh();
            } else
              _sc.animateTo(-180,
                  duration: Duration(milliseconds: 600),
                  curve: Curves.easeInOut);
          },
          child: Center(
            child: Text(title, style: TextUtil.base.bold.label(context).sp(16)),
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
                    Text('跟帖', style: TextUtil.base.bold.customColor(WpyTheme.of(context).get(WpyColorKey.cursorColor)).sp(12)),
                    SizedBox(width: 4),
                    Container(
                        height: 24,
                        width: 24,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/lake_butt_icons/add_post.png")))),
                    SizedBox(width: 14)
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(context, FeedbackRouter.newPost,
                      arguments: NewPostArgs(true, tagId, lakeType, title));
                })
          else
            SizedBox(
              width: 40,
            )
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
                    if (index == 0) {
                      return Container(
                        color: WpyTheme.of(context)
                            .get(WpyColorKey.primaryBackgroundColor),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const SizedBox(width: 15),
                                WButton(
                                  onPressed: () async {
                                    searchMode = 0;
                                    await _refreshController.requestRefresh();
                                  },
                                  child: Text('发帖时间正序',
                                      style: searchMode == 0
                                          ? TextUtil.base
                                              .label(context)
                                              .w700
                                              .sp(14)
                                              .primaryAction(context)
                                          : TextUtil.base
                                              .label(context)
                                              .w500
                                              .sp(14)),
                                ),
                                const SizedBox(width: 15),
                                WButton(
                                  onPressed: () {
                                    searchMode = 1;
                                    _refreshController.requestRefresh();
                                  },
                                  child: Text('更新时间正序',
                                      style: searchMode == 1
                                          ? TextUtil.base
                                              .label(context)
                                              .w700
                                              .sp(14)
                                              .primaryAction(context)
                                          : TextUtil.base
                                              .label(context)
                                              .w500
                                              .sp(14)),
                                ),
                                Spacer(),
                                const SizedBox(width: 15),
                              ],
                            ),
                            SizedBox(height: 10), //topCard,
                          ],
                        ),
                      );
                    }
                    Widget post = PostCardNormal(_list[index]);
                    return post;
                  },
                  childCount: _list.length,
                  findChildIndexCallback: (key) {
                    return _list.indexWhere((m) =>
                        'srm-${m.id}' == (key as ValueKey<String>).value);
                  },
                ),
              ));
        } else {
          body = Center(
            child: Text(S.current.feedback_no_post,
                style: TextUtil.base.regular.infoText(context)),
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
      child: GestureDetector(
        child: Scaffold(
            appBar: appBar,
            body: AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: body,
            )),
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          if (details.delta.dx > 20) {
            Navigator.pop(context, true);
          }
        },
      ),
    );
  }
}
