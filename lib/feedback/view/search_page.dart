import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
            text,
            '',
            S.current.feedback_search_result,
          ),
        ).then((_) {
          Navigator.pop(context);
        });
      },
    );
    var sharp =  SvgPicture.asset(
      "assets/svg_pics/lake_butt_icons/sharp.svg",
      width: 14,
    );
    var topView = SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
               mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height:6.25.w),
                  InkWell(
                    child: Row(
                      children: [
                        SizedBox(width: 15.w),
                        ImageIcon(AssetImage('assets/images/lake_butt_icons/back.png'),
                            size: 18),
                        SizedBox(width: 20.w),
                      ],
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                  SizedBox(height:36.25.w),
                  sharp,
                  SizedBox(height:20.w),
                  sharp,
                  SizedBox(height:20.w),
                  sharp,
                  SizedBox(height:20.w),
                  sharp,
                  SizedBox(height:20.w),
                  sharp,
                ],
              ),
              ConstrainedBox(constraints: BoxConstraints(maxWidth: 320.w,),
                child: searchBar,
              )

            ],
          )
    );

    const titleTextStyle = TextStyle(
        fontSize: 17.0,
        color: Color.fromRGBO(98, 103, 124, 1),
        fontWeight: FontWeight.bold);

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

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Wrap(
            spacing: 6,
            children: List.generate(
              list.length,
              (index) {
                var searchArgument = SearchResultPageArgs(
                  list[list.length - index - 1],
                  '',
                  S.current.feedback_search_result,
                );
                if (index == 0)
                  return SizedBox(width: double.infinity);
                index--;
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
                    deleteIcon: Icon(Icons.close, color: ColorUtil.lightTextColor, size: 16),
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
            ),
          ),
        );
      },
    );

    var searchHistory = Padding(
      child: Column(
        children: [searchHistoryIcon, searchHistoryList],
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
    );

    return Container(
      color: ColorUtil.white253,
        child:
        Column(
          children: [
          //  searchList,
            topView,
            searchHistory,
          ],
        ));
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
