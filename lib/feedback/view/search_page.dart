import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/search_bar.dart'
    as wpySearchBar;
import 'package:we_pei_yang_flutter/feedback/view/search_result_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

import '../../commons/themes/wpy_theme.dart';
import '../../commons/widgets/w_button.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final ValueNotifier<List<String>> _searchHistoryList;
  late final SharedPreferences _prefs;

  _addHistory() {
    _prefs.setStringList('feedback_search_history', _searchHistoryList.value);
  }

  @override
  void initState() {
    _searchHistoryList = ValueNotifier([])
      ..addListener(() {
        _addHistory();
      });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _prefs = await SharedPreferences.getInstance();
      if (_prefs.getStringList('feedback_search_history') == null) {
        _addHistory();
      } else {
        _searchHistoryList.value =
            _prefs.getStringList('feedback_search_history')!;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var searchBar = wpySearchBar.SearchBar(
      onSubmitted: (text) {
        if (text.startsWith('#MP') &&
            RegExp(r'^-?[0-9]+').hasMatch(text.substring(3))) {
          FeedbackService.getPostById(
            id: int.parse(text.substring(3)),
            onResult: (post) {
              _searchHistoryList.unequalAdd(text);
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
        } else {
          _searchHistoryList.unequalAdd(text);
          Navigator.pushNamed(
            context,
            FeedbackRouter.searchResult,
            arguments: SearchResultPageArgs(
                text, '', '', S.current.feedback_search_result, 0, 0),
          ).then((_) {
            Navigator.pop(context);
          });
        }
      },
    );

    var topView = SafeArea(
        child: Stack(
      alignment: Alignment.topLeft,
      children: [
        searchBar,
        WButton(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, left: 12),
            child: Icon(
              CupertinoIcons.back,
              color: ColorUtil.black25Color,
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
            S.current.feedback_search_history,
            style: TextUtil.base.primaryAction(context).w600.sp(17),
          ),
          WButton(
            child: Icon(Icons.delete, size: 16),
            onPressed: showClearDialog,
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
                style: TextUtil.base.blue98Opacity061.normal.sp(16),
              ),
            ),
          );
        }

        List<Widget> searchHistory = [SizedBox(width: double.infinity)];
        searchHistory.addAll(List.generate(
          list.length,
          (index) {
            var searchArgument = SearchResultPageArgs(
                list[list.length - index - 1],
                '',
                '',
                S.current.feedback_search_result,
                0,
                0);
            return InkResponse(
              radius: 30,
              highlightColor: ColorUtil.transparent,
              splashColor: ColorUtil.transparent,
              onTap: () {
                if (searchArgument.keyword.startsWith('#MP') &&
                    RegExp(r'^-?[0-9]+')
                        .hasMatch(searchArgument.keyword.substring(3))) {
                  FeedbackService.getPostById(
                    id: int.parse(searchArgument.keyword.substring(3)),
                    onResult: (post) {
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
                Navigator.pushNamed(
                  context,
                  FeedbackRouter.searchResult,
                  arguments: searchArgument,
                ).then((_) {
                  Navigator.pop(context);
                });
              },
              child: Chip(
                elevation: 1,
                backgroundColor: ColorUtil.white234,
                label: Text(list[list.length - index - 1],
                    style: TextUtil.base.normal.label(context).NotoSansSC.sp(16)),
                deleteIcon: Icon(Icons.close,
                    color: WpyTheme.of(context)
                        .get(WpyThemeKeys.secondaryTextColor),
                    size: 16),
                onDeleted: () {
                  setState(() {
                    list.removeAt(list.length - index - 1);
                  });
                  _prefs.setStringList('feedback_search_history', list);
                  ToastProvider.success("删除成功");
                },
              ),
            );
          },
        ));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Wrap(spacing: 6, children: searchHistory),
        );
      },
    );

    var searchHistory = Padding(
      child: Column(
        children: [searchHistoryContainer, searchHistoryList],
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
    );

    return ColoredBox(
        color: WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            topView,
            Expanded(
                child: ColoredBox(
                    color: WpyTheme.of(context)
                        .get(WpyThemeKeys.secondaryBackgroundColor),
                    child: searchHistory)),
          ],
        ));
  }

  showClearDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return LakeDialogWidget(
              title: '清除记录',
              confirmButtonColor: WpyTheme.of(context).get(WpyThemeKeys.primaryTextButtonColor),
              titleTextStyle: TextUtil.base.normal.label(context).NotoSansSC.sp(18).w600,
              cancelText: S.current.feedback_cancel,
              confirmTextStyle:
                  TextUtil.base.normal.reverse(context).NotoSansSC.sp(16).w400,
              cancelTextStyle:
                  TextUtil.base.normal.label(context).NotoSansSC.sp(16).w400,
              confirmText: S.current.feedback_ok,
              cancelFun: () {
                Navigator.pop(context);
              },
              confirmFun: () {
                _searchHistoryList.value.clear();
                _addHistory();
                setState(() {});
                Navigator.pop(context);
              },
              content: Text(S.current.feedback_clear_history));
        });
  }
}
