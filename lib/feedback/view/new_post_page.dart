import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/SpoilerMask.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/tag_grid_view.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../commons/themes/template/wpy_theme_data.dart';
import '../../commons/themes/wpy_theme.dart';
import '../../commons/widgets/w_button.dart';
import '../feedback_router.dart';
import 'components/widget/pop_menu_shape.dart';
import 'components/widget/tag_search_card.dart';
import 'image_view/local_image_view_page.dart';
import 'lake_home_page/lake_notifier.dart';

class NewPostPage extends StatefulWidget {
  final NewPostArgs args;

  const NewPostPage(this.args);

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class NewPostArgs {
  final bool isFollowing;
  final String tagId;
  final String tagName;
  final int type;

  NewPostArgs(this.isFollowing, this.tagId, this.type, this.tagName);
}

final ValueNotifier<PostVariant> variant = ValueNotifier(PostVariant.Common);

class _NewPostPageState extends State<NewPostPage> {
  // 0 -> 不区分; 1 -> 卫津路; 2 -> 北洋园
  final campusNotifier = ValueNotifier(0);
  bool tapAble = true;

  _showLoading() {
    showDialog(context: context, builder: (_) => Loading());
  }

  _submit() async {
    final args = widget.args;
    var dataModel = context.read<NewPostProvider>();
    dataModel.type = dataModel.postTypeNotifier.value;

    if (variant.value == PostVariant.Vote) {
      _voteFormController.submit(
          context,
          args.isFollowing ? args.type : dataModel.type,
          campusNotifier.value,
          args.isFollowing ? args.tagId : dataModel.tag?.id.toString() ?? '');
      return;
    }

    if (!dataModel.check) {
      dataModel.type == 1
          ? ToastProvider.error('内容标题与部门不能为空！')
          : ToastProvider.error('内容与标题不能为空！');
      return;
    }
    _showLoading();
    if (dataModel.images.isNotEmpty) {
      FeedbackService.postPic(
          images: dataModel.images,
          onResult: (images) {
            dataModel.images.clear();
            if (dataModel.check) {
              FeedbackService.sendPost(
                type: args.isFollowing ? args.type : dataModel.type,
                title: dataModel.title,
                content: dataModel.content,
                tagId: args.isFollowing ? args.tagId : dataModel.tag?.id ?? '',
                departmentId: dataModel.department?.id ?? '',
                images: images,
                masked: dataModel.masked,
                campus: campusNotifier.value,
                onSuccess: () {
                  ToastProvider.success('发布成功');
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                onFailure: (e) {
                  Navigator.pop(context);
                  ToastProvider.error('发帖失败，内容已暂存\n${e.error.toString()}');
                },
              );
              dataModel.clear();
            } else {
              dataModel.type == 1
                  ? ToastProvider.error('内容标题与部门不能为空！')
                  : ToastProvider.error('内容与标题不能为空！');
            }
          },
          onFailure: (e) {
            Navigator.pop(context);
            ToastProvider.error('发送图片失败或图片不合规\n${e.error.toString()}');
          });
    } else {
      FeedbackService.sendPost(
        type: args.isFollowing ? args.type : dataModel.type,
        title: dataModel.title,
        content: dataModel.content,
        tagId: args.isFollowing ? args.tagId : dataModel.tag?.id ?? '',
        departmentId: dataModel.department?.id ?? '',
        images: [],
        campus: campusNotifier.value,
        onSuccess: () {
          ToastProvider.success('发布成功');
          Navigator.pop(context);
          Navigator.pop(context);
        },
        onFailure: (e) {
          dataModel.clear();
          ToastProvider.error(e.error.toString());
          Navigator.pop(context);
        },
      );
      dataModel.clear();
    }
  }

  VoteFormController _voteFormController = VoteFormController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            AnimatedSize(
              alignment: Alignment.topCenter,
              duration: Duration(milliseconds: 250),
              child: ListenableBuilder(
                child: TitleInputField(),
                builder: (context, old) {
                  if (variant.value == PostVariant.Vote)
                    return SizedBox.shrink();
                  return old!;
                },
                listenable: variant,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          padding: widget.args.isFollowing
                              ? const EdgeInsets.fromLTRB(0, 14, 0, 20)
                              : EdgeInsets.zero,
                          child: widget.args.isFollowing
                              ? Text('跟帖:',
                                  style: TextUtil.base.NotoSansSC.w500
                                      .sp(14)
                                      .label(context))
                              : LakeSelector()),
                      SizedBox(height: 10),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.secondaryBackgroundColor),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedSize(
                                alignment: Alignment.topCenter,
                                duration: Duration(milliseconds: 250),
                                child: ValueListenableBuilder(
                                    valueListenable: variant,
                                    builder: (ctx, v, oldChild) {
                                      switch (v) {
                                        case PostVariant.Common:
                                          return Column(
                                            children: [
                                              ContentInputField(),
                                              SizedBox(height: 20),
                                              ImagesGridView(),
                                            ],
                                          );
                                        case PostVariant.Vote:
                                          return NewVoteForm(
                                              controller: _voteFormController);
                                        case PostVariant.Question:
                                          return SizedBox.shrink();
                                      }
                                    }),
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  PostVariantSelector(),
                                  Spacer(),
                                  CampusSelector(campusNotifier),
                                  SizedBox(width: 18),
                                  _buildSubmitButton(context),
                                ],
                              ),
                            ]),
                      ),
                      SizedBox(height: 22),
                      widget.args.isFollowing
                          ? Text('${widget.args.tagName}'.substring(3),
                              style: TextUtil.base.NotoSansSC.w500
                                  .sp(14)
                                  .label(context))
                          : departmentTagView(
                              context.read<NewPostProvider>().postTypeNotifier),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        '冒泡',
        style: TextUtil.base.NotoSansSC.w700.sp(18).label(context),
      ),
      elevation: 0,
      leading: IconButton(
        padding: EdgeInsets.zero,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: WpyTheme.of(context).get(WpyColorKey.oldThirdActionColor),
          size: 36,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Hero _buildSubmitButton(BuildContext context) {
    return Hero(
      tag: "addNewPost",
      child: ElevatedButton(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0),
          backgroundColor: MaterialStateProperty.all(
              WpyTheme.of(context).get(WpyColorKey.primaryActionColor)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        onPressed: () async {
          if (tapAble) {
            tapAble = false;
            await _submit();
            await Future.delayed(Duration(milliseconds: 3000));
            tapAble = true;
          }
        },
        child: Text('发送',
            style: TextUtil.base.NotoSansSC.w500.sp(14).bright(context)),
      ),
    );
  }
}

