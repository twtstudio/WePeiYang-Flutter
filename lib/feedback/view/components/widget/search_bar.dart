import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

import '../../../feedback_router.dart';
import '../../search_result_page.dart';

List<SearchTag> tagUtil = [];

typedef SubmitCallback = void Function(String);
typedef ChangeCallback = void Function(String);

class SearchBar extends StatefulWidget {
  final SubmitCallback onSubmitted;
  final VoidCallback tapField;
  final ChangeCallback onChanged;

  const SearchBar({Key key, this.onSubmitted, this.tapField, this.onChanged})
      : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar>
    with SingleTickerProviderStateMixin {
  TextEditingController _controller = TextEditingController();
  bool _showSearch;
  List<Widget> tagList = [SizedBox(height: 4)];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _showSearch = false;
    super.initState();
    initSearchTag();
    _controller.addListener(() {
      _controller.text.startsWith('#')
          ? _showSearch = true
          : _showSearch = false;
      if (_showSearch) refreshSearchTag(_controller.text.substring(1));
    });
  }

  _searchTags(List<SearchTag> list) {
    tagList.clear();
    tagList.add(SizedBox(height: 4));
    tagUtil = list;
    for (int total = 0; total < min(tagUtil.length, 5); total++) {
      tagList.add(GestureDetector(
        onTap: () {
            _controller.text = tagUtil[total].name;
            Navigator.pushNamed(
              context,
              FeedbackRouter.searchResult,
              arguments: SearchResultPageArgs(
                '',
                '${tagUtil[total].id}',
                '',
                S.current.feedback_search_result,
                0
              ),
            ).then((_) {
              Navigator.pop(context);
            });},
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 20, 4),
          child: Row(
            children: [
              SvgPicture.asset(
                "assets/svg_pics/lake_butt_icons/hashtag.svg",
                width: 14,
              ),
              SizedBox(width: 16),
              Expanded(
                  child: Text(
                tagUtil[total].name,
                style: TextUtil.base.w500.NotoSansSC.sp(16).grey6C,
                overflow: TextOverflow.ellipsis,
              )),
              SizedBox(width: 4),
              Text(
                (tagUtil[total].point ?? 0).toString(),
                style: TextUtil.base.w500.NotoSansSC.sp(16).grey6C,
              )
            ],
          ),
        ),
      ));
    }
  }

  initSearchTag() {
    FeedbackService.searchTags(
        name: "",
        onResult: (list) {
          setState(() {
            _searchTags(list);
          });
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
        });
  }

  refreshSearchTag(String text) {
    FeedbackService.searchTags(
        name: text,
        onResult: (list) {
          setState(() {
            _searchTags(list);
          });
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
        });
  }

  @override
  Widget build(BuildContext context) {
    Widget searchInputField = ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 30,
      ),
      child: Padding(
          padding: const EdgeInsets.only(left: 38, right: 12),
          child: Consumer<FbHotTagsProvider>(
            builder: (_, data, __) => TextField(
              controller: _controller,
              style: TextStyle().black2A.NotoSansSC.w400.sp(16),
              decoration: InputDecoration(
                hintStyle: TextStyle().grey6C.NotoSansSC.w400.sp(15),
                hintText: data.recTag.name == ''
                    ? '加载推荐中，失败请下拉刷新'
                    : '#${data.recTag.name}#，输入“#”号搜索更多Tag',
                contentPadding: const EdgeInsets.only(right: 6),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(1080),
                ),
                fillColor: ColorUtil.searchBarBackgroundColor,
                filled: true,
                prefixIcon: Icon(
                  Icons.search,
                  size: 19,
                  color: ColorUtil.grey108,
                ),
              ),
              enabled: true,
              onSubmitted: (content) {
                if (content.isNotEmpty) {
                  widget.onSubmitted?.call(content);
                } else {
                  Navigator.pushNamed(
                    context,
                    FeedbackRouter.searchResult,
                    arguments: SearchResultPageArgs(
                      '',
                      '${data.recTag.id}',
                      '',
                      S.current.feedback_search_result,
                      0
                    ),
                  );
                }
              },
              onChanged: (content) {
                if (content.isNotEmpty) {
                  widget.onChanged?.call(content);
                }
              },
              textInputAction: TextInputAction.search,
            ),
          )),
    );
    if (widget.tapField != null) {
      searchInputField = InkWell(
        child: AbsorbPointer(
          child: searchInputField,
        ),
        onTap: widget.tapField,
      );
    }

    return Column(
      children: [
        Container(
            color: Colors.white,
            child: searchInputField,
            padding: EdgeInsets.symmetric(vertical: 6)),
        ColoredBox(
          color: ColorUtil.backgroundColor,
          child: AnimatedSize(
            curve: Curves.easeOutCirc,
            duration: Duration(milliseconds: 400),
            vsync: this,
            child: _showSearch
                ? Container(
              padding: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        )),
                    child: Column(children: tagList ?? [SizedBox()]))
                : SizedBox(),
          ),
        )
      ],
    );
  }
}
