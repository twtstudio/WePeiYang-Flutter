import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/lost_and_found/lost_and_found_router.dart';
import 'package:we_pei_yang_flutter/lost_and_found/view/components/widget/lost_and_found_search_bar.dart';
import 'package:we_pei_yang_flutter/lost_and_found/view/lost_and_found_search_notifier.dart';
import 'package:we_pei_yang_flutter/lost_and_found/view/lost_and_found_search_result_page.dart';

import '../../commons/themes/wpy_theme.dart';

class LostAndFoundSearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LostAndFoundSearchPageState();
}

class _LostAndFoundSearchPageState extends State<LostAndFoundSearchPage> {
  late final ValueNotifier<List<String>> _foundSearchHistoryList;
  late final SharedPreferences _prefs;

  _addHistory() {
    _prefs.setStringList(
        'feedback_found_search_history', _foundSearchHistoryList.value);
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
          LAFRouter.lostAndFoundSearchResult,
          arguments: LostAndFoundSearchResultPageArgs(
              context.read<LostAndFoundModel2>().currentType,
              context.read<LostAndFoundModel2>().currentCategory[
                  context.read<LostAndFoundModel2>().currentType]!,
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
              padding: EdgeInsets.only(top: 12.h, left: 12.h),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                size: 27.r,
              ),
            ),
            onTap: () => Navigator.pop(context),
          ),
        ]),
        Padding(
          padding:
              EdgeInsetsDirectional.only(bottom: 10.h, start: 20.h, end: 20.h),
          child: Selector<LostAndFoundModel2, String>(
            selector: (context, model) {
              return model.currentCategory[type]!;
            },
            builder: (context, category, _) {
              return Flex(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                direction: Axis.horizontal,
                children: <Widget>[
                  Expanded(
                    child: LostAndFoundTag(category: '全部', type: type),
                    flex: 4,
                  ),
                  Expanded(
                    child: LostAndFoundTag(category: '生活日用', type: type),
                    flex: 5,
                  ),
                  Expanded(
                    child: LostAndFoundTag(category: '数码产品', type: type),
                    flex: 5,
                  ),
                  Expanded(
                    child: LostAndFoundTag(category: '钱包卡证', type: type),
                    flex: 5,
                  ),
                  Expanded(
                    child: LostAndFoundTag(category: '其他', type: type),
                    flex: 4,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    ));

    var searchHistoryContainer = Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 8.h),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '历史记录',
            style: TextUtil.base.primary(context).w600.sp(19),
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
            padding: EdgeInsets.only(top: 12.0.r),
            child: Center(
              child: Text(
                "暂无历史记录",
                style: TextUtil.base.normal.secondary(context).sp(16),
              ),
            ),
          );
        }

        List<Widget> searchHistory = [SizedBox(width: double.infinity)];
        searchHistory.addAll(List.generate(
          list.length,
          (index) {
            return InkResponse(
              radius: 30.r,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                _foundSearchHistoryList
                    .unequalAdd(list[list.length - index - 1]);
                Navigator.pushNamed(
                  context,
                  LAFRouter.lostAndFoundSearchResult,
                  arguments: LostAndFoundSearchResultPageArgs(
                      context.read<LostAndFoundModel2>().currentType,
                      context.read<LostAndFoundModel2>().currentCategory[
                          context.read<LostAndFoundModel2>().currentType]!,
                      list[list.length - index - 1]),
                ).then((_) {
                  Navigator.pop(context);
                });
              },
              child: Chip(
                shadowColor: Colors.transparent,
                elevation: 1,
                backgroundColor: WpyTheme.of(context)
                    .get(WpyColorKey.primaryBackgroundColor),
                label: Text(list[list.length - index - 1],
                    style: TextUtil.base.normal.infoText(context).PingFangSC.sp(14)),
              ),
            );
          },
        ));

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.0.w),
          child: Wrap(spacing: 6.w, children: searchHistory),
        );
      },
    );

    var searchHistory = Padding(
      child: Column(
        children: [searchHistoryContainer, searchHistoryList],
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
    );

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            topView,
            Expanded(
              child: SingleChildScrollView(
                child: searchHistory,
              ),
            ),
          ],
        ),
      ),
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
                _foundSearchHistoryList.value.clear();
                _addHistory();
                setState(() {});
                Navigator.pop(context);
              },
              content: Text('确认清除所有搜索记录吗？'));
        });
  }
}

class LostAndFoundTag extends StatefulWidget {
  final String type;
  final String category;
  final String? tag;

  const LostAndFoundTag({
    Key? key,
    required this.type,
    required this.category,
    this.tag,
  }) : super(key: key);

  @override
  LostAndFoundTagState createState() => LostAndFoundTagState();
}

class LostAndFoundTagState extends State<LostAndFoundTag> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, right: 8.w),
      child: WButton(
        onPressed: () {
          context
              .read<LostAndFoundModel2>()
              .resetCategory(type: widget.type, category: widget.category);
          context.read<LostAndFoundModel2>().clearByType(widget.type);
        },
        child: Container(
          height: 30.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              color: widget.category ==
                      context
                          .read<LostAndFoundModel2>()
                          .currentCategory[widget.type]
                  ? WpyTheme.of(context).get(WpyColorKey.tagLabelColor)
                  : WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor)),
          child: Center(
            child: Text(widget.category,
                style: widget.category ==
                        context
                            .read<LostAndFoundModel2>()
                            .currentCategory[widget.type]
                    ? TextUtil.base.normal.NotoSansSC.w400
                        .sp(10)
                        .primaryAction(context)
                    : TextUtil.base.normal.NotoSansSC.w400
                        .sp(10)
                        .label(context)),
          ),
        ),
      ),
    );
  }
}