class VoteFormController {
  final title = TextEditingController();
  int maxSelect = 1;

  final options = List.generate(1, (index) => TextEditingController());

  submit(BuildContext context, int type, int campus, String tag_id) async {
    // 取消焦点
    FocusScope.of(context).requestFocus(FocusNode());

    final title = this.title.text;
    // 需要去掉最后一个选项
    final options = this.options.map((e) => e.text).toList();
    if (options.last.isEmpty) options.removeLast();

    // check valid
    if (title.isEmpty) {
      ToastProvider.error('标题不能为空');
      return;
    }

    if (options.any((element) => element.isEmpty)) {
      ToastProvider.error('选项不能为空');
      return;
    }

    if (options.length < 2) {
      ToastProvider.error('至少需要两个选项');
      return;
    }
    // options 检查重复
    if (options.toSet().length != options.length) {
      ToastProvider.error('选项不能重复');
      return;
    }

    try {
      await FeedbackService.addVote(
        type: type,
        title: title,
        options: options,
        campus: campus,
        tagId: tag_id,
        maxSelect: maxSelect,
      );
      ToastProvider.success('发布成功');
      Navigator.pop(context);
    } on DioException catch (e) {
      ToastProvider.error('发布失败: ${e.error.toString()}');
    } catch (e) {
      Logger.reportError(e, StackTrace.current);
      ToastProvider.error('未知错误: ${e.toString()}');
    }
  }
}

class NewVoteForm extends StatefulWidget {
  const NewVoteForm({super.key, required this.controller});

  final VoteFormController controller;

