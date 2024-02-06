// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';

import '../../../../commons/themes/template/wpy_theme_data.dart';
import '../../../../commons/themes/wpy_theme.dart';

class TabGridView extends StatefulWidget {
  final Department department;

  const TabGridView({Key? key, required this.department}) : super(key: key);

  @override
  _TabGridViewState createState() => _TabGridViewState();
}

class _TabGridViewState extends State<TabGridView>
    with TickerProviderStateMixin {
  late ValueNotifier<Department?> currentTab;

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
        color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        borderRadius: BorderRadius.all(
          const Radius.circular(10.0),
        ),
      ),
      foregroundDecoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0, 0.75),
          end: Alignment.bottomCenter,
          colors: [
            ColorUtil.liteBackgroundMaskColor,
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
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

  Widget _tagButton(tag) {
    return ValueListenableBuilder(
      valueListenable: currentTab,
      builder: (_, Department? value, __) {
        return _tagChip(tag.id == value?.id, tag);
      },
    );
  }

  ActionChip _tagChip(bool chose, Department tag) => ActionChip(
        backgroundColor: chose ? WpyTheme.of(context).get(WpyColorKey.oldThirdActionColor) : ColorUtil.tagLabelColor,
        label: Text(
          tag.name,
          style: chose
              ? TextUtil.base.reverse(context).NotoSansSC.w400.sp(14)
              : TextUtil.base.label(context).NotoSansSC.w400.sp(14),
        ),
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        onPressed: () {
          if (!chose) {
            setState(() {
              context.read<NewPostProvider>().department = tag;
              updateGroupValue(tag);
              ToastProvider.success(
                  context.read<NewPostProvider>().department?.name ?? '');
            });
          } else {
            setState(() {
              context.read<NewPostProvider>().department = Department();
              ToastProvider.error(
                  (context.read<NewPostProvider>().department == null)
                      .toString());

              updateGroupValue(Department());
            });
          }
        },
      );
}
