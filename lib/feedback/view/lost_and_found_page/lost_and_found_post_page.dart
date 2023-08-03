import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/view/new_post_page.dart';

import '../../../commons/util/text_util.dart';
import '../../../commons/widgets/loading.dart';
import '../../../main.dart';
import '../../util/color_util.dart';

class NewLostAndFoundPostProvider {
  String title = "";
  String content = "";
  String category = "";
  String date = "";
  String location = "";
  String phone = "";

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
  //final NewLostAndFoundPostArgs args;

  //const LostAndFoundPostPage(this.args);

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

  _LAFsubmit() async {
    //final args = widget.args;
    var dataModel = context.read<NewLostAndFoundPostProvider>();
    if (!dataModel.check) {
      ToastProvider.error("内容与标题不能为空！");
      return;
    }
    ToastProvider.running("创建中...");
    _showLoading();
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
              await _LAFsubmit();
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
    var dataModel = Provider.of<NewPostProvider>(context, listen: false);
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
