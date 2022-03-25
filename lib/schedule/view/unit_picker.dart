// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/schedule/model/edit_provider.dart';

class UnitPicker extends Dialog {
  final int _index;

  UnitPicker(this._index);

  static const _text = ['至', '节'];

  final _textStyle =
      TextUtil.base.PingFangSC.w900.black00.copyWith(letterSpacing: 1);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    for (int section = 0; section < 2; section++) {
      children.add(
        Expanded(
          flex: 1,
          child: CupertinoPicker.builder(
            diameterRatio: 1.5,
            squeeze: 1.45,
            selectionOverlay: Container(color: Colors.transparent),
            itemExtent: 40,
            childCount: 12,
            onSelectedItemChanged: (row) {
              print('section: $section | row: ${row + 1}');
              context
                  .read<EditProvider>()
                  .arrangeList[_index]
                  .unitList[section] = row + 1;
            },
            itemBuilder: (context, row) {
              var str = '${row + 1}';
              if (str.length == 1) str = '0$str';
              return Center(child: Text(str, style: _textStyle.sp(18)));
            },
          ),
        ),
      );
      children.add(Text(_text[section], style: _textStyle.sp(15)));
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: WePeiYangApp.screenWidth * 0.66,
        height: 150,
        margin: EdgeInsets.only(bottom: WePeiYangApp.screenHeight * 0.15),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          elevation: 5,
          child: Center(
            child: Container(
              width: WePeiYangApp.screenWidth * 0.5,
              padding: const EdgeInsets.all(5),
              margin: EdgeInsets.only(right: WePeiYangApp.screenWidth * 0.05),
              child: Row(children: children),
            ),
          ),
        ),
      ),
    );
  }
}
