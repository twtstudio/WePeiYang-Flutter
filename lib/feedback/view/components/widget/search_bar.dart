import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
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
    Widget searchInputField = ConstrainedBox
      (
        constraints: BoxConstraints(
          maxHeight: ScreenUtil().setSp(24),
          maxWidth: ScreenUtil().setSp(282),
        ),
        child:TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintStyle: TextStyle().NotoSansSC.sp(13),
        hintText: S.current.feedback_search_hint,
        contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(1080),
        ),
        fillColor: ColorUtil.searchBarBackgroundColor,
        filled: true,
        prefixIcon: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: ScreenUtil().setSp(13.5),
            maxWidth:  ScreenUtil().setSp(13.5),
          ),
          child:Icon(
            Icons.search,
            color: ColorUtil.mainColor,
          ),
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
    ),);

    if (widget.tapField != null) {
      searchInputField = InkWell(
        child: AbsorbPointer(
          child: searchInputField,
        ),
        onTap: widget.tapField,
      );
    }

    var searchBar = Container(
      height: kToolbarHeight,
      child: Row(
        children: [
          Expanded(
            child: Padding(
                padding: const EdgeInsets.all(0),
                child: searchInputField),
          ),
          SizedBox(width: ScreenUtil().setSp(16),),
          widget.rightWidget ?? SizedBox.shrink()
        ],
      ),
    );

    return searchBar;
  }
}
