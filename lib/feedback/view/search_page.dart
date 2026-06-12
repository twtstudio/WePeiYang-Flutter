import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/search_bar.dart'
    as wpySearchBar;
import 'package:we_pei_yang_flutter/feedback/view/search_result_page.dart';

import '../../commons/themes/wpy_theme.dart';
import '../../commons/widgets/w_button.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final ValueNotifier<List<String>> _searchHistoryList;
  SharedPreferencesWithCache? _prefs;
  bool _historyChangedBeforePrefs = false;

  _addHistory() {
    final prefs = _prefs;
    if (prefs == null) {
      _historyChangedBeforePrefs = true;
      return;
    }
    prefs.setStringList('feedback_search_history', _searchHistoryList.value);
  }

  @override
  void initState() {
    super.initState();
    _searchHistoryList = ValueNotifier([])..addListener(_addHistory);
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    if (!mounted) return;
    _prefs = prefs;
    if (_historyChangedBeforePrefs) {
      _addHistory();
      return;
    }
    final history = prefs.getStringList('feedback_search_history');
    if (history == null) {
      _addHistory();
    } else {
      _searchHistoryList.value = history;
    }
  }

  int? _postIdFromKeyword(String keyword) {
    if (!keyword.startsWith('#MP')) return null;
    return int.tryParse(keyword.substring(3));
  }

  void _openKeyword(String keyword, {required bool fromHistory}) {
    final postId = _postIdFromKeyword(keyword);
    if (postId != null) {
      FeedbackService.getPostById(
        id: postId,
        onResult: (post) {
          if (!fromHistory) _searchHistoryList.unequalAdd(keyword);
          if (!mounted) return;
          Navigator.popAndPushNamed(
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

    if (!fromHistory) _searchHistoryList.unequalAdd(keyword);
    Navigator.pushNamed(
      context,
      FeedbackRouter.searchResult,
      arguments: SearchResultPageArgs(keyword, '', '', '搜索结果', 0, 0),
    ).then((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _searchHistoryList.removeListener(_addHistory);
    _searchHistoryList.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var searchBar = wpySearchBar.SearchBar(
      onSubmitted: (text) {
        _openKeyword(text, fromHistory: false);
      },
    );

    var topView = SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            searchBar,
            WButton(
              child: Padding(
                padding: const EdgeInsets.only(top: 9, left: 9),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ));

    var searchHistoryContainer = Container(
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '历史记录',
            style: TextUtil.base.primaryAction(context).w600.sp(17),
          ),
          IconButton(
            onPressed: showClearDialog,
            splashColor:
                WpyTheme.of(context).get(WpyColorKey.primaryLighterActionColor),
            icon: Icon(
              Icons.delete,
              size: 24,
              color: WpyTheme.of(context).primary,
            ),
          ),
        ],
      ),
    );

    var searchHistoryList = ValueListenableBuilder(
      valueListenable: _searchHistoryList,
      builder: (_, List<String> list, __) {
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Center(
              child: Text(
                "暂无历史记录",
                style: TextUtil.base.secondary(context).normal.sp(16),
              ),
            ),
          );
        }

        List<Widget> searchHistory = [SizedBox(width: double.infinity)];
        searchHistory.addAll(List.generate(
          list.length,
          (index) {
            var searchArgument = SearchResultPageArgs(
                list[list.length - index - 1], '', '', '搜索结果', 0, 0);
            return InkResponse(
              radius: 30,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                _openKeyword(searchArgument.keyword, fromHistory: true);
              },
              child: Chip(
                shadowColor: WpyTheme.of(context)
                    .get(WpyColorKey.secondaryBackgroundColor)
                    .withValues(alpha: 0.5),
                visualDensity: VisualDensity.comfortable,
                avatar: Icon(Icons.history,
                    color: WpyTheme.of(context)
                        .get(WpyColorKey.secondaryTextColor),
                    size: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                        color: WpyTheme.of(context)
                            .get(WpyColorKey.secondaryBackgroundColor),
                        width: 1)),
                elevation: 1,
                backgroundColor:
                    WpyTheme.of(context).get(WpyColorKey.tagLabelColor),
                label: Text(list[list.length - index - 1],
                    style:
                        TextUtil.base.normal.label(context).NotoSansSC.sp(16)),
                deleteIcon: Icon(Icons.close,
                    color: WpyTheme.of(context)
                        .get(WpyColorKey.secondaryTextColor),
                    size: 16),
                onDeleted: () {
                  setState(() {
                    list.removeAt(list.length - index - 1);
                  });
                  _prefs?.setStringList('feedback_search_history', list);
                  ToastProvider.success("删除成功");
                },
              ),
            );
          },
        ));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Wrap(spacing: 10, runSpacing: 8, children: searchHistory),
        );
      },
    );

    var searchHistory = Padding(
      child: Column(
        children: [searchHistoryContainer, searchHistoryList],
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
    );

    return Scaffold(
      body: ColoredBox(
          color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              topView,
              Expanded(
                  child: ColoredBox(
                      color: WpyTheme.of(context)
                          .get(WpyColorKey.secondaryBackgroundColor),
                      child: searchHistory)),
            ],
          )),
    );
  }

  showClearDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return LakeDialogWidget(
              title: '清除记录',
              confirmButtonColor:
                  WpyTheme.of(context).get(WpyColorKey.primaryTextButtonColor),
              titleTextStyle:
                  TextUtil.base.normal.label(context).NotoSansSC.sp(18).w600,
              cancelText: '取消',
              confirmTextStyle:
                  TextUtil.base.normal.reverse(context).NotoSansSC.sp(16).w400,
              cancelTextStyle:
                  TextUtil.base.normal.label(context).NotoSansSC.sp(16).w400,
              confirmText: '确定',
              cancelFun: () {
                Navigator.pop(context);
              },
              confirmFun: () {
                _searchHistoryList.value.clear();
                _addHistory();
                setState(() {});
                Navigator.pop(context);
              },
              content: Text('确认清除所有搜索记录吗？'));
        });
  }
}
