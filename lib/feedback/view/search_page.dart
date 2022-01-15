import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/search_bar.dart';
import 'package:we_pei_yang_flutter/feedback/view/search_result_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/main.dart';
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
            text,
            '',
            S.current.feedback_search_result,
          ),
        ).then((_) {
          Navigator.pop(context);
        });
      },
      rightWidget: TextButton(
        child: Text(
          S.current.feedback_cancel,
          style: FontManager.YaHeiRegular.copyWith(
            fontWeight: FontWeight.bold,
            color: ColorUtil.boldTextColor,
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );

    const titleTextStyle = TextStyle(
        fontSize: 13.0,
        color: Color.fromRGBO(98, 103, 124, 1),
        fontWeight: FontWeight.bold);

    var historyTextStyle = FontManager.YaHeiRegular.copyWith(
      fontSize: 15.0,
      color: Color.fromRGBO(48, 60, 102, 1),
    );

    var searchHistoryIcon = Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      margin: EdgeInsets.only(top: 0),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            S.current.feedback_search_history,
            style: titleTextStyle,
          ),
          InkWell(
            child: Image.asset(
              'lib/feedback/assets/img/trash_can.png',
              fit: BoxFit.cover,
              height: 18,
              width: 18,
            ),
            onTap: showClearDialog,
          ),
        ],
      ),
    );

    var searchHistoryList = ValueListenableBuilder(
      valueListenable: _searchHistoryList,
      builder: (_, List<String> list, __) {
        if (list.isEmpty) {
          return Center(
            child: Text(
              "暂无历史记录",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color.fromRGBO(98, 103, 124, 0.61),
                  fontWeight: FontWeight.normal),
            ),
          );
        }

        var historyItem = (String item) => Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item, style: historyTextStyle),
                  Image.asset(
                    'lib/feedback/assets/img/arrow_nw.png',
                    fit: BoxFit.cover,
                    height: 14,
                    width: 14,
                  )
                ],
              ),
            );

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: list.length,
          shrinkWrap: true,
          itemBuilder: (_, index) {
            var searchArgument = SearchResultPageArgs(
              list[list.length - index - 1],
              '',
              S.current.feedback_search_result,
            );

            return InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  FeedbackRouter.searchResult,
                  arguments: searchArgument,
                ).then((_) {
                  Navigator.pop(context);
                });
              },
              child: historyItem(list[list.length - index - 1]),
            );
          },
          physics: NeverScrollableScrollPhysics(),
        );
      },
    );

    var searchHistory = Padding(
      child: Column(
        children: [searchHistoryIcon, searchHistoryList],
      ),
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
    );

    return DefaultTextStyle(
      style: FontManager.YaHeiRegular,
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(top: WePeiYangApp.paddingTop),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [searchBar, searchHistory],
          ),
        ),
      ),
    );
  }

  showClearDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.current.feedback_clear_history),
          actions: <Widget>[
            TextButton(
              child: Text(S.current.feedback_cancel),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(S.current.feedback_ok),
              onPressed: () {
                _searchHistoryList.value.clear();
                _addHistory();
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
