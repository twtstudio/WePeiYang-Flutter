import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';

class TabGridView extends StatefulWidget {
  final Department department;

  const TabGridView({Key key, this.department}) : super(key: key);

  @override
  _TabGridViewState createState() => _TabGridViewState();
}

class _TabGridViewState extends State<TabGridView>
    with TickerProviderStateMixin {
  ValueNotifier<Department> currentTab;

  @override
  void initState() {
    super.initState();
    currentTab = ValueNotifier(widget.department);
  }

  @override
  Widget build(BuildContext context) {
    //设计图里没有发送按键，删了
    var tagsWrap = Consumer<FbDepartmentsProvider>(
      builder: (_, data, __) => Wrap(
        alignment: WrapAlignment.start,
        spacing: 6,
        children: List.generate(data.departmentList.length, (index) {
          return _tagButton(data.departmentList[index]);
        }),
      ),
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      constraints: BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          const Radius.circular(10.0),
        ),
      ),
      foregroundDecoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0, 0.75),
          end: Alignment.bottomCenter,
          colors: [
            Colors.white10,
            Colors.white,
          ],
        ),
      ),
      child: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [SizedBox(height: 12), tagsWrap, SizedBox(height: 14)],
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
        return tag.id == value?.id ? _tagChip(true, tag) : _tagChip(false, tag);
      },
    );
  }

  ActionChip _tagChip(bool chose, Department tag) => ActionChip(
        backgroundColor: chose ? Color(0xff62677c) : Color(0xffeeeeee),
        label: Text(
          tag.name,
          style: chose
              ? TextUtil.base.white.NotoSansSC.w400.sp(14)
              : TextUtil.base.black2A.NotoSansSC.w400.sp(14),
        ),
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        onPressed: () {
          if (chose == false) {
            setState(() {
              context.read<NewPostProvider>().department = tag;
              updateGroupValue(tag);
            });
          } else if (chose == true) {
            setState(() {
              context.read<NewPostProvider>().department = Department();
              updateGroupValue(Department());
            });
          }
        },
      );
}
