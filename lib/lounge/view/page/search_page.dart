// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/building_data_provider.dart';
import 'package:we_pei_yang_flutter/lounge/server/hive_manager.dart';
import 'package:we_pei_yang_flutter/lounge/server/search_server.dart';
import 'package:we_pei_yang_flutter/lounge/model/area.dart';
import 'package:we_pei_yang_flutter/lounge/model/building.dart';
import 'package:we_pei_yang_flutter/lounge/model/classroom.dart';
import 'package:we_pei_yang_flutter/lounge/util/image_util.dart';
import 'package:we_pei_yang_flutter/lounge/util/theme_util.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/building_grid_view.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/search_page/clear_dialog.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/search_page/history_chips.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/search_page/search_bar.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/search_page/search_result.dart';

enum _PageState {
  history,
  searching,
  result,
  noResult,
  error,
}

class SearchPageProvider with ChangeNotifier {
  final BuildContext _context;
  final TextEditingController controller;
  final FocusNode focusNode;
  String _lastText = '';

  String get hintText => _hintText;
  String _hintText = '请输入';

  List<String> get historyList => _historyList;
  final List<String> _historyList = [];

  List<SearchResult> get searchResult => _searchResultList;
  final List<SearchResult> _searchResultList = [];

  _PageState get pageState => _pageState;
  _PageState _pageState = _PageState.history;

  SearchPageProvider._(this.controller, this.focusNode, this._context) {
    controller.addListener(() {
      // debugPrint('controller.text ${controller.text} lastText $lastText');
      if (controller.text != _lastText) {
        // '' -> 'a'
        if (_lastText.isEmpty && controller.text.isNotEmpty) {
          notifyListeners();
        }

        // 'b' -> ''
        if (_lastText.isNotEmpty && controller.text.isEmpty) {
          notifyListeners();
        }

        _lastText = controller.text;
      }
    });
    LoungeDB().db.searchHistory.then((list) {
      _historyList.addAll(list);
      notifyListeners();
    });
  }

  factory SearchPageProvider(BuildContext context) {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    return SearchPageProvider._(controller, focusNode, context);
  }

  void search([String? query]) async {
    query ??= controller.text;
    debugPrint('search $query');
    if (_historyList.contains(query)) {
      _historyList.remove(query);
    }
    _historyList.add(query);
    _pageState = _PageState.searching;
    _hintText = query;
    notifyListeners();
    LoungeDB().db.addSearchHistory(query);
    _searchResultList.clear();

    try {
      final resultStream = _context.read<BuildingData>().search(query);
      // 0.5s 搜索时间
      await Future.delayed(const Duration(milliseconds: 500));

      await for (var result in resultStream) {
        _searchResultList.add(result);
      }

      if (_searchResultList.isEmpty) {
        // 说明没有解析出任何匹配的形式
        _pageState = _PageState.error;
      } else if (resultsAllEmpty) {
        _pageState = _PageState.noResult;
      } else {
        _pageState = _PageState.result;
      }
    } catch (e) {
      debugPrint('$e');
      if (_searchResultList.isEmpty) {
        _pageState = _PageState.error;
      } else {
        _pageState = _PageState.result;
      }
    }

    notifyListeners();
  }

  void clearInput() {
    controller.clear();
    _pageState = _PageState.history;
    _hintText = '';
    focusNode.requestFocus();
    notifyListeners();
  }

  void clearHistory() async {
    final result = await showDialog<bool>(
      context: _context,
      builder: (_) => const ClearHistoryDialog(),
    );

    if (result == true) {
      await LoungeDB().db.clearHistory();
      _historyList.clear();
      notifyListeners();
    }
  }

  void autoInputTextField() {
    if (_pageState == _PageState.result) {
      controller.text = hintText;
    }
  }

