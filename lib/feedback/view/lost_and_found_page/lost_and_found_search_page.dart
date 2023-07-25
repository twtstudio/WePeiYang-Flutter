import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import '../../../commons/widgets/wpy_pic.dart';
import '../components/widget/lost_and_found_search_bar.dart';

class LostAndFoundSearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LostAndFoundSearchPageState();
}

class _LostAndFoundSearchPageState extends State<LostAndFoundSearchPage> {
  late final ValueNotifier<List<String>> _foundSearchHistoryList;
  late final SharedPreferences _prefs;

  _addHistory() {
    _prefs.setStringList('feedback_found_search_history', _foundSearchHistoryList.value);
  }

  @override
  void initState() {
    _foundSearchHistoryList = ValueNotifier([])
      ..addListener(() {
        _addHistory();
      });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _prefs = await SharedPreferences.getInstance();
      if (_prefs.getStringList('feedback_found_search_history') == null) {
        _addHistory();
      } else {
        _foundSearchHistoryList.value =
        _prefs.getStringList('feedback_found_search_history')!;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var searchBar = LostAndFoundSearchBar(
      onSubmitted: (text) {
        _foundSearchHistoryList.unequalAdd(text);
        // Navigator.pushNamed(
        //   context,
        //   FeedbackRouter.searchResult,
        //   arguments: SearchResultPageArgs(
        //       text, '', '', S.current.feedback_search_result, 0, 0),
        // ).then((_) {
        //   Navigator.pop(context);
        // });
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
                child: Icon(
                  CupertinoIcons.back,
                  color: Color(0XFF252525),
                  size: 27,
                ),
              ),
              onTap: () => Navigator.pop(context),
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
            style: TextUtil.base.black00.w600.sp(19),
          ),
          InkWell(
            child: WpyPic(
              'assets/svg_pics/delete.svg',
              width: 21.w,
              height: 21.w,
            ),
            onTap: showClearDialog,
          ),
        ],
      ),
    );

    var searchHistoryList = ValueListenableBuilder(
      valueListenable: _foundSearchHistoryList,
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
            // var searchArgument = SearchResultPageArgs(
            //     list[list.length - index - 1],
            //     '',
            //     '',
            //     S.current.feedback_search_history,
            //     0,
            //     0);
            return InkResponse(
              radius: 30,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                // Navigator.pushNamed(
                //   context,
                //   FeedbackRouter.searchResult,
                //   arguments: searchArgument,
                // ).then((_) {
                //   Navigator.pop(context);
                // });
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
                  _prefs.setStringList('feedback_found_search_history', list);
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
        children:
        [searchHistoryContainer,
          searchHistoryList
        ],
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
                _foundSearchHistoryList.value.clear();
                _addHistory();
                setState(() {});
                Navigator.pop(context);
              },
              content: Text(S.current.feedback_clear_history));
        });
  }
}
