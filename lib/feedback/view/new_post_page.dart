import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/tag_grid_view.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
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

    if (!dataModel.check) {
      dataModel.type == 1
          ? ToastProvider.error('内容标题与部门不能为空！')
          : ToastProvider.error('内容与标题不能为空！');
      return;
    }
    ToastProvider.running("创建中...");
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
                campus: campusNotifier.value,
                onSuccess: () {
                  ToastProvider.success(S.current.feedback_post_success);
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
          ToastProvider.success(S.current.feedback_post_success);
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

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text(
        S.current.feedback_new_post,
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
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );

    final submitButton = Hero(
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
        child: Text(S.current.feedback_submit,
            style: TextUtil.base.NotoSansSC.w500.sp(14).bright(context)),
      ),
    );

    return Scaffold(
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        appBar: appBar,
        body: Column(
          children: [
            TitleInputField(),
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
                      SizedBox(height: 30),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ContentInputField(),
                            SizedBox(height: 10),
                            ImagesGridView(),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Spacer(),
                                CampusSelector(campusNotifier),
                                submitButton,
                              ],
                            ),
                          ]),
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
    final status = context.select((LakeModel model) => model.mainStatus);
    final tabList = context.select((LakeModel model) => model.tabList);
    return switch (status) {
      LakePageStatus.unload => SizedBox(),
      LakePageStatus.loading => Container(
          height: 60,
          child: Center(
            child: Loading(),
          ),
        ),
      LakePageStatus.error => Container(
          height: 60,
          decoration: BoxDecoration(
              color:
                  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
              borderRadius: BorderRadius.circular(16)),
          child: Center(
            child: Text('点击刷新'),
          ),
        ),
      LakePageStatus.idle => SizedBox(
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
                                context.read<NewPostProvider>().department =
                                    null;
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
                                                  WpyColorKey
                                                      .primaryActionColor)
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
                        color: WpyTheme.of(context)
                            .get(WpyColorKey.labelTextColor),
                        size: 10.h),
                  ),
                ),
              ),
            ],
          )),
    };
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
          shape: RacTangle(),
          offset: Offset(-120.w, -60.w),
          tooltip: "校区",
          child: Row(
            children: [
              SvgPicture.asset(
                "assets/svg_pics/lake_butt_icons/map.svg",
                width: 16,
                color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
              ),
              SizedBox(width: 10),
              Text(
                texts[value],
                style: TextUtil.base
                    .sp(14)
                    .w400
                    .NotoSansSC
                    .normal
                    .primaryAction(context),
              ),
              SizedBox(width: 18),
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
          hintText: S.current.feedback_enter_title,
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
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
          maxAssets: maxImage - context.read<NewPostProvider>().images.length,
          requestType: RequestType.image,
          themeColor:
              WpyTheme.of(context).get(WpyColorKey.primaryTextButtonColor)),
    );
    if (assets == null) return; // 取消选择图片的情况
    for (int i = 0; i < assets.length; i++) {
      File? file = await assets[i].file;
      if (file == null) {
        ToastProvider.error('选取图片异常，请重新尝试');
        return;
      }
      for (int j = 0; file!.lengthSync() > 2000 * 1024 && j < 10; j++) {
        file = await FlutterNativeImage.compressImage(file.path, quality: 80);
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

  Future<String?> _showDialog() {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        titleTextStyle: TextUtil.base.NotoSansSC.w500.sp(14).label(context),
        title: Text(S.current.feedback_delete_image_content),
        actions: [
          WButton(
              onPressed: () {
                Navigator.of(context).pop('cancel');
              },
              child: Text(S.current.feedback_cancel)),
          WButton(
              onPressed: () {
                Navigator.of(context).pop('ok');
              },
              child: Text(S.current.feedback_ok)),
        ],
      ),
    );
  }

  Widget imgBuilder(index, List<File> data, length, {onTap}) {
    return Stack(fit: StackFit.expand, children: [
      WButton(
        onPressed: () => Navigator.pushNamed(
            context, FeedbackRouter.localImageView,
            arguments: LocalImageViewPageArgs(data, [], length, index)),
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(
                  width: 1,
                  color:
                      WpyTheme.of(context).get(WpyColorKey.dislikeSecondary)),
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: ClipRRect(
            child: Image.file(
              data[index],
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
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
              Icons.close,
              size: MediaQuery.of(context).size.width / 32,
              color: WpyTheme.of(context)
                  .get(WpyColorKey.secondaryBackgroundColor),
            ),
          ),
        ),
      ),
    ]);
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
              onTap: () async {
                var result = await _showDialog();
                if (result == 'ok') {
                  data.images.removeAt(index);
                  setState(() {});
                }
              },
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
    return IconButton(
      icon: Icon(
        Icons.crop_original,
        color: WpyTheme.of(context).get(WpyColorKey.basicTextColor),
      ),
      onPressed: onTap,
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