  bool get resultsAllEmpty {
    return _searchResultList.fold(
      true,
      (previour, next) {
        final nextList = (next.data as List<dynamic>);
        return previour && nextList.isEmpty;
      },
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget body = Builder(builder: (context) {
      final state = context.select(
        (SearchPageProvider provider) => provider.pageState,
      );

      switch (state) {
        case _PageState.history:
          return const _SearchHistoryPage();
        case _PageState.searching:
          return const _SearchingPage();
        case _PageState.result:
          return const _SearchResultPage();
        case _PageState.noResult:
          return const _NoResultPage();
        case _PageState.error:
          return const _SearchErrorPage();
      }
    });

    body = AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      child: body,
    );

    return ChangeNotifierProvider(
      create: (_) => SearchPageProvider(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).baseBackgroundColor,
        appBar: AppBar(
          titleSpacing: 0,
          toolbarHeight: 70.w,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const SearchBarWidget(),
        ),
        body: body,
      ),
    );
  }
}

class _SearchHistoryPage extends StatefulWidget {
  const _SearchHistoryPage({Key? key}) : super(key: key);

  @override
  __SearchHistoryPageState createState() => __SearchHistoryPageState();
}

class __SearchHistoryPageState extends State<_SearchHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final buttons = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Text(
            '历史记录',
            style: TextStyle(
              color: Theme.of(context).searchHistoryTitle,
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            context.read<SearchPageProvider>().clearHistory();
          },
          child: Container(
            width: 40.w,
            height: 30.w,
            alignment: Alignment.center,
            child: Image.asset(
              Images.crash,
              width: 12.w,
              fit: BoxFit.cover,
              color: Theme.of(context).searchIcon,
            ),
          ),
        ),
      ],
    );

    Widget historyChips = const HistoryChips();

    historyChips = Padding(
      padding: EdgeInsets.only(top: 10.w),
      child: historyChips,
    );

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 23.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buttons,
            historyChips,
          ],
        ),
      ),
    );
  }
}

class _SearchingPage extends StatelessWidget {
  const _SearchingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Loading();
  }
}

class _SearchResultPage extends StatelessWidget {
  const _SearchResultPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (_, index) {
        return Builder(builder: (context) {
          final result = context.select(
            (SearchPageProvider provider) {
              if (index >= provider.searchResult.length) {
                return 'error';
              }
              return provider.searchResult[index];
            },
          ) as SearchResult;

          switch (result.type) {
            case SearchResultType.building:
              final data = (result.data as List).cast<Building>();
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: BuildingGrid(data),
              );
            case SearchResultType.area:
              final data = (result.data as List).cast<Area>();
              return AreasGrid(data);
            case SearchResultType.room:
              final data = (result.data as List).cast<Classroom>();
              return RoomList(data);
          }
        });
      },
      itemCount: context.select(
        (SearchPageProvider provider) => provider.searchResult.length,
      ),
    );
  }
}

class _NoResultPage extends _SearchErrorForm {
  const _NoResultPage({Key? key}) : super(key: key);

  @override
  String get title => '“没有找到这件教室···”';
}

class _SearchErrorPage extends _SearchErrorForm {
  const _SearchErrorPage({Key? key}) : super(key: key);

  @override
  String get title => '“请按照以下规则输入”';
}

abstract class _SearchErrorForm extends StatelessWidget {
  const _SearchErrorForm({
    Key? key,
  }) : super(key: key);

  final title = '';
  final content = '请输入阿拉伯数字和字母\n以查找教学楼或教室\n\n如果你想找到26教B区'
      '120教室：\n可输入26教b120，26b120，26120或120...';

  @override
  Widget build(BuildContext context) {
    final contentText = Text(
      content,
      style: TextStyle(
        color: Theme.of(context).searchErrorPageContent,
        fontSize: 13.sp,
        fontWeight: FontWeight.normal,
      ),
    );

    final titleText = Text(
      title,
      style: TextStyle(
        color: Theme.of(context).searchErrorPageTitle,
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 39.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 60.w),
          titleText,
          SizedBox(height: 27.w),
          Padding(
            padding: EdgeInsets.only(left: 9.w),
            child: contentText,
          ),
        ],
      ),
    );
  }
}
