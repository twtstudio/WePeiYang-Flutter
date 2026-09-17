import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';

class FeedbackTabOrderPage extends StatefulWidget {
  const FeedbackTabOrderPage({super.key});

  @override
  State<FeedbackTabOrderPage> createState() => _FeedbackTabOrderPageState();
}

class _FeedbackTabOrderPageState extends State<FeedbackTabOrderPage> {
  late Future<void> _loadFuture;
  List<WPYTab> _tabs = [];

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadTabs();
  }

  Future<void> _loadTabs() async {
    await LakeUtil.initTabList(forceRefresh: true);
    final tabs = LakeUtil.tabList.where((tab) => tab.id != 0).toList();
    if (!mounted) return;
    setState(() {
      _tabs = tabs;
    });
  }

  void _retry() {
    setState(() {
      _loadFuture = _loadTabs();
    });
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      final tab = _tabs.removeAt(oldIndex);
      _tabs.insert(newIndex, tab);
    });
    LakeUtil.setCustomTabOrder(_tabs.map((tab) => tab.id));
  }

  void _reset() {
    setState(() {
      _tabs = List<WPYTab>.from(LakeUtil.defaultTabList);
    });
    LakeUtil.resetCustomTabOrder();
    ToastProvider.success('已恢复默认顺序');
  }

  @override
  Widget build(BuildContext context) {
    final background =
        WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor);
    final cardColor =
        WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor);
    final titleStyle = TextUtil.base.bold.sp(15).oldThirdAction(context);
    final hintStyle = TextUtil.base.regular.sp(12).oldHint(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: WpyTheme.of(context).brightness.uiOverlay.copyWith(
            systemNavigationBarColor: background,
          ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '论坛分区顺序',
            style: TextUtil.base.bold.sp(16).oldActionColor(context),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: cardColor,
          leading: Padding(
            padding: EdgeInsets.only(left: 15.w),
            child: WButton(
              onPressed: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back,
                color: WpyTheme.of(context).get(WpyColorKey.oldActionColor),
                size: 32,
              ),
            ),
          ),
          actions: [
            WButton(
              onPressed: _tabs.isEmpty || LakeUtil.defaultTabList.isEmpty
                  ? null
                  : _reset,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Text(
                  '恢复默认',
                  style: TextUtil.base.medium.sp(14).primaryAction(context),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: background,
        body: SafeArea(
          child: FutureBuilder<void>(
            future: _loadFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('分区加载失败', style: titleStyle),
                      SizedBox(height: 12.h),
                      WButton(
                        onPressed: _retry,
                        child: Padding(
                          padding: EdgeInsets.all(12.r),
                          child: Text('重试', style: titleStyle),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
                    child: Text(
                      '按住右侧图标拖动分区；“精华”固定在首位。',
                      style: hintStyle,
                    ),
                  ),
                  Expanded(
                    child: ReorderableListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      buildDefaultDragHandles: false,
                      itemCount: _tabs.length,
                      onReorderItem: _reorder,
                      itemBuilder: (context, index) {
                        final tab = _tabs[index];
                        return Container(
                          key: ValueKey(tab.id),
                          margin: EdgeInsets.only(bottom: 10.h),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: ListTile(
                            title: Text(tab.shortname, style: titleStyle),
                            subtitle: tab.name == tab.shortname
                                ? null
                                : Text(tab.name, style: hintStyle),
                            trailing: ReorderableDragStartListener(
                              index: index,
                              child: Padding(
                                padding: EdgeInsets.all(8.r),
                                child: Icon(
                                  Icons.drag_handle,
                                  color: WpyTheme.of(context)
                                      .get(WpyColorKey.oldListActionColor),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