  @override
  State<NewVoteForm> createState() => _NewVoteFormState();
}

class _NewVoteFormState extends State<NewVoteForm> {
  @override
  Widget build(BuildContext context) {
    final options = widget.controller.options;
    return Stack(children: [
      Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
            border: Border.all(
                color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
                width: 2),
            borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    minLines: 1,
                    onChanged: (_) => setState(() {}),
                    maxLines: 2,
                    maxLength: 100,
                    controller: widget.controller.title,
                    decoration: InputDecoration(
                      counterText: widget.controller.title.text.length > 80
                          ? '${widget.controller.title.text.length}/100'
                          : '',
                      hintText: '请输入投票标题',
                      hintStyle: TextUtil.base.NotoSansSC.w500
                          .sp(16)
                          .infoText(context),
                      border: InputBorder.none,
                    ),
                    style: TextUtil.base.NotoSansSC.w500
                        .sp(16)
                        .label(context)
                        .h(1.4),
                  ),
                ),
                if (widget.controller.options
                        .where((element) => element.text.isNotEmpty)
                        .length >
                    2)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                        color: WpyTheme.of(context)
                            .get(WpyColorKey.primaryBackgroundColor),
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        NumberPicker(
                            axis: Axis.horizontal,
                            selectedTextStyle: TextUtil.base.NotoSansSC.w500
                                .sp(16)
                                .primaryAction(context),
                            itemWidth: 20,
                            itemHeight: 30,
                            textStyle: TextUtil.base.NotoSansSC.w500
                                .sp(14)
                                .label(context)
                                .h(1.4),
                            minValue: 1,
                            maxValue: widget.controller.options
                                .where((element) => element.text.isNotEmpty)
                                .length,
                            value: widget.controller.maxSelect,
                            onChanged: (v) {
                              widget.controller.maxSelect = v;
                              setState(() {});
                            }),
                        Text("最多选${widget.controller.maxSelect}项",
                            style: TextUtil.base.NotoSansSC.w500
                                .sp(12)
                                .infoText(context)
                                .h(1.4)),
                      ],
                    ),
                  ),
              ],
            ),
            ReorderableListView.builder(
              shrinkWrap: true,
              proxyDecorator: (child, index, animation) {
                return child;
              },
              physics: NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {
                // Check if the item is being dragged to the last position
                if (newIndex >= options.length - 1) {
                  // If dragged to the last position, set it back to its original position
                  newIndex = oldIndex;
                } else {
                  // Adjust the newIndex if it’s moved to another position
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                }

                // Perform the reorder if the newIndex is valid
                if (oldIndex != newIndex) {
                  final item = options.removeAt(oldIndex);
                  options.insert(newIndex, item);
                  setState(() {});
                }
              },
              itemBuilder: (context, index) {
                final e = options[index];
                return GestureDetector(
                  key: ValueKey(index),
                  onLongPress: index != options.length - 1
                      ? null
                      : () => HapticFeedback.mediumImpact(),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          e.text.isEmpty
                              ? Icons.add
                              : Icons.check_box_outline_blank,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: e,
                            minLines: 1,
                            maxLines: 2,
                            onChanged: (text) {
                              if (text.isEmpty && index != options.length - 1) {
                                options.removeAt(index);
                                setState(() {});
                                return;
                              }
                              if (index == options.length - 1 &&
                                  text.isNotEmpty &&
                                  options.length < 8) {
                                options.add(TextEditingController());
                                setState(() {});
                              }
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              counterText: e.text.length > 20
                                  ? '${e.text.length}/50'
                                  : '',
                              suffixIcon: options.length > 1 &&
                                          index != options.length - 1 ||
                                      index == 7 && options.last.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () {
                                        if (index == 7) {
                                          options.removeAt(index);
                                          options.add(TextEditingController());
                                          setState(() {});
                                          return;
                                        }
                                        options.removeAt(index);
                                        widget.controller.maxSelect = min(
                                            widget.controller.maxSelect,
                                            options.length - 1);
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              hintText: '选项',
                              hintStyle: TextUtil.base.NotoSansSC.w500
                                  .sp(14)
                                  .infoText(context)
                                  .h(1.4),
                              border: InputBorder.none,
                            ),
                            style: TextUtil.base.NotoSansSC.w500
                                .sp(14)
                                .label(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: options.length,
            ),
          ],
        ),
      ),
      Positioned(
        left: 24,
        top: 0,
        child: Container(
          height: 20,
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
              borderRadius: BorderRadius.circular(16)),
          child: Center(
            child: Text(
              'POLL',
              style: TextUtil.base.w400.NotoSansSC
                  .sp(10)
                  .bright(context)
                  .bold
                  .h(1.6),
            ),
          ),
        ),
      ),
    ]);
  }
}

