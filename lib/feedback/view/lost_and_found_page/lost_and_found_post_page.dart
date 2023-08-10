import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/new_post_page.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../commons/util/text_util.dart';
import '../../../commons/widgets/loading.dart';
import '../../../generated/l10n.dart';
import '../../../main.dart';
import '../../feedback_router.dart';
import '../../util/color_util.dart';
import '../image_view/local_image_view_page.dart';

class NewLostAndFoundPostProvider {
  String title = "";
  String content = "";
  String category = "";
  String date = "";
  String location = "";
  String phone = "";

  List<File> images = [];

  bool get check =>
      title.isNotEmpty &&
      content.isNotEmpty &&
      date.isNotEmpty &&
      location.isNotEmpty &&
      phone.isNotEmpty;

  void clear() {
    title = "";
    content = "";
    category = "";
    date = "";
    location = "";
    phone = "";
  }
}

class LostAndFoundPostPage extends StatefulWidget {

  @override
  State<LostAndFoundPostPage> createState() => _LostAndFoundPostPageState();
}

class NewLostAndFoundPostArgs {
  final int type;

  //0->失物 1->招领
  NewLostAndFoundPostArgs(this.type);
}

class _LostAndFoundPostPageState extends State<LostAndFoundPostPage> {
  bool postType = false;
  String _selectCategory = "选择分类";

  //0->失物 1->招领
  bool tapAble = true;
  bool _showSelectDialog = false;
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  _showLoading() {
    showDialog(context: context, builder: (_) => Loading());
  }

