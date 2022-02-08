import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_svg/svg.dart';
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
import 'package:we_pei_yang_flutter/feedback/view/components/widget/tab_grid_view.dart';

import '../feedback_router.dart';
import 'components/widget/tag_search_card.dart';

class NewPostPage extends StatefulWidget {
  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  // 0 -> 不区分; 1 -> 卫津路; 2 -> 北洋园
  final campusNotifier = ValueNotifier(0);

  // 0 -> 青年湖底; 1 -> 校务专区
  final postTypeNotifier = ValueNotifier(PostType.feedback);

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      centerTitle: true,
      title: Text(
        S.current.feedback_new_post,
        style: TextUtil.base.NotoSansSC.w500.sp(18).black2A,
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
        preferredSize: Size.fromHeight(58),
        child: TitleInputField(),
      ),
      backgroundColor: Colors.transparent,
    );

    return Scaffold(
        backgroundColor: ColorUtil.backgroundColor,
        appBar: appBar,
        body: ListView(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              LakeSelector(),
              SizedBox(height: 10),
              TagView(postTypeNotifier),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    shape: BoxShape.rectangle,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
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
                            SubmitButton(campusNotifier, postTypeNotifier),
                          ],
                        ),
                      ]))
            ]));
  }
}

enum PostType { lake, feedback }

extension PostTypeExt on PostType {
  int get value => [0, 1][index];

  String get title => ["青年湖底", "校务专区"][index];
}

class LakeSelector extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LakeSelectorState();
}