class LakeSelector extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LakeSelectorState();
}

class _LakeSelectorState extends State<LakeSelector> {
  var controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<NewPostProvider>().postTypeNotifier;
    final tabList = LakeUtil.tabList;
    return SizedBox(
        height: 60,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: notifier,
              builder: (context, type, _) {
                return Padding(
                    padding: const EdgeInsets.only(right: 40.0),
                    child: Builder(builder: (context) {
                      return ListView.builder(
                        controller: controller,
                        itemCount: tabList.length - 1,
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return WButton(
                            onPressed: () {
                              notifier.value = tabList[index + 1].id;

                              ///在切换发帖区时，要清空department，不然就会导致参数问题
                              context.read<NewPostProvider>().department = null;
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 25.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(tabList[index + 1].shortname,
                                      style: type == tabList[index + 1].id
                                          ? TextUtil.base.NotoSansSC.w400
                                              .sp(15)
                                              .primaryAction(context)
                                          : TextUtil.base.w400
                                              .sp(15)
                                              .label(context)),
                                  Container(
                                    margin: EdgeInsets.only(top: 2),
                                    decoration: BoxDecoration(
                                        color: type == tabList[index + 1].id
                                            ? WpyTheme.of(context).get(
                                                WpyColorKey.primaryActionColor)
                                            : WpyTheme.of(context).get(
                                                WpyColorKey
                                                    .primaryBackgroundColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16))),
                                    width: 28,
                                    height: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }));
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  controller.offset <= 100 * (tabList.length - 2)
                      ? controller.animateTo(controller.offset + 100,
                          duration: Duration(milliseconds: 400),
                          curve: Curves.fastOutSlowIn)
                      : controller.animateTo(
                          100 * (tabList.length - 2).toDouble(),
                          duration: Duration(milliseconds: 800),
                          curve: Curves.slowMiddle);
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 15.w),
                  child: Icon(Icons.arrow_forward_ios_sharp,
                      color:
                          WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                      size: 10.h),
                ),
              ),
            ),
          ],
        ));
  }
}

class departmentTagView extends StatefulWidget {
  final ValueNotifier postTypeNotifier;

  const departmentTagView(this.postTypeNotifier, {Key? key}) : super(key: key);

  @override
  _departmentTagViewState createState() => _departmentTagViewState();
}

class _departmentTagViewState extends State<departmentTagView> {
  late final ValueNotifier<Department> department;

  @override
  void initState() {
    super.initState();
    var dataModel = context.read<NewPostProvider>();
    department = ValueNotifier(dataModel.department ?? Department())
      ..addListener(() {
        dataModel.department = department.value;
      });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<NewPostProvider>().postTypeNotifier;
    return ValueListenableBuilder<int>(
        valueListenable: notifier,
        builder: (context, type, _) {
          return Container(
            decoration: BoxDecoration(
              color:
                  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
              borderRadius: BorderRadius.circular(16),
              shape: BoxShape.rectangle,
            ),
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.fromLTRB(18, 0, 10, 4),
            child: notifier.value == 1
                ? TabGridView(department: department.value)
                : SearchTagCard(),
          );
        });
  }
}

class PostVariantSelector extends StatelessWidget {
  const PostVariantSelector({super.key});

