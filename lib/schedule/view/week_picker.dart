// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/edit_provider.dart';

class WeekPicker extends Dialog {
  final int _index;

  WeekPicker(this._index);

  static const _text = ['至', '周'];

  static const _weekDays = [
    'Mon.',
    'Tue.',
    'Wed.',
    'Thu.',
    'Fri.',
    'Sat.',
    'Sun.'
  ];

  static const _weekTypes = ['每周', '单周', '双周'];

  final _textStyle =
      TextUtil.base.PingFangSC.w900.black00.copyWith(letterSpacing: 1);

  final _selectedWeekTypeIndex = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    var pvd = context.read<EditProvider>();
    var weekCount = context.read<CourseProvider>().weekCount;
    List<Widget> children = [
      Expanded(
        flex: 1,
        child: CupertinoPicker.builder(
          diameterRatio: 1.5,
          squeeze: 1.45,
          selectionOverlay: Container(color: Colors.transparent),
          itemExtent: 40,
          childCount: 7,
          onSelectedItemChanged: (row) {
            print('week row: ${row + 1}');
            pvd.arrangeList[_index].weekday = row + 1;
          },
          itemBuilder: (context, row) =>
              Center(child: Text(_weekDays[row], style: _textStyle.sp(18))),
        ),
      ),
    ];

    for (int section = 0; section < 2; section++) {
      children.add(
        Expanded(
          flex: 1,
          child: CupertinoPicker.builder(
            diameterRatio: 1.5,
            squeeze: 1.45,
            selectionOverlay: Container(color: Colors.transparent),
            itemExtent: 40,
            childCount: weekCount,
            onSelectedItemChanged: (row) {
              print('section: $section | row: ${row + 1}');
              if (section == 0) {
                pvd.weekStart = row + 1;
              } else {
                pvd.weekEnd = row + 1;
              }
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
        width: WePeiYangApp.screenWidth * 0.8,
        height: 220,
        margin: EdgeInsets.only(bottom: WePeiYangApp.screenHeight * 0.15),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          elevation: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 150,
                width: WePeiYangApp.screenWidth * 0.65,
                padding: const EdgeInsets.all(10),
                margin: EdgeInsets.only(right: WePeiYangApp.screenWidth * 0.05),
                child: Row(children: children),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ...List.generate(3, (index) {
                    return ValueListenableBuilder(
                      valueListenable: _selectedWeekTypeIndex,
                      builder: (context, value, _) {
                        return ElevatedButton(
                          onPressed: () {
                            _selectedWeekTypeIndex.value = index;
                            pvd.weekType = _weekTypes[index];
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            primary: index == value
                                ? FavorColors.scheduleTitleColor
                                : ColorUtil.greyF7F8Color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(_weekTypes[index],
                              style: TextUtil.base.PingFangSC.regular
                                  .sp(12)
                                  .customColor(index == value
                                      ? Colors.white
                                      : ColorUtil.greyCAColor)),
                        );
                      },
                    );
                  })
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
