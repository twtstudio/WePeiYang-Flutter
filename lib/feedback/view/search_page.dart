import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/search_bar.dart';
import 'package:we_pei_yang_flutter/feedback/view/search_result_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  ValueNotifier<List<String>> _searchHistoryList;
  SharedPreferences _prefs;

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
            _prefs.getStringList('feedback_search_history');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var searchBar = SearchBar(
      onSubmitted: (text) {
        _searchHistoryList.unequalAdd(text);
        Navigator.pushNamed(
          context,
          FeedbackRouter.searchResult,
          arguments: SearchResultPageArgs(
              text, '', '', S.current.feedback_search_result, 0),
        ).then((_) {
          Navigator.pop(context);
        });
      },
    );

    var topView = SafeArea(
        child: Stack(
      alignment: Alignment.topLeft,
      children: [
        searchBar,
        InkWell(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, left: 12),
            child: ImageIcon(
                AssetImage('assets/images/lake_butt_icons/back.png'),
                size: 18),
          ),
          onTap: () => Navigator.pop(context),
        ),
      ],
    ));

    const titleTextStyle = TextStyle(
        fontSize: 17.0,
        color: Color.fromRGBO(98, 103, 124, 1),
        fontWeight: FontWeight.bold);

    var searchHistoryIcon = Container(
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            S.current.feedback_search_history,
            style: titleTextStyle,
          ),
          InkWell(
            child: Icon(Icons.delete, size: 16),
            onTap: showClearDialog,
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
                style: TextStyle(
                    fontSize: 16.0,
                    color: Color.fromRGBO(98, 103, 124, 0.61),
                    fontWeight: FontWeight.normal),
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
                0);
            return InkResponse(
              radius: 30,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
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
                backgroundColor: Color.fromRGBO(234, 234, 234, 1),
                label: Text(list[list.length - index - 1],
                    style: TextUtil.base.normal.black2A.NotoSansSC.sp(16)),
                deleteIcon: Icon(Icons.close,
                    color: ColorUtil.lightTextColor, size: 16),
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
        children: [searchHistoryIcon, searchHistoryList],
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
    );

    return ColoredBox(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            topView,
            Expanded(
                child: ColoredBox(
                    color: ColorUtil.backgroundColor, child: searchHistory)),
          ],
        ));
  }

  showClearDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return LakeDialogWidget(
              title: '清除记录',
              confirmButtonColor: ColorUtil.selectionButtonColor,
              titleTextStyle:
                  TextUtil.base.normal.black2A.NotoSansSC.sp(18).w600,
              cancelText: S.current.feedback_cancel,
              confirmTextStyle:
                  TextUtil.base.normal.white.NotoSansSC.sp(16).w400,
              cancelTextStyle:
                  TextUtil.base.normal.black2A.NotoSansSC.sp(16).w400,
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