  options(context) => {
        PostVariant.Common: {
          'icon': Icons.chat,
          'text': '讨论',
          'color': WpyTheme.of(context).get(WpyColorKey.primaryActionColor)
        },
        PostVariant.Vote: {
          'icon': Icons.poll,
          'text': '投票',
          'color': WpyTheme.of(context).get(WpyColorKey.infoStatusColor)
        },
      };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: variant,
      builder: (context, _) {
        return PopupMenuButton(
          padding: EdgeInsets.zero,
          color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          shape: RacTangle(),
          offset: Offset(-120.w, 40.w),
          tooltip: "校区",
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color:
                      WpyTheme.of(context).get(WpyColorKey.lightBorderColor)),
              color:
                  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    options(context)[variant.value]?['icon'] as IconData,
                    color: options(context)[variant.value]?['color'] as Color,
                    size: 18,
                  ),
                ),
                SizedBox(width: 6),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  // 使用滚动动画
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: Text(
                      options(context)[variant.value]?['text'] as String,
                      key: ValueKey(variant.value),
                      style: TextUtil.base
                          .sp(16)
                          .w400
                          .NotoSansSC
                          .normal
                          .infoText(context)),
                ),
              ],
            ),
          ),
          onSelected: (PostVariant value) {
            variant.value = value;
          },
          itemBuilder: (context) {
            return List.from(options(context).keys).map((key) {
              return PopupMenuItem<PostVariant>(
                padding: EdgeInsets.only(left: 35), // 去除内边距
                height: ScreenUtil().setHeight(50), // 设置高度
                value: key,
                child: Row(
                  children: [
                    Icon(
                      options(context)[key]?['icon'] as IconData,
                      color: options(context)[key]?['color'] as Color,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      options(context)[key]?['text'] as String,
                      style: TextUtil.base.w400.medium.NotoSansSC.sp(14),
                    ),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }
}

class CampusSelector extends StatefulWidget {
  final ValueNotifier<int> campusNotifier;

  CampusSelector(this.campusNotifier);

  @override
  _CampusSelectorState createState() => _CampusSelectorState();
}

class _CampusSelectorState extends State<CampusSelector> {
  static const texts = ["双校区", "卫津路", "北洋园"];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.campusNotifier,
      builder: (context, int value, _) {
        return PopupMenuButton(
          padding: EdgeInsets.zero,
          color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          shape: RacTangle(),
          offset: Offset(-120.w, -60.w),
          tooltip: "校区",
          child: Row(
            children: [
              SvgPicture.asset(
                "assets/svg_pics/lake_butt_icons/map.svg",
                width: 16,
                colorFilter: ColorFilter.mode(
                    WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
                    BlendMode.srcIn),
              ),
              SizedBox(width: 10),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                // 使用滚动动画
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Text(
                  key: ValueKey(value),
                  texts[value],
                  style: TextUtil.base
                      .sp(14)
                      .w400
                      .NotoSansSC
                      .normal
                      .primaryAction(context),
                ),
              ),
            ],
          ),
          onSelected: (int value) {
            widget.campusNotifier.value = value;
          },
          itemBuilder: (context) {
            return <PopupMenuEntry<int>>[
              PopupMenuItem<int>(
                height: ScreenUtil().setHeight(30),
                value: 0,
                child: Center(
                  child: Text(
                    texts[0],
                    style: TextUtil.base.w400.medium.NotoSansSC.sp(12),
                  ),
                ),
              ),
              PopupMenuItem<int>(
                height: ScreenUtil().setHeight(30),
                value: 1,
                child: Center(
                    child: Text(texts[1],
                        style: TextUtil.base.w400.medium.NotoSansSC.sp(12))),
              ),
              PopupMenuItem<int>(
                height: ScreenUtil().setHeight(30),
                value: 2,
                child: Center(
                    child: Text(texts[2],
                        style: TextUtil.base.w400.medium.NotoSansSC.sp(12))),
              ),
            ];
          },
        );
      },
    );
  }
}

class TitleInputField extends StatefulWidget {
  @override
  _TitleInputFieldState createState() => _TitleInputFieldState();
}

class _TitleInputFieldState extends State<TitleInputField> {
  late final ValueNotifier<String> titleCounter;
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    var dataModel = context.read<NewPostProvider>();
    _titleController = TextEditingController(text: dataModel.title);
    titleCounter = ValueNotifier('${dataModel.title.characters.length}/30')
      ..addListener(() {
        dataModel.title = _titleController.text;
      });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget inputField = Expanded(
      child: TextField(
        buildCounter: null,
        controller: _titleController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        style: TextUtil.base.NotoSansSC.w700.sp(18).h(1.2).label(context),
        minLines: 1,
        maxLines: 10,
        decoration: InputDecoration.collapsed(
          hintStyle: TextUtil.base.NotoSansSC.w500.sp(18).infoText(context),
          hintText: '添加标题',
        ),
        onChanged: (text) {
          titleCounter.value = '${text.characters.length} / 30';
        },
        inputFormatters: [
          CustomizedLengthTextInputFormatter(30),
        ],
        cursorColor: WpyTheme.of(context).get(WpyColorKey.cursorColor),
        cursorHeight: 20,
      ),
    );

    Widget textCounter = ValueListenableBuilder(
      valueListenable: titleCounter,
      builder: (_, String value, __) {
        return Text(value,
            style: TextUtil.base.NotoSansSC.w400.sp(14).infoText(context));
      },
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 5, 20, 0),
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 14),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [inputField, SizedBox(width: 3), textCounter],
          ),
          Container(
              margin: EdgeInsets.only(top: 16.h),
              color: WpyTheme.of(context).get(WpyColorKey.lightBorderColor),
              height: 1.h)
        ],
      ),
    );
  }
}

