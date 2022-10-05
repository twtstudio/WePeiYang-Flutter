import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_svg/svg.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/tag_grid_view.dart';

import '../feedback_router.dart';
import 'components/widget/pop_menu_shape.dart';
import 'components/widget/tag_search_card.dart';
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
  final postTypeNotifier = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      centerTitle: true,
      title: Text(
        S.current.feedback_new_post,
        style: TextUtil.base.NotoSansSC.w700.sp(18).black2A,
      ),
      brightness: Brightness.light,
      elevation: 0,
      leading: IconButton(
        padding: EdgeInsets.zero,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: Color(0XFF62677B),
          size: 36,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(50.h),
        child: TitleInputField(),
      ),
      backgroundColor: Colors.transparent,
    );

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar,
        body: ListView(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 20),
            children: [
              Container(
                  margin: widget.args.isFollowing
                      ? const EdgeInsets.only(right: 20, top: 4, bottom: 10)
                      : EdgeInsets.zero,
                  padding: widget.args.isFollowing
                      ? const EdgeInsets.fromLTRB(22, 10, 22, 10)
                      : EdgeInsets.zero,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.args.isFollowing
                            ? Text('跟帖:',
                                style: TextUtil.base.NotoSansSC.w500
                                    .sp(14)
                                    .black2A)
                            : LakeSelector(),
                        SizedBox(height: 6),
                      ])),
              Container(
                  margin: const EdgeInsets.only(right: 20, top: 4),
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 22),
                  child: Column(
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
                            SubmitButton(campusNotifier, postTypeNotifier,
                                args: widget.args),
                          ],
                        ),
                      ])),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: widget.args.isFollowing
                    ? Text('${widget.args.tagName}'.substring(3),
                        style: TextUtil.base.NotoSansSC.w500.sp(14).black2A)
                    : departmentTagView(postTypeNotifier),
              ),
            ]));
  }
}

class LakeSelector extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LakeSelectorState();
}

class _LakeSelectorState extends State<LakeSelector> {
  ScrollController controller = new ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final notifier =
        context.findAncestorStateOfType<_NewPostPageState>().postTypeNotifier;
    final status = context.select((LakeModel model) => model.mainStatus);
    final tabList = context.select((LakeModel model) => model.tabList);
    notifier.value = tabList[1].id;

    return status == LakePageStatus.unload
        ? SizedBox()
        : status == LakePageStatus.loading
            ? Container(
                height: 60,
                child: Center(
                  child: Loading(),
                ),
              )
            : status == LakePageStatus.idle
                ? SizedBox(
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
                                      return InkWell(
                                        onTap: () {
                                          notifier.value =
                                              tabList[index + 1].id;

                                          ///在切换发帖区时，要清空department，不然就会导致参数问题
                                          context
                                              .read<NewPostProvider>()
                                              .department = null;
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 25.w),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(tabList[index + 1].shortname,
                                                  style: type ==
                                                          tabList[index + 1].id
                                                      ? TextUtil
                                                          .base.NotoSansSC.w400
                                                          .sp(15)
                                                          .blue2C
                                                      : TextUtil.base.w400
                                                          .sp(15)
                                                          .black2A),
                                              Container(
                                                margin: EdgeInsets.only(top: 2),
                                                decoration: BoxDecoration(
                                                    color: type ==
                                                            tabList[index + 1]
                                                                .id
                                                        ? ColorUtil.blue2CColor
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                16))),
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
                                  ? controller.animateTo(
                                      controller.offset + 100,
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
                                  color: ColorUtil.black2AColor, size: 10.h),
                            ),
                          ),
                        ),
                      ],
                    ))
                : Container(
                    height: 60,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Center(
                      child: Text('点击刷新'),
                    ),
                  );
  }
}

class SubmitButton extends StatelessWidget {
  final ValueNotifier campusNotifier, postTypeNotifier;
  final NewPostArgs args;

  const SubmitButton(this.campusNotifier, this.postTypeNotifier,
      {Key key, this.args})
      : super(key: key);

  void submit(BuildContext context) {
    var dataModel = context.read<NewPostProvider>();
    dataModel.type = postTypeNotifier.value;
    if (dataModel.images.isNotEmpty && dataModel.check) {
      FeedbackService.postPic(
          images: dataModel.images,
          onResult: (images) {
            dataModel.images.clear();
            if (dataModel.check) {
              FeedbackService.sendPost(
                type: args.isFollowing ? args.type : dataModel.type,
                title: dataModel.title,
                content: dataModel.content,
                tagId: args.isFollowing
                    ? args.tagId
                    : dataModel.tag == null
                        ? ''
                        : dataModel.tag.id,
                departmentId:
                    dataModel.department == null ? '' : dataModel.department.id,
                images: images,
                campus: campusNotifier.value,
                onSuccess: () {
                  ToastProvider.success(S.current.feedback_post_success);
                  Navigator.pop(context);
                },
                onFailure: (e) {
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
            ToastProvider.error('发送图片失败或图片不合规\n${e.error.toString()}');
          });
    } else {
      if (dataModel.check) {
        FeedbackService.sendPost(
          type: args.isFollowing ? args.type : dataModel.type,
          title: dataModel.title,
          content: dataModel.content,
          tagId: args.isFollowing
              ? args.tagId
              : dataModel.tag == null
                  ? ''
                  : dataModel.tag.id,
          departmentId:
              dataModel.department == null ? '' : dataModel.department.id,
          images: [],
          campus: campusNotifier.value,
          onSuccess: () {
            ToastProvider.success(S.current.feedback_post_success);
            Navigator.pop(context);
          },
          onFailure: (e) {
            dataModel.clear();
            ToastProvider.error(e.error.toString());
          },
        );
        dataModel.clear();
      } else {
        dataModel.type == 1
            ? ToastProvider.error('内容标题与部门不能为空！')
            : ToastProvider.error('内容与标题不能为空！');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "addNewPost",
      child: ElevatedButton(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0),
          backgroundColor: MaterialStateProperty.all(ColorUtil.blue2CColor),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        onPressed: () => submit(context),
        child: Text(S.current.feedback_submit,
            style: TextUtil.base.NotoSansSC.w500.sp(14).white),
      ),
    );
  }
}

class departmentTagView extends StatefulWidget {
  final ValueNotifier postTypeNotifier;

  const departmentTagView(this.postTypeNotifier, {Key key}) : super(key: key);

  @override
  _departmentTagViewState createState() => _departmentTagViewState();
}

class _departmentTagViewState extends State<departmentTagView> {
  ValueNotifier<Department> department;

  @override
  void initState() {
    super.initState();
    var dataModel = context.read<NewPostProvider>();
    department = ValueNotifier(dataModel.department)
      ..addListener(() {
        dataModel.department = department.value;
      });
  }

  @override
  Widget build(BuildContext context) {
    final notifier =
        context.findAncestorStateOfType<_NewPostPageState>().postTypeNotifier;
    return ValueListenableBuilder<int>(
        valueListenable: notifier,
        builder: (context, type, _) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              shape: BoxShape.rectangle,
            ),
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.fromLTRB(18, 0, 10, 4),
            child: notifier.value == 1
                ? TabGridView(
                    department: department.value,
                  )
                : SearchTagCard(),
          );
        });
  }
}

