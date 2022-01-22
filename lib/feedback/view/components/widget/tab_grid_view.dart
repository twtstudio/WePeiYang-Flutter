import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';

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
    //设计图里没有发送按键，删了

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
        borderRadius: BorderRadius.all(
          const Radius.circular(10.0),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 25),
        shrinkWrap: true,
        children: [tagsWrap],
      ),
    );
  }

  void updateGroupValue(Department department) {
    currentTab.value = department;
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
          if (chose == false) {
            setState(() {
           context.read<NewPostProvider>().department = tag;
              updateGroupValue(tag);
            });
          } else if (chose == true){
            setState(() {
             context.read<NewPostProvider>().department = Department();
             updateGroupValue(Department());
            });
          }
        },
      );
}
