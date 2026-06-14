import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/log/log.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';

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
  late String keyword;
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
  late final TextEditingController _searchController;
  final FocusNode _searchFocus = FocusNode();

  List<Post> _list = [];

  _SearchResultPageState(String keyword, this.tagId, this.departmentId,
      this.title, this.type, this.lakeType) {
    this.keyword = keyword;
    _searchController = TextEditingController(text: keyword);
  }

  bool get _canEditKeyword =>
      tagId.isEmpty && departmentId.isEmpty && lakeType == 0;

  int? _postIdFromKeyword(String keyword) {
    if (!keyword.startsWith('#MP')) return null;
    return int.tryParse(keyword.substring(3));
  }

  void _submitKeyword(String value) {
    final nextKeyword = value.trim();
    if (nextKeyword.isEmpty) return;

    final postId = _postIdFromKeyword(nextKeyword);
    if (postId != null) {
      FeedbackService.getPostById(
        id: postId,
        onResult: (post) {
          if (!mounted) return;
          Navigator.pushNamed(
            context,
            FeedbackRouter.detail,
            arguments: post,
          );
        },
        onFailure: (e) {
          ToastProvider.error('无法找到对应帖子，报错信息：${e.error}');
        },
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      keyword = nextKeyword;
      currentPage = 1;
      totalPage = 1;
      status = SearchPageStatus.loading;
      _list.clear();
    });
    _refreshController.resetNoData();
    _refreshPost();
  }

  _refreshPost() async {
    try {
      final result = await FeedbackService.getPosts(
        type: '$type',
        departmentId: departmentId,
        page: currentPage,
        tagId: tagId,
        keyword: keyword,
        searchMode: searchMode,
      );
      final list = result.item1, page = result.item2;
      status = SearchPageStatus.idle;
      totalPage = page;
      _list.clear();
      setState(() => _list.addAll(list));
      _refreshController.refreshCompleted();
    } catch (e) {
      if (e is DioException) {
        status = SearchPageStatus.idle;
        ToastProvider.error(e.error.toString());
        _refreshController.refreshFailed();
      } else {
        Log.e(e, StackTrace.current, 'feedback');
      }
    }
  }

  _onRefresh() async {
    currentPage = 1;
    setState(() {
      status = SearchPageStatus.loading;
    });
    await _refreshPost();
  }

  _onLoading() async {
    if (currentPage != totalPage) {
      currentPage++;
      try {
        final result = await FeedbackService.getPosts(
            departmentId: departmentId,
            type: '$type',
            page: currentPage,
            tagId: tagId,
            keyword: keyword,
            searchMode: searchMode);
        final list = result.item1, page = result.item2;
        totalPage = page;
        setState(() => _list.addAll(list));
        _refreshController.loadComplete();
        if (list.isEmpty) _refreshController.loadNoData();
      } catch (e) {
        if (e is DioException) {
          ToastProvider.error(e.error.toString());
          _refreshController.loadFailed();
        } else {
          Log.e(e, StackTrace.current, 'feedback');
        }
      }
    } else {
      _refreshController.loadNoData();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        final result = await FeedbackService.getPosts(
          departmentId: departmentId,
          type: '$type',
          page: currentPage,
          tagId: tagId,
          keyword: keyword,
          searchMode: searchMode,
        );
        final list = result.item1, page = result.item2;
        totalPage = page;
        setState(() {
          _list.addAll(list);
          status = SearchPageStatus.idle;
        });
      } catch (e) {
        if (e is DioException) {
          ToastProvider.error(e.error.toString());
        } else {
          Log.e(e, StackTrace.current, 'feedback');
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _refreshController.dispose();
    _sc.dispose();
    super.dispose();
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
            Icons.arrow_back_ios_new,
            color: WpyTheme.of(context).get(WpyColorKey.defaultActionColor),
          ),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: _canEditKeyword
            ? _buildSearchTitle()
            : WButton(
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
                  child: Text(title,
                      style: TextUtil.base.bold.label(context).sp(16)),
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
                    Text('跟帖',
                        style: TextUtil.base.bold
                            .customColor(WpyTheme.of(context)
                                .get(WpyColorKey.cursorColor))
                            .sp(12)),
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
                    index--;
                    Widget post = PostCardNormal(_list[index]);
                    return post;
                  },
                  childCount: _list.length + 1,
                  findChildIndexCallback: (key) {
                    return _list.indexWhere((m) =>
                        'srm-${m.id}' == (key as ValueKey<String>).value);
                  },
                ),
              ));
        } else {
          body = Center(
            child: Text('未检索到相关问题',
                style: TextUtil.base.regular.infoText(context)),
          );
        }
        break;
      case SearchPageStatus.error:
        body = Center(child: Text("error"));
        break;
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, true);
      },
      child: GestureDetector(
        child: Scaffold(
            appBar: appBar,
            backgroundColor:
                WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
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

  Widget _buildSearchTitle() {
    return Container(
      height: 34,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
        borderRadius: BorderRadius.circular(17),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        textInputAction: TextInputAction.search,
        style: TextUtil.base.label(context).NotoSansSC.w400.sp(15),
        decoration: InputDecoration(
          hintText: '搜索冒泡',
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          prefixIcon: Icon(
            Icons.search,
            size: 18,
            color: WpyTheme.of(context).get(WpyColorKey.infoTextColor),
          ),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : WButton(
                  onPressed: () {
                    setState(() => _searchController.clear());
                    _searchFocus.requestFocus();
                  },
                  child: Icon(
                    Icons.close_rounded,
                    size: 17,
                    color: WpyTheme.of(context).get(WpyColorKey.infoTextColor),
                  ),
                ),
        ),
        onChanged: (_) => setState(() {}),
        onSubmitted: _submitKeyword,
      ),
    );
  }
}
