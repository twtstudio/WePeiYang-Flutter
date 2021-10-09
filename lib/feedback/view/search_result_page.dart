import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/loading.dart';

import 'components/post_card.dart';

class SearchResultPage extends StatefulWidget {
  final SearchResultPageArgs args;

  SearchResultPage(this.args);

  @override
  _SearchResultPageState createState() =>
      _SearchResultPageState(args.keyword, args.tagId, args.title);
}

class SearchResultPageArgs {
  final String keyword;
  final String tagId;
  final String title;

  SearchResultPageArgs(this.keyword, this.tagId, this.title);
}

enum SearchPageStatus {
  loading,
  idle,
  error,
}

class _SearchResultPageState extends State<SearchResultPage> {
  final String keyword;
  final String tagId;
  final String title;

  int currentPage = 1, totalPage = 1;
  SearchPageStatus status;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<Post> _list = [];

  _SearchResultPageState(this.keyword, this.tagId, this.title);

  _onRefresh() {
    currentPage = 1;
    FeedbackService.getPosts(
      tagId: tagId,
      page: currentPage,
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
        tagId: tagId,
        page: currentPage,
        keyword: keyword,
        onSuccess: (list, page) {
          totalPage = page;
          setState(() => _list.addAll(list));
          _refreshController.loadComplete();
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
          _refreshController.loadFailed();
        },
      );
    } else {
      _refreshController.loadComplete();
    }
  }

  @override
  void initState() {
    super.initState();
    status = SearchPageStatus.loading;
    currentPage = 1;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FeedbackService.getPosts(
        tagId: tagId,
        page: currentPage,
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
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: ColorUtil.mainColor,
        ),
        onPressed: () {
          Navigator.pop(context, true);
        },
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorUtil.boldTextColor,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      primary: true,
    );

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
            child: ListView.builder(
              itemBuilder: (context, index) {
                Widget post = PostCard.simple(_list[index]);

                return post;
              },
              itemCount: _list.length,
            ),
          );
        } else {
          body = Center(
            child: Text(
              S.current.feedback_no_post,
              style: FontManager.YaHeiRegular.copyWith(
                color: ColorUtil.lightTextColor,
              ),
            ),
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