class ContentInputField extends StatefulWidget {
  @override
  _ContentInputFieldState createState() => _ContentInputFieldState();
}

class _ContentInputFieldState extends State<ContentInputField> {
  late final ValueNotifier<String> contentCounter;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    var dataModel = Provider.of<NewPostProvider>(context, listen: false);
    _contentController = TextEditingController(text: dataModel.content);
    contentCounter =
        ValueNotifier('${dataModel.content.characters.length}/1000')
          ..addListener(() {
            dataModel.content = _contentController.text;
          });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget inputField = TextField(
      controller: _contentController,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      minLines: 1,
      maxLines: 100,
      style: TextUtil.base.NotoSansSC.w400.sp(16).h(1.4).label(context),
      decoration: InputDecoration.collapsed(
        hintStyle: TextUtil.base.NotoSansSC.w500.sp(16).infoText(context),
        hintText: '请添加正文',
      ),
      onChanged: (text) {
        contentCounter.value = '${text.characters.length}/1000';
      },
      scrollPhysics: NeverScrollableScrollPhysics(),
      inputFormatters: [
        CustomizedLengthTextInputFormatter(1000),
      ],
      cursorColor: WpyTheme.of(context).get(WpyColorKey.profileBackgroundColor),
    );

    Widget bottomTextCounter = ValueListenableBuilder(
      valueListenable: contentCounter,
      builder: (_, String value, __) {
        return Text(value,
            style: TextUtil.base.NotoSansSC.w500.sp(12).infoText(context));
      },
    );

    return Container(
        constraints: BoxConstraints(
            minHeight: WePeiYangApp.screenHeight > 800
                ? WePeiYangApp.screenHeight - 700
                : 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [inputField, SizedBox(height: 20), bottomTextCounter],
        ));
  }
}

class ImagesGridView extends StatefulWidget {
  @override
  _ImagesGridViewState createState() => _ImagesGridViewState();
}

class _ImagesGridViewState extends State<ImagesGridView> {
  static const maxImage = 3;

  loadAssets() async {
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(context,
        pickerConfig: AssetPickerConfig(
            maxAssets: 1,
            requestType: RequestType.image,
            themeColor:
                WpyTheme.of(context).get(WpyColorKey.primaryActionColor)));
    if (assets == null) return; // 取消选择图片的情况
    for (int i = 0; i < assets.length; i++) {
      File? file = await assets[i].file;
      if (file == null) {
        ToastProvider.error('选取图片异常，请重新尝试');
        return;
      }
      for (int j = 0; file!.lengthSync() > 2000 * 1024 && j < 10; j++) {
        final targetPath = '${file.path}_compressed.jpg';
        final r = await FlutterImageCompress.compressAndGetFile(
            file.path, targetPath, quality: 80);
        if (r != null) file = File(r.path);
        if (j == 10) {
          ToastProvider.error('您的图片 ${i + 1} 实在太大了，请自行压缩到2MB内再试吧');
          return;
        }
      }
      Provider.of<NewPostProvider>(context, listen: false).images.add(file);
    }
    if (!mounted) return;
    setState(() {});
  }

