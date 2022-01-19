import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/new_post_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

import '../../../../main.dart';

class TabGridView extends StatefulWidget {
  final Department department;

  const TabGridView({Key key, this.department}) : super(key: key);

  @override
  _TabGridViewState createState() => _TabGridViewState();
}

class _TabGridViewState extends State<TabGridView>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  ValueNotifier<Department> currentTab;

  @override
  void initState() {
    super.initState();
    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 200))
      ..forward();
    currentTab = ValueNotifier(widget.department);
  }

  @override
  Widget build(BuildContext context) {
    var tagInformation = ValueListenableBuilder(
        valueListenable: currentTab,
        builder: (_, Department value, __) {
          if (value != null) {
            var information = value.name + ': ';
            information += (value.introduction != null
                ? value.introduction
                : S.current.feedback_no_description);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                information,
                style: FontManager.YaHeiRegular.copyWith(
                  color: Color(0xff303c66),
                  fontSize: 10,
                ),
              ),
            );
          } else {
            return Container();
          }
        });
    //设计图里没有发送按键，删了
    var confirmButton = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Visibility(
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: ConfirmButton(onPressed: null),
        ),
        Text(
          S.current.feedback_add_tag,
          style: FontManager.YaHeiRegular.copyWith(
            color: Color(0xff303c66),
            fontSize: 18,
          ),
        ),
        ConfirmButton(
            onPressed: () => Navigator.of(context).pop(currentTab.value))
      ],
    );

    var tagsWrap = Consumer<FbTagsProvider>(
      builder: (_, data, __) => Wrap(
        alignment: WrapAlignment.start,
        spacing: 10,
        children: List.generate(data.departmentList.length, (index) {
          return _tagButton(data.departmentList[index]);
        }),
      ),
    );

    return Container(
      constraints: BoxConstraints(
          maxHeight: WePeiYangApp.screenHeight - WePeiYangApp.paddingTop),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(10.0),
              topRight: const Radius.circular(10.0))),
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 25),
        shrinkWrap: true,
        children: [confirmButton, tagInformation, tagsWrap],
      ),
    );
  }

  void updateGroupValue(Department department) {
    currentTab.value = department;
    _animationController.forward(from: 0.0);
  }

  _tagButton(tag) {
    return ValueListenableBuilder(
      valueListenable: currentTab,
      builder: (_, value, __) {
        return tag.id == value?.id
            ? FadeTransition(
          opacity:
          Tween(begin: 0.0, end: 1.0).animate(_animationController),
          child: _tagChip(true, tag),
        )
            : _tagChip(false, tag);
      },
    );
  }

  ActionChip _tagChip(bool chose, Department tag) => ActionChip(
    backgroundColor: chose ? Color(0xff62677c) : Color(0xffeeeeee),
    label: Text(
      tag.name,
      style: FontManager.YaHeiRegular.copyWith(
        fontSize: 12,
        color: chose ? Colors.white : Color(0xff62677c),
      ),
    ),
    onPressed: () {
      updateGroupValue(tag);
    },
  );
}