  _submit() async {
    var dataModel = context.read<NewLostAndFoundPostProvider>();
    if (!dataModel.check) {
      ToastProvider.error("内容与标题不能为空！");
      return;
    }
    ToastProvider.running("创建中...");
    _showLoading();
    if (dataModel.images.isNotEmpty) {
      FeedbackService.postLostAndFoundPic(
          images: dataModel.images,
          onResult: (images) {
            dataModel.images.clear();
            if (dataModel.check) {
              FeedbackService.sendLostAndFoundPost(
                  type: 1,
                  category: dataModel.category,
                  title: dataModel.title,
                  text: dataModel.content,
                  yyyymmdd: dataModel.date,
                  location: dataModel.location,
                  phone: dataModel.phone,
                  images: images,
                  onSuccess: () {
                    ToastProvider.success(S.current.feedback_post_success);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  onFailure: (e) {
                    dataModel.clear();
                    ToastProvider.error(e.error.toString());
                    Navigator.pop(context);
                  });
              dataModel.clear();
            }
          },
          onFailure: (e) {
            Navigator.pop(context);
            ToastProvider.error('发送图片失败或图片不合规\n${e.error.toString()}');
          });
    } else {
      FeedbackService.sendLostAndFoundPost(
        type: 1,
        category: dataModel.category,
        title: dataModel.title,
        text: dataModel.content,
        yyyymmdd: dataModel.date,
        location: dataModel.location,
        phone: dataModel.phone,
        images: [],
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
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
        title: Text(
          postType ? "发布失物" : "发布招领",
          style: TextStyle(
              color: Color.fromARGB(255, 42, 42, 42),
              fontSize: 18,
              fontWeight: FontWeight.w400),
        ),
        actions: [
          InkWell(
            onTap: () async {
              if (tapAble) {
                tapAble = false;
                setState(() {
                  postType = !postType;
                });
                await Future.delayed(Duration(milliseconds: 500));
                tapAble = true;
              }
            },
            child: Container(
              width: 36,
              height: 36,
              child: Column(
                children: [
                  Image.asset("assets/images/post_swap.png"),
                  Text(
                    postType ? "招领" : "失物",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        color: Color.fromARGB(255, 81, 137, 220)),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TitleInputField(),
            LostAndFoundContentInputField(),
            ImagesGridView(),
            Container(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  SelectDateButton(context),
                  const SizedBox(height: 8),
                  InputCategoryField(),
                  const SizedBox(height: 8),
                  InputPhoneField(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Container(
              height: 150,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  selectCategoryDialog(context),
                  SelectCategoryButton(),
                  const SizedBox(width: 8),
                  LostAndFoundPostButton()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  TextButton SelectCategoryButton() {
    return TextButton(
        onPressed: () {
          setState(() {
            _showSelectDialog = true;
          });
        },
        child: Text(
          "# ${_selectCategory}",
          style: const TextStyle(color: Color.fromARGB(255, 44, 126, 223)),
        ));
  }

  Visibility selectCategoryDialog(BuildContext context) {
    return Visibility(
        visible: _showSelectDialog,
        child: Container(
          margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
          padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
          height: 120,
          width: 86,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    offset: Offset(0, 3),
                    blurRadius: 6,
                    color: Color.fromARGB(64, 0, 0, 0))
              ]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildSelectCategoryOption("生活日用", context),
              buildSelectCategoryOption("数码产品", context),
              buildSelectCategoryOption("钱包卡证", context),
              buildSelectCategoryOption("其他", context),
            ],
          ),
        ));
  }

  Container SelectDateButton(BuildContext context) {
    return Container(
      width: 195,
      height: 36,
      padding: EdgeInsets.zero,
      child: ElevatedButton(
        onPressed: () => _selectDate(context),
        style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            backgroundColor: MaterialStateProperty.all(
                const Color.fromARGB(255, 248, 248, 248)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 17,
              height: 17,
              child: selectedDate != null
                  ? Image.asset("assets/images/icon_clock_filled.png")
                  : Image.asset("assets/images/icon_clock.png"),
            ),
            const SizedBox(width: 8),
            selectedDate != null
                ? Text(
                    "${selectedDate!.year}年${selectedDate!.month}月${selectedDate!.day}日",
                    style: const TextStyle(
                        color: Color.fromARGB(255, 44, 126, 223)),
                  )
                : Text(
                    "请填写丢失日期",
                    style: const TextStyle(
                        color: Color.fromARGB(255, 144, 144, 144)),
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildSelectCategoryOption(String option, BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectCategory = option;
          _showSelectDialog = false;
        });
      },
      child: Container(
        child: Text(
          option,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  SizedBox LostAndFoundPostButton() {
    return SizedBox(
      width: 63,
      height: 32,
      child: ElevatedButton(
          style: ButtonStyle(
              elevation: MaterialStateProperty.all(0),
              backgroundColor: MaterialStateProperty.all(
                  const Color.fromARGB(255, 44, 126, 223)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)))),
          onPressed: () async {
            if (tapAble) {
              tapAble = false;
              await _submit();
              await Future.delayed(Duration(milliseconds: 3000));
              tapAble = true;
            }
          },
          child: const Text('发送')),
    );
  }
}

class InputCategoryField extends StatefulWidget {
  @override
  _InputCategoryFieldState createState() => _InputCategoryFieldState();
}

class _InputCategoryFieldState extends State<InputCategoryField> {
  late final ValueNotifier<String> contentCounter;
  late final TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    var dataModel =
        Provider.of<NewLostAndFoundPostProvider>(context, listen: false);
    _categoryController = TextEditingController(text: dataModel.category);
    contentCounter =
        ValueNotifier('${dataModel.category.characters.length}/1000')
          ..addListener(() {
            dataModel.category = _categoryController.text;
          });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget inputField = TextField(
      controller: _categoryController,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      maxLines: 1,
      style: TextUtil.base.NotoSansSC.w400.sp(16).h(1.4).black2A,
      decoration: InputDecoration.collapsed(
        hintStyle: const TextStyle(
            fontSize: 16, color: Color.fromARGB(255, 144, 144, 144)),
        hintText: '请填写丢失地点',
      ),
      scrollPhysics: NeverScrollableScrollPhysics(),
      inputFormatters: [
        CustomizedLengthTextInputFormatter(15),
      ],
      cursorColor: ColorUtil.profileBackgroundColor,
    );

    return Container(
        width: 195,
        height: 36,
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 248, 248, 248),
            borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(30, 3, 0, 0),
              child: Image.asset("assets/images/icon_location.png"),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(55, 0, 0, 0),
              child: inputField,
            )
          ],
        ));
  }
}

class InputPhoneField extends StatefulWidget {
  @override
  _InputPhoneFieldState createState() => _InputPhoneFieldState();
}

class _InputPhoneFieldState extends State<InputPhoneField> {
  late final ValueNotifier<String> contentCounter;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    var dataModel =
        Provider.of<NewLostAndFoundPostProvider>(context, listen: false);
    _phoneController = TextEditingController(text: dataModel.phone);
    contentCounter = ValueNotifier('${dataModel.phone.characters.length}/1000')
      ..addListener(() {
        dataModel.phone = _phoneController.text;
      });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget inputField = TextField(
      controller: _phoneController,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      maxLines: 1,
      style: TextUtil.base.NotoSansSC.w400.sp(16).h(1.4).black2A,
      decoration: InputDecoration.collapsed(
        hintStyle: const TextStyle(
            fontSize: 16, color: Color.fromARGB(255, 144, 144, 144)),
        hintText: '请填写联系方式',
      ),
      scrollPhysics: NeverScrollableScrollPhysics(),
      inputFormatters: [
        CustomizedLengthTextInputFormatter(15),
      ],
      cursorColor: ColorUtil.profileBackgroundColor,
    );

    return Container(
        width: 195,
        height: 36,
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 248, 248, 248),
            borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(30, 3, 0, 0),
              child: Image.asset("assets/images/icon_smile_chat.png"),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(55, 0, 0, 0),
              child: inputField,
            )
          ],
        ));
  }
}

