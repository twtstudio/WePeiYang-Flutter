import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';

import '../../../../commons/themes/wpy_theme.dart';

class DaTab extends StatelessWidget {
  final String text;

  final bool withDropDownButton;

  final bool dropdownOpen;

  final bool selected;

  final VoidCallback? onTap;

  const DaTab({
    Key? key,
    required this.text,
    required this.withDropDownButton,
    this.dropdownOpen = false,
    this.selected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _tabPaddingWidth = MediaQuery.of(context).size.width / 30;
    if (withDropDownButton) {
      return Tab(
        child: Row(
          children: [
            SizedBox(width: _tabPaddingWidth),
            Text(text),
            InkWell(
              onTap: onTap, // 启用 TagsWrap 的打开/关闭功能
              customBorder: const CircleBorder(), // 创建圆形触摸效果
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: Icon(
                  // selected ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  dropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 20,
                  // color: iconColor,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Tab(
        child: Row(
      children: [
        SizedBox(width: _tabPaddingWidth),
        Text(text),
        SizedBox(width: _tabPaddingWidth),
      ],
    ));
  }
}
