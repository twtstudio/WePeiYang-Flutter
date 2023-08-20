import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import '../../../commons/widgets/w_button.dart';
import '../../../commons/widgets/wpy_pic.dart';
import '../../feedback_router.dart';
import '../components/widget/lost_and_found_search_bar.dart';
import 'lost_and_found_search_notifier.dart';
import 'lost_and_found_search_result_page.dart';

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

    final String type = context.read<LostAndFoundModel2>().currentType;

    var searchBar = LostAndFoundSearchBar(
      onSubmitted: (text) {
        _foundSearchHistoryList.unequalAdd(text);
        Navigator.pushNamed(
          context,
          FeedbackRouter.lostAndFoundSearchResult,
          arguments: LostAndFoundSearchResultPageArgs(
              context.read<LostAndFoundModel2>().currentType,
              context.read<LostAndFoundModel2>().currentCategory[context.read<LostAndFoundModel2>().currentType]!,
              text),
        ).then((_) {
          Navigator.pop(context);
        });
      },
    );

    var topView = SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
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
            ]
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(bottom: 10.h, start: 20.h, end: 20.h),
              child: Selector<LostAndFoundModel2,String>(
                selector: (context, model){
                  return model.currentCategory[type]!;
                },
                builder:(context, category, _){
                  return Flex(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Expanded(child: LostAndFoundTag(category: '全部',type: type), flex: 4,),
                      Expanded(child: LostAndFoundTag(category: '生活日用',type: type), flex: 5,),
                      Expanded(child: LostAndFoundTag(category: '数码产品',type: type), flex: 5,),
                      Expanded(child: LostAndFoundTag(category: '钱包卡证',type: type), flex: 5,),
                      Expanded(child: LostAndFoundTag(category: '其他',type: type), flex: 4,),
                    ],
                  );
                },
              ),
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
            return InkResponse(
              radius: 30,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                _foundSearchHistoryList.unequalAdd(list[list.length - index - 1]);
                Navigator.pushNamed(
                  context,
                  FeedbackRouter.lostAndFoundSearchResult,
                  arguments: LostAndFoundSearchResultPageArgs(
                      context.read<LostAndFoundModel2>().currentType,
                      context.read<LostAndFoundModel2>().currentCategory[context.read<LostAndFoundModel2>().currentType]!,
                      list[list.length - index - 1]),
                ).then((_) {
                  Navigator.pop(context);
                });
              },
              child: Chip(
                elevation: 1,
                backgroundColor: Color.fromARGB(248, 248, 248, 248),
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
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
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
                    color: Colors.white, child: searchHistory)),
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


class LostAndFoundTag extends StatefulWidget {
  final String type;
  final String category;
  final String? tag;
  const LostAndFoundTag({Key? key, required this.type, required this.category, this.tag,}) : super(key: key);

  @override
  LostAndFoundTagState createState() => LostAndFoundTagState();
}

class LostAndFoundTagState extends State<LostAndFoundTag> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w,right: 8.w),
      child: WButton(
        onPressed: () {
          context.read<LostAndFoundModel2>().resetCategory(type: widget.type, category: widget.category);
          context.read<LostAndFoundModel2>().clearByType(widget.type);
        },
        child: Container(
          height: 30.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: widget.category == context.read<LostAndFoundModel2>().currentCategory[widget.type]
                  ? Color.fromARGB(255, 234, 243, 254)
                  : Color.fromARGB(248, 248, 248, 248)
          ),
          child: Center(
            child: Text(
                widget.category,
                style: widget.category == context.read<LostAndFoundModel2>().currentCategory[widget.type]
                    ? TextUtil.base.normal.NotoSansSC.w400.sp(8.5.sp).blue2C
                    : TextUtil.base.normal.NotoSansSC.w400.sp(8.5.sp).black2A
            ),
          ),
        ),
      ),
    );
  }
}