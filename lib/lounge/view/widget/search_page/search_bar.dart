// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/lounge/util/image_util.dart';
import 'package:we_pei_yang_flutter/lounge/util/theme_util.dart';
import 'package:we_pei_yang_flutter/lounge/view/page/search_page.dart';
import 'package:provider/provider.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({Key? key}) : super(key: key);

  @override
  _SearchBarWidgetState createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: 考虑把搜索图标换成和主页相同的退出按钮，参考百度app
    final cancelButtonTextStyle = TextStyle(
      color: Theme.of(context).searchCancelButton,
      fontWeight: FontWeight.bold,
      fontSize: 12.sp,
    );

    var cancelButton = Builder(
      builder: (context) {
        final text = context.select(
          (SearchPageProvider provider) => provider.controller.text,
        );

        return TextButton(
          onPressed: () {
            if (text.isEmpty) {
              Navigator.pop(context);
            } else {
              context.read<SearchPageProvider>().search();
            }
          },
          child: Text(
            text.isEmpty ? '取消' : '搜索',
            style: cancelButtonTextStyle,
          ),
        );
      },
    );

    var clearButton = IconButton(
      icon: Icon(
        Icons.clear,
        color: Theme.of(context).searchIcon,
      ),
      onPressed: () {
        context.read<SearchPageProvider>().clearInput();
      },
      padding: const EdgeInsets.all(0),
    );

    var textField = const Expanded(child: _SearchInputField());

    var searchBar = Row(
      children: [
        Image.asset(
          Images.search,
          height: 20.w,
        ),
        SizedBox(width: 10.w),
        textField,
        clearButton,
        cancelButton,
      ],
    );

    var bottomLine = Container(
      height: 0.6.w,
      color: Theme.of(context).searchInputFieldButtonLine,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 23.w),
      width: double.infinity,
      child: Column(
        children: [
          searchBar,
          bottomLine,
        ],
      ),
    );
  }
}

class _SearchInputField extends StatelessWidget {
  const _SearchInputField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: context.read<SearchPageProvider>().controller,
      focusNode: context.read<SearchPageProvider>().focusNode,
      autofocus: true,
      style: TextStyle(
        color: Theme.of(context).searchInputField,
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
      ),
      onSubmitted: (_) {
        context.read<SearchPageProvider>().search();
      },
      onTap: () {
        context.read<SearchPageProvider>().autoInputTextField();
      },
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: context.select(
          (SearchPageProvider provider) => provider.hintText,
        ),
        hintStyle: TextStyle(
          color: Theme.of(context).searchInputFieldHint,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}