class LakeSelectorState extends State<LakeSelector> {
  @override
  Widget build(BuildContext context) {
    final notifier =
        context.findAncestorStateOfType<_NewPostPageState>().postTypeNotifier;
    return ValueListenableBuilder<PostType>(
      valueListenable: notifier,
      builder: (context, type, _) {
        return SizedBox(
          height: 60,
          child: ListView.builder(
            itemCount: 2,
            scrollDirection: Axis.horizontal,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return SizedBox(
                height: 58,
                width: (WePeiYangApp.screenWidth - 40) / 2,
                child: ElevatedButton(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        PostType.values[index].title,
                        style: type.value == index
                            ? TextUtil.base.NotoSansSC.w500.sp(18).black2A
                            : TextUtil.base.NotoSansSC.w400.sp(18).grey6C,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: type.value == index
                                ? ColorUtil.mainColor
                                : Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(16))),
                        width: 30,
                        height: 4,
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: _judgeBorder(index)),
                    primary: Colors.white,
                    elevation: 0,
                  ),
                  onPressed: () {
                    notifier.value = PostType.values[index];
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  BorderRadius _judgeBorder(int index) {
    if (index == 0)
      return BorderRadius.horizontal(left: Radius.circular(16));
    else
      return BorderRadius.horizontal(right: Radius.circular(16));
  }
}

class SubmitButton extends StatelessWidget {
  final ValueNotifier campusNotifier, postTypeNotifier;

  const SubmitButton(this.campusNotifier, this.postTypeNotifier, {Key key})
      : super(key: key);

  void submit(BuildContext context) {
    var dataModel = Provider.of<NewPostProvider>(context, listen: false);
    if (dataModel.images.isNotEmpty) {
      FeedbackService.postPic(
          images: dataModel.images,
          onResult: (images) {
            print(images);
            dataModel.images.clear();
            dataModel.type =
                postTypeNotifier.value == PostType.feedback ? 1 : 0;
            if (dataModel.check) {
              postTypeNotifier.value == PostType.feedback
                  ? FeedbackService.sendPost(
                      type: PostType.feedback.value,
                      title: dataModel.title,
                      content: dataModel.content,
                      departmentId: dataModel.department.id,
                      images: images,
                      campus: campusNotifier.value,
                      onSuccess: () {
                        ToastProvider.success(S.current.feedback_post_success);
                        Navigator.pop(context);
                      },
                      onFailure: (e) {
                        ToastProvider.error(e.error.toString());
                      },
                    )
                  : FeedbackService.sendPost(
                      type: PostType.lake.value,
                      title: dataModel.title,
                      content: dataModel.content,
                      tagId: dataModel.tag.id,
                      images: images,
                      campus: campusNotifier.value,
                      onSuccess: () {
                        ToastProvider.success(S.current.feedback_post_success);
                        Navigator.pop(context);
                      },
                      onFailure: (e) {
                        ToastProvider.error(e.error.toString());
                      },
                    );
              dataModel.clear();
            } else {
              ToastProvider.error(S.current.feedback_empty_content_error);
            }
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
          });
    } else {
      dataModel.type = postTypeNotifier.value == PostType.feedback ? 1 : 0;
      if (dataModel.check) {
        postTypeNotifier.value == PostType.feedback
            ? FeedbackService.sendPost(
                type: PostType.feedback.value,
                title: dataModel.title,
                content: dataModel.content,
                departmentId: dataModel.department.id,
                images: [],
                campus: campusNotifier.value,
                onSuccess: () {
                  ToastProvider.success(S.current.feedback_post_success);
                  Navigator.pop(context);
                },
                onFailure: (e) {
                  ToastProvider.error(e.error.toString());
                },
              )
            : FeedbackService.sendPost(
                type: PostType.lake.value,
                title: dataModel.title,
                content: dataModel.content,
                tagId: dataModel.tag.id,
                images: [],
                campus: campusNotifier.value,
                onSuccess: () {
                  ToastProvider.success(S.current.feedback_post_success);
                  Navigator.pop(context);
                },
                onFailure: (e) {
                  ToastProvider.error(e.error.toString());
                },
              );
        dataModel.clear();
      } else {
        ToastProvider.error(S.current.feedback_empty_content_error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "addNewPost",
      child: ElevatedButton(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(1),
          backgroundColor: MaterialStateProperty.all(ColorUtil.mainColor),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
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

class TagView extends StatefulWidget {
  final ValueNotifier postTypeNotifier;

  const TagView(this.postTypeNotifier, {Key key}) : super(key: key);

  @override
  _TagViewState createState() => _TagViewState();
}

class _TagViewState extends State<TagView> {
  ValueNotifier<Department> department;

  @override
  void initState() {
    super.initState();
    var dataModel = Provider.of<NewPostProvider>(context, listen: false);
    department = ValueNotifier(dataModel.department)
      ..addListener(() {
        dataModel.department = department.value;
      });
  }

  @override
  Widget build(BuildContext context) {
    final notifier =
        context.findAncestorStateOfType<_NewPostPageState>().postTypeNotifier;
    return ValueListenableBuilder<PostType>(
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
            child: notifier.value == PostType.feedback
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
          offset: Offset(-120, -89),
          tooltip: "校区",
          child: Row(
            children: [
              SvgPicture.asset(
                "assets/svg_pics/lake_butt_icons/map.svg",
                width: 16,
              ),
              SizedBox(width: 10),
              Text(
                texts[value],
                style: TextUtil.base.sp(14).w400.NotoSansSC.normal,
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

class RacTangle extends ShapeBorder {
  @override
  // ignore: missing_return
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return null;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    var path = Path();
    path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(20)));
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    var paint = Paint()
      ..color = Colors.transparent
      ..strokeWidth = 12.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    var w = rect.width;
    var d = rect.height;
    var tang = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.square
      ..color = Colors.white
      ..strokeWidth = 5;
    //var h = rect.height;
    canvas.drawLine(Offset(w, 0), Offset(w, 40), paint);
    canvas.drawLine(Offset(w, 40), Offset(w + 4, 45), tang);
    canvas.drawLine(Offset(w + 4, 45), Offset(w, 50), tang);
    canvas.drawLine(Offset(w, 50), Offset(w, d), paint);
    Rect rect1 = Rect.fromCircle(center: Offset(w / 2, d / 2), radius: 140);
    Rect rect2 = Rect.fromCircle(center: Offset(w / 2, d / 2), radius: 160);
    RRect rRect1 = RRect.fromRectAndRadius(rect1, Radius.circular(20));
    RRect rRect2 = RRect.fromRectAndRadius(rect2, Radius.circular(20));
    canvas.drawDRRect(rRect2, rRect1, paint);
  }

  @override
  ShapeBorder scale(double t) {
    return null;
  }

  @override
  EdgeInsetsGeometry get dimensions => null;
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
    var dataModel = Provider.of<NewPostProvider>(context, listen: false);
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
        return Text(value, style: TextUtil.base.NotoSansSC.w500.sp(12).grey6C);
      },
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        shape: BoxShape.rectangle,
      ),
      margin: const EdgeInsets.fromLTRB(20, 5, 20, 15),
      padding: const EdgeInsets.fromLTRB(22, 15, 22, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [inputField, SizedBox(width: 3), textCounter],
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
        hintText: '${S.current.feedback_detail}...',
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
      themeColor: ColorUtil.selectionButtonColor
    );
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
