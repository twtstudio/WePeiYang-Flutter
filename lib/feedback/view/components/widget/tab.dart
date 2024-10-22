import 'package:flutter/material.dart';

class DaTab extends StatelessWidget {
  final String text;
  final bool withDropDownButton;

  const DaTab({
    Key? key,
    required this.text,
    required this.withDropDownButton,
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
            Icon(
              Icons.arrow_drop_down,
              size: 20,
            ),
            if (_tabPaddingWidth > 10) SizedBox(width: _tabPaddingWidth - 10)
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