class LostAndFoundTitleInputField extends StatefulWidget {
  @override
  _TitleInputFieldState createState() => _TitleInputFieldState();
}

class _TitleInputFieldState extends State<LostAndFoundTitleInputField> {
  late final ValueNotifier<String> titleCounter;
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    var dataModel = context.read<NewLostAndFoundPostProvider>();
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

class LostAndFoundContentInputField extends StatefulWidget {
  @override
  _LostAndFoundContentInputFieldState createState() =>
      _LostAndFoundContentInputFieldState();
}

class _LostAndFoundContentInputFieldState
    extends State<LostAndFoundContentInputField> {
  late final ValueNotifier<String> contentCounter;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    var dataModel =
        Provider.of<NewLostAndFoundPostProvider>(context, listen: false);
    _contentController = TextEditingController(text: dataModel.content);
    contentCounter = ValueNotifier('${dataModel.content.characters.length}/300')
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
      style: TextUtil.base.NotoSansSC.w400.sp(16).h(1.4).black2A,
      decoration: InputDecoration.collapsed(
        hintStyle: TextUtil.base.NotoSansSC.w500.sp(16).grey6C,
        hintText: '请添加正文',
      ),
      onChanged: (text) {
        contentCounter.value = '${text.characters.length}/300';
      },
      scrollPhysics: NeverScrollableScrollPhysics(),
      inputFormatters: [
        CustomizedLengthTextInputFormatter(300),
      ],
      cursorColor: ColorUtil.profileBackgroundColor,
    );

    Widget bottomTextCounter = ValueListenableBuilder(
      valueListenable: contentCounter,
      builder: (_, String value, __) {
        return Text(value, style: TextUtil.base.NotoSansSC.w500.sp(12).grey6C);
      },
    );

    return Container(
        padding: EdgeInsets.all(20),
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

class LostAndFoundImagesGridView extends StatefulWidget {
  @override
  _LostAndFoundImagesGridViewState createState() =>
      _LostAndFoundImagesGridViewState();
}

class _LostAndFoundImagesGridViewState
    extends State<LostAndFoundImagesGridView> {
  static const maxImage = 3;

  loadAssets() async {
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
          maxAssets: maxImage -
              context.read<NewLostAndFoundPostProvider>().images.length,
          requestType: RequestType.image,
          themeColor: ColorUtil.selectionButtonColor),
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
      Provider.of<NewLostAndFoundPostProvider>(context, listen: false)
          .images
          .add(file);
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<String?> _showDialog() {
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
            arguments: LocalImageViewPageArgs(data, [], length, index)),
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

    return Consumer<NewLostAndFoundPostProvider>(
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
    return ElevatedButton(
        onPressed: onTap,
        child: Image.asset("assets/images/crop_original.png"));
  }
}

class LAFInputButton extends StatelessWidget {
  final String imagePath;
  final String hintText;

  LAFInputButton({
    required this.imagePath,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 195,
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: Color.fromARGB(255, 248, 248, 248),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, width: 17, height: 17),
          SizedBox(width: 8),
        ],
      ),
    );
  }
}
