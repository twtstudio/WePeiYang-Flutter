import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/model/tag.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_service.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/main.dart';

class NewPostProvider {
  String title = "";
  String content = "";
  Tag tag;

  List<File> imgList = [];

  bool get check => title.isNotEmpty && content.isNotEmpty && tag?.id != -1;
}

class NewPostPage extends StatefulWidget {
  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  Divider _divider() {
    return const Divider(
      height: 0.6,
      color: Color(0xffacaeba),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body = ListView(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 20),
      children: [
        TitleInputField(),
        _divider(),
        ContentInputField(),
        SizedBox(height: 10),
        ImagesGridView(),
        SizedBox(height: 10),
        TagView(),
        _divider(),
        SubmitButton(),
      ],
    );

    var boxDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      shape: BoxShape.rectangle,
      boxShadow: [
        BoxShadow(
            color: Colors.grey[200],
            blurRadius: 5.0, //阴影模糊程度
            spreadRadius: 5.0 //阴影扩散程度
            )
      ],
    );

    return DefaultTextStyle(
      style: FontManager.YaHeiRegular,
      child: _BasePage(
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
          child: Container(
            decoration: boxDecoration,
            child: body,
          ),
        ),
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    Key key,
  }) : super(key: key);

  void submit(BuildContext context) {
    var dataModel = Provider.of<NewPostProvider>(context, listen: false);
    if (dataModel.check) {
      FeedbackService.sendPost(
        title: dataModel.title,
        content: dataModel.content,
        tagId: dataModel.tag.id,
        imgList: dataModel.imgList,
        onSuccess: () {
          ToastProvider.success(S.current.feedback_post_success);
          Navigator.pop(context);
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
        },
      );
    } else {
      ToastProvider.error(S.current.feedback_empty_content_error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => submit(context),
            child: Text(
              S.current.feedback_submit,
              style: FontManager.YaHeiRegular.copyWith(
                fontWeight: FontWeight.bold,
                color: Color(0xff303c66),
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TagView extends StatefulWidget {
  @override
  _TagViewState createState() => _TagViewState();
}

class _TagViewState extends State<TagView> {
  ValueNotifier<Tag> tag;

  @override
  void initState() {
    super.initState();
    var dataModel = Provider.of<NewPostProvider>(context, listen: false);
    tag = ValueNotifier(dataModel.tag)
      ..addListener(() {
        dataModel.tag = tag.value;
      });
  }

  _showTags(BuildContext context) async {
    var result = await showModalBottomSheet<Tag>(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (_) => TabGridView(
        tag: tag.value,
      ),
    );
    if (result != null) tag.value = result;
  }

  @override
  Widget build(BuildContext context) {
    var text = ValueListenableBuilder(
      valueListenable: tag,
      builder: (_, Tag tag, __) {
        return Text(
          tag == null
              ? S.current.feedback_add_tag_hint
              : '#${tag.name} ${S.current.feedback_change_tag_hint}',
          style: FontManager.YaHeiRegular.copyWith(
            fontSize: 12,
            color: Color(0xff303c66),
          ),
        );
      },
    );
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: InkResponse(
        radius: 20,
        onTap: () => _showTags(context),
        child: text,
      ),
    );
  }
}

class TabGridView extends StatefulWidget {
  final Tag tag;

  const TabGridView({Key key, this.tag}) : super(key: key);

  @override
  _TabGridViewState createState() => _TabGridViewState();
}

class _TabGridViewState extends State<TabGridView>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  ValueNotifier<Tag> currentTab;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200))
          ..forward();
    currentTab = ValueNotifier(widget.tag);
  }

  @override
  Widget build(BuildContext context) {
    var tagInformation = ValueListenableBuilder(
        valueListenable: currentTab,
        builder: (_, Tag value, __) {
          if (value != null) {
            var information = value.name + ': ';
            information += (value.description != null
                ? value.description
                : S.current.feedback_no_description);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                information,
                style: FontManager.YaHeiRegular.copyWith(
                  color: Color(0xff303c66),
                  fontSize: 10,
                ),
              ),
            );
          } else {
            return Container();
          }
        });

    var confirmButton = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Visibility(
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: ConfirmButton(onPressed: null),
        ),
        Text(
          S.current.feedback_add_tag,
          style: FontManager.YaHeiRegular.copyWith(
            color: Color(0xff303c66),
            fontSize: 16,
          ),
        ),
        ConfirmButton(
            onPressed: () => Navigator.of(context).pop(currentTab.value))
      ],
    );

    var tagsWrap = Consumer<FbTagsProvider>(
      builder: (_, data, __) => Wrap(
        alignment: WrapAlignment.start,
        spacing: 10,
        children: List.generate(data.tagList.length, (index) {
          return _tagButton(data.tagList[index]);
        }),
      ),
    );

    return Container(
      constraints: BoxConstraints(
          maxHeight: WePeiYangApp.screenHeight - WePeiYangApp.paddingTop),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(10.0),
              topRight: const Radius.circular(10.0))),
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 25),
        shrinkWrap: true,
        children: [confirmButton, tagInformation, tagsWrap],
      ),
    );
  }

  void updateGroupValue(Tag tag) {
    currentTab.value = tag;
    _animationController.forward(from: 0.0);
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

  ActionChip _tagChip(bool chose, Tag tag) => ActionChip(
        backgroundColor: chose ? Color(0xff62677c) : Color(0xffeeeeee),
        label: Text(
          tag.name,
          style: FontManager.YaHeiRegular.copyWith(
            fontSize: 12,
            color: chose ? Colors.white : Color(0xff62677c),
          ),
        ),
        onPressed: () {
          updateGroupValue(tag);
        },
      );
}

class ConfirmButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ConfirmButton({Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: MaterialStateProperty.all(Size(0, 0)),
        padding: MaterialStateProperty.all(EdgeInsets.zero),
      ),
      onPressed: onPressed,
      child: Text(
        S.current.feedback_ok,
        style: FontManager.YaHeiRegular.copyWith(
          color: Color(0xff303c66),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
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
    var dataModel = Provider.of<NewPostProvider>(context, listen: false);
    _titleController = TextEditingController(text: dataModel.title);
    titleCounter = ValueNotifier('${dataModel.title.characters.length}/20')
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
        style: FontManager.YaHeiRegular.copyWith(
          color: ColorUtil.boldTextColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        minLines: 1,
        maxLines: 10,
        decoration: InputDecoration.collapsed(
          hintStyle: FontManager.YaHeiRegular.copyWith(
            color: Color(0xffd0d1d6),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          hintText: S.current.feedback_enter_title,
        ),
        onChanged: (text) {
          titleCounter.value = '${text.characters.length}/20';
        },
        inputFormatters: [
          _CustomizedLengthTextInputFormatter(20),
        ],
      ),
    );

    Widget rightTextCounter = ValueListenableBuilder(
      valueListenable: titleCounter,
      builder: (_, String value, __) {
        return Text(
          value,
          style: FontManager.YaHeiRegular.copyWith(
            color: Color(0xffd0d1d6),
            fontSize: 12,
          ),
        );
      },
    );

    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [inputField, Container(width: 3), rightTextCounter],
        ),
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
    contentCounter = ValueNotifier('${dataModel.content.characters.length}/200')
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
    //TODO
    print("ContentInputField");

    Widget inputField = TextField(
      controller: _contentController,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.done,
      minLines: 6,
      maxLines: 20,
      style: FontManager.YaHeiRegular.copyWith(
          color: ColorUtil.boldTextColor,
          fontWeight: FontWeight.normal,
          fontSize: 14),
      decoration: InputDecoration.collapsed(
        hintStyle: FontManager.YaHeiRegular.copyWith(
          color: Color(0xffd0d1d6),
          fontSize: 14,
        ),
        hintText: '${S.current.feedback_detail}...',
      ),
      onChanged: (text) {
        contentCounter.value = '${text.characters.length}/200';
      },
      inputFormatters: [
        _CustomizedLengthTextInputFormatter(200),
      ],
    );

    Widget bottomTextCounter = ValueListenableBuilder(
      valueListenable: contentCounter,
      builder: (_, String value, __) {
        return Text(
          value,
          style: FontManager.YaHeiRegular.copyWith(
            color: Color(0xffd0d1d6),
            fontSize: 12,
          ),
        );
      },
    );

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [inputField, bottomTextCounter],
      ),
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
    PickedFile pickedFile = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 50);
    Provider.of<NewPostProvider>(context, listen: false)
        .imgList
        .add(File(pickedFile.path));
    if (!mounted) return;
    setState(() {});
  }

  Future<String> _showDialog() {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.feedback_delete_dialog_content),
        actions: [
          FlatButton(
              onPressed: () {
                Navigator.of(context).pop('cancel');
              },
              child: Text(S.current.feedback_cancel)),
          FlatButton(
              onPressed: () {
                Navigator.of(context).pop('ok');
              },
              child: Text(S.current.feedback_ok)),
        ],
      ),
    );
  }

  Widget imgBuilder(data, {onLongPress}) {
    return InkWell(
      onLongPress: onLongPress,
      child: Image.file(
        data,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
    );

    return Consumer<NewPostProvider>(
      builder: (_, data, __) => GridView.builder(
        shrinkWrap: true,
        gridDelegate: gridDelegate,
        itemCount: maxImage == data.imgList.length
            ? data.imgList.length
            : data.imgList.length + 1,
        itemBuilder: (_, index) {
          if (index <= 2 && index == data.imgList.length) {
            return _ImagePickerWidget(onTap: loadAssets);
          } else {
            return imgBuilder(
              data.imgList[index],
              onLongPress: () async {
                var result = await _showDialog();
                if (result == 'ok') {
                  data.imgList.removeAt(index);
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
    return InkWell(
      onTap: onTap,
      child: DottedBorder(
        borderType: BorderType.Rect,
        color: Color(0xffb5b7c5),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_sharp,
                color: Color(0xffb5b7c5),
              ),
              Text(
                S.current.feedback_add_image,
                style: FontManager.YaHeiRegular.copyWith(
                  color: Color(0xffd0d1d6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BasePage extends StatelessWidget {
  final Widget body;

  const _BasePage({this.body});

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      centerTitle: true,
      title: Text(
        S.current.feedback_new_post,
        style: FontManager.YaHeiRegular.copyWith(
          fontSize: 18,
          color: Color(0xff303c66),
        ),
      ),
      brightness: Brightness.light,
      elevation: 0,
      leading: IconButton(
        padding: EdgeInsets.zero,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        icon: Icon(Icons.arrow_back, color: Color(0XFF62677B)),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: Colors.transparent,
    );

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus.unfocus();
        }
      },
      child: Container(
        color: Color(0xfff7f7f8),
        padding: const EdgeInsets.only(top: 10),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar:
              PreferredSize(preferredSize: Size.fromHeight(35), child: appBar),
          body: body,
        ),
      ),
    );
  }
}

/// 自定义兼容中文拼音输入法长度限制输入框
/// https://www.jianshu.com/p/d2c50b9271d3
class _CustomizedLengthTextInputFormatter extends TextInputFormatter {
  final int maxLength;

  _CustomizedLengthTextInputFormatter(this.maxLength);

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