class CampusSelector extends StatefulWidget {
  final ValueNotifier campusNotifier;

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
      builder: (context, value, _) {
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
                color: ColorUtil.blue2CColor,
              ),
              SizedBox(width: 10),
              Text(
                texts[value],
                style: TextUtil.base.sp(14).w400.NotoSansSC.normal.blue2C,
              ),
              SizedBox(width: 18),
            ],
          ),
          onSelected: (value) {
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
  ValueNotifier<String> titleCounter;
  TextEditingController _titleController;

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
        style: TextUtil.base.NotoSansSC.w700.sp(18).h(1.2).black2A,
        minLines: 1,
        maxLines: 10,
        decoration: InputDecoration.collapsed(
          hintStyle: TextUtil.base.NotoSansSC.w500.sp(18).grey6C,
          hintText: S.current.feedback_enter_title,
        ),
        onChanged: (text) {
          titleCounter.value = '${text.characters.length} / 30';
        },
        inputFormatters: [
          CustomizedLengthTextInputFormatter(30),
        ],
        cursorColor: ColorUtil.boldTextColor,
        cursorHeight: 20,
      ),
    );

    Widget textCounter = ValueListenableBuilder(
      valueListenable: titleCounter,
      builder: (_, String value, __) {
        return Text(value, style: TextUtil.base.NotoSansSC.w400.sp(14).grey6C);
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
              color: ColorUtil.greyEAColor,
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
  ValueNotifier<String> contentCounter;
  TextEditingController _contentController;

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
      textInputAction: TextInputAction.done,
      minLines: 1,
      maxLines: 100,
      style: TextUtil.base.NotoSansSC.w400.sp(16).h(1.4).black2A,
      decoration: InputDecoration.collapsed(
        hintStyle: TextUtil.base.NotoSansSC.w500.sp(16).grey6C,
        hintText: '请添加正文',
      ),
      onChanged: (text) {
        contentCounter.value = '${text.characters.length}/1000';
      },
      scrollPhysics: NeverScrollableScrollPhysics(),
      inputFormatters: [
        CustomizedLengthTextInputFormatter(1000),
      ],
      cursorColor: ColorUtil.profileBackgroundColor,
    );

    Widget bottomTextCounter = ValueListenableBuilder(
      valueListenable: contentCounter,
      builder: (_, String value, __) {
        return Text(value, style: TextUtil.base.NotoSansSC.w500.sp(12).grey6C);
      },
    );

    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Container(
            constraints: BoxConstraints(
                minHeight: WePeiYangApp.screenHeight > 800
                    ? WePeiYangApp.screenHeight - 700
                    : 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [inputField, SizedBox(height: 20), bottomTextCounter],
            )),
      ],
    );
  }
}

class ImagesGridView extends StatefulWidget {
  @override
  _ImagesGridViewState createState() => _ImagesGridViewState();
}

class _ImagesGridViewState extends State<ImagesGridView> {
  static const maxImage = 3;

  loadAssets() async {
    final List<AssetEntity> assets = await AssetPicker.pickAssets(context,
        maxAssets: maxImage - context.read<NewPostProvider>().images.length,
        requestType: RequestType.image,
        themeColor: ColorUtil.selectionButtonColor);
    for (int i = 0; i < assets.length; i++) {
      File file = await assets[i].file;
      for (int j = 0; file.lengthSync() > 2000 * 1024 && j < 10; j++) {
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

  Future<String> _showDialog() {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        titleTextStyle: TextUtil.base.NotoSansSC.w500.sp(14).black2A,
        title: Text(S.current.feedback_delete_image_content),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop('cancel');
              },
              child: Text(S.current.feedback_cancel)),
          TextButton(
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
      InkWell(
        onTap: () => Navigator.pushNamed(context, FeedbackRouter.localImageView,
            arguments: {
              "uriList": data,
              "uriListLength": length,
              "indexNow": index
            }),
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(width: 1, color: Colors.black26),
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
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
            ),
            child: Icon(
              Icons.close,
              size: MediaQuery.of(context).size.width / 32,
              color: ColorUtil.searchBarBackgroundColor,
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
    Key key,
    this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.crop_original),
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
