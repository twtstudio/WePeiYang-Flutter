import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

List<Text> tagsList = List.filled(
    5,
    Text(
      "",
      style: TextUtil.base.w400.NotoSansSC.sp(16).grey97,
    ));
List<Text> hotIndexList = List.filled(
    5,
    Text(
      "",
      style: TextUtil.base.w400.NotoSansSC.sp(14).grey97,
    ));

List<SearchTag> tagUtils = [];

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

class _SearchBarState extends State<SearchBar> {
  TextEditingController _controller = TextEditingController();
  bool _showSearch;

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
    tagUtils = list;
    for (int total = 0; total < tagUtils.length && total < 5; total++) {
      tagsList[total] = Text(
        tagUtils[total].name,
        style: TextUtil.base.w500.NotoSansSC.sp(16).grey6C,
      );
      hotIndexList[total] = Text(
        "${tagUtils[total].id}",
        style: TextUtil.base.w500.NotoSansSC.sp(14).black2A,
      );
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
        padding: const EdgeInsets.only(left: 30, right: 12.0),
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintStyle: TextStyle().grey6C.NotoSansSC.w400.sp(16),
            hintText: S.current.feedback_search_hint,
            contentPadding: const EdgeInsets.all(0),
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
              ToastProvider.error(S.current.feedback_empty_keyword);
            }
          },
          onChanged: (content) {
            if (content.isNotEmpty) {
              widget.onChanged?.call(content);
            }
          },
          textInputAction: TextInputAction.search,
        ),
      ),
    );
    var searchList = ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _controller.text = tagUtils[index].name;
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 3, 3, 10),
            child: Row(
              children: [
                SizedBox(width: 2),
                SvgPicture.asset(
                  "assets/svg_pics/lake_butt_icons/hashtag.svg",
                  width: 14,
                ),
                SizedBox(width: 4),
                Center(child: tagsList[index]),
                Spacer(),
                hotIndexList[index],
                SizedBox(width: 6)
              ],
            ),
          ),
        );
      },
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
        searchInputField,
        _showSearch
            ? Padding(
                padding: const EdgeInsets.only(top: 14),
                child: searchList,
              )
            : SizedBox(),
      ],
    );
  }
}
