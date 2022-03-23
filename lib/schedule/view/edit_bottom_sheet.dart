// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';

class EditBottomSheet extends StatelessWidget {
  final _arrangeList = ValueNotifier<List<Arrange>>([Arrange.empty()]);

  @override
  Widget build(BuildContext context) {
    var titleColor = FavorColors.scheduleTitleColor;
    var name = '';
    var credit = '';
    return Material(
      color: Color.fromRGBO(246, 246, 246, 1.0),
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        height: WePeiYangApp.screenHeight * 0.6,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          children: [
            Row(
              children: [
                Text('新建课程',
                    style: TextUtil.base.PingFangSC.bold.black2A.sp(18)),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // TODO
                  },
                  style: ElevatedButton.styleFrom(
                    primary: titleColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('保存',
                      style: TextUtil.base.PingFangSC.regular.white.sp(12)),
                )
              ],
            ),
            _CardWidget(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle, color: titleColor),
                  SizedBox(width: 5),
                  Text('输入逻辑班号导入课程',
                      style: TextUtil.base.PingFangSC.medium
                          .customColor(titleColor)
                          .sp(12)),
                ],
              ),
            ),
            _CardWidget(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _InputWidget(
                    onChanged: (text) => name = text,
                    title: '课程名称',
                    hintText: '请输入课程名称（必填）',
                  ),
                  _InputWidget(
                    onChanged: (text) => credit = text,
                    title: '课程学分',
                    hintText: '请输入课程学分（选填）',
                  ),
                ],
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _arrangeList,
              builder: (context, List<Arrange> list, _) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return _TimeFrameWidget(_arrangeList, index);
                    },
                  ),
                );
              },
            ),
            _CardWidget(
              onTap: () => _arrangeList.value.add(Arrange.empty()),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle, color: titleColor),
                  SizedBox(width: 5),
                  Text('新增时段',
                      style: TextUtil.base.PingFangSC.medium
                          .customColor(titleColor)
                          .sp(12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeFrameWidget extends StatelessWidget {
  final ValueNotifier<List<Arrange>> notifier;
  final int index;

  _TimeFrameWidget(this.notifier, this.index);

  @override
  Widget build(BuildContext context) {
    return _CardWidget(
      child: Column(
        children: [
          Row(
            children: [
              Text('time frame $index',
                  style: TextUtil.base.Aspira.medium.black2A.sp(16)),
              Spacer(),
              GestureDetector(
                onTap: () => notifier.value.removeAt(index),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(),
                  child:
                      Icon(Icons.cancel, color: FavorColors.scheduleTitleColor),
                ),
              ),
            ],
          ),
          _InputWidget(
            onChanged: (text) => notifier.value[index].location = text,
            title: '地点',
            hintText: '请输入地点（选填）',
          ),
          _InputWidget(
            onChanged: (text) => notifier.value[index].location = text,
            title: '教师',
            hintText: '请输入教师名（选填）',
          ),
        ],
      ),
    );
  }
}

class _CardWidget extends StatelessWidget {
  final Widget child;
  final GestureTapCallback? onTap;
  final EdgeInsetsGeometry? padding;

  _CardWidget({required this.child, this.onTap, this.padding});

  @override
  Widget build(BuildContext context) {
    if (onTap != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: onTap,
            splashFactory: InkRipple.splashFactory,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(12),
              child: Center(child: child),
            ),
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: child),
    );
  }
}

class _InputWidget extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String title;
  final String hintText;

  _InputWidget(
      {required this.onChanged, required this.title, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$title：', style: TextUtil.base.PingFangSC.bold.black2A.sp(14)),
        Expanded(
          child: TextField(
            onChanged: onChanged,
            textAlign: TextAlign.end,
            style: TextUtil.base.PingFangSC.medium.black2A.sp(16),
            cursorColor: FavorColors.scheduleTitleColor,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextUtil.base.PingFangSC.medium.greyA8.sp(13),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
