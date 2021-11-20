import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

typedef SubmitCallback = void Function(String);

class SearchBar extends StatefulWidget {
  final SubmitCallback onSubmitted;
  final Widget rightWidget;
  final VoidCallback tapField;

  const SearchBar({Key key, this.onSubmitted, this.rightWidget, this.tapField})
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
    Widget searchInputField = TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: S.current.feedback_search_hint,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(1080),
        ),
        contentPadding: EdgeInsets.zero,
        fillColor: ColorUtil.searchBarBackgroundColor,
        filled: true,
        prefixIcon: Icon(
          Icons.search,
          color: ColorUtil.mainColor,
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
    );

    if (widget.tapField != null) {
      searchInputField = InkWell(
        child: AbsorbPointer(
          child: searchInputField,
        ),
        onTap: widget.tapField,
      );
    }

    var searchBar = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: kToolbarHeight,
      child: Row(
        children: [
          Expanded(
            child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: searchInputField),
          ),
          widget.rightWidget ?? SizedBox.shrink()
        ],
      ),
    );

    return searchBar;
  }
}
