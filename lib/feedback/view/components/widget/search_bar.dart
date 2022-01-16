import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

typedef SubmitCallback = void Function(String);

class SearchBar extends StatefulWidget {
  final SubmitCallback onSubmitted;
  final VoidCallback tapField;

  const SearchBar({Key key, this.onSubmitted, this.tapField})
      : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget searchInputField = ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 25,
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
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
          textInputAction: TextInputAction.search,
        ),
      ),
    );

    if (widget.tapField != null) {
      searchInputField = InkWell(
        child: AbsorbPointer(
          child: searchInputField,
        ),
        onTap: widget.tapField,
      );
    }

    return searchInputField;
  }
}