  Widget imgBuilder(index, List<File> data, length, {onTap, mask = false}) {
    return Stack(fit: StackFit.expand, children: [
      WButton(
        onPressed: () => Navigator.pushNamed(
            context, FeedbackRouter.localImageView,
            arguments: LocalImageViewPageArgs(data, [], length, index)),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(
                  color:
                      WpyTheme.of(context).get(WpyColorKey.dislikeSecondary)),
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: ClipRRect(
            child: () {
              final img = Image.file(
                data[index],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              );

              return AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: mask
                    ? SpoilerMaskImage(
                        child: img,
                        particleCount: 100,
                      )
                    : img,
              );
            }(),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),

      // 右下角的编辑符号
      Positioned(
        right: 0,
        bottom: 0,
        child: WButton(
          onPressed: onTap,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: WpyTheme.of(context).get(WpyColorKey.dislikeSecondary),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
            ),
            child: Icon(
              Icons.edit,
              size: MediaQuery.of(context).size.width / 32,
              color: WpyTheme.of(context)
                  .get(WpyColorKey.secondaryBackgroundColor),
            ),
          ),
        ),
      ),
    ]);
  }

  showImageOptions(data, index) {
    final red = WpyTheme.of(context).get(WpyColorKey.dangerousRed);
    showModalBottomSheet(
        context: context,
        useSafeArea: true,
        clipBehavior: Clip.antiAlias,
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        builder: (_) {
          return SafeArea(
            child: Wrap(
              children: [
                // masked
                ListTile(
                  tileColor: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  title: Row(
                    children: [
                      Icon(Icons.grain),
                      SizedBox(width: 10),
                      Text(!data.masked.contains(index) ? '罩住图片' : '取消遮罩'),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    print(data.masked);
                    if (data.masked.contains(index))
                      data.masked.remove(index);
                    else
                      data.masked.add(index);
                    setState(() {});
                  },
                ),
                //delete
                ListTile(
                  tileColor: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  title: Row(
                    children: [
                      Icon(Icons.delete, color: red),
                      SizedBox(width: 10),
                      Text(
                        '删除图片',
                        style: TextStyle(color: red),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    data.images.removeAt(index);
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4, //方便右边宽度留白哈哈
      childAspectRatio: 1,
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
    );

    return Consumer<NewPostProvider>(
      builder: (_, data, __) => GridView.builder(
        shrinkWrap: true,
        gridDelegate: gridDelegate,
        itemCount: maxImage == data.images.length
            ? data.images.length
            : data.images.length + 1,
        itemBuilder: (_, index) {
          if (index <= 2 && index == data.images.length) {
            return _ImagePickerWidget(onTap: loadAssets);
          } else {
            return imgBuilder(
              index,
              data.images,
              data.images.length,
              onTap: () => showImageOptions(data, index),
              mask: data.masked.contains(index),
            );
          }
        },
        physics: NeverScrollableScrollPhysics(),
      ),
    );
  }
}

class _ImagePickerWidget extends StatelessWidget {
  const _ImagePickerWidget({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: WpyTheme.of(context).get(WpyColorKey.dislikeSecondary)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          Icons.crop_original,
          color: WpyTheme.of(context).get(WpyColorKey.basicTextColor),
        ),
        onPressed: onTap,
      ),
    );
  }
}

/// 自定义兼容中文拼音输入法长度限制输入框
/// https://www.jianshu.com/p/d2c50b9271d3
class CustomizedLengthTextInputFormatter extends TextInputFormatter {
  final int maxLength;

  CustomizedLengthTextInputFormatter(this.maxLength);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.isComposingRangeValid) return newValue;
    return LengthLimitingTextInputFormatter(maxLength)
        .formatEditUpdate(oldValue, newValue);
  }
}
