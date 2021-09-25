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
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/util/screen_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

TextEditingController _titleController;
TextEditingController _bodyController;
int _currentTagId;
int _currentTagIndex;
List<File> _resultList = List<File>();

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
    return DefaultTextStyle(
      style: FontManager.YaHeiRegular,
      child: _BasePage(
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
          child: Container(
            decoration: BoxDecoration(
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
            ),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                TitleInputField(),
                _divider(),
                BodyInputField(),
                ImagesGridView(),
                TagView(),
                _divider(),
                // Submit.
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          if (_titleController.text.isNotEmpty &&
                              _bodyController.text.isNotEmpty &&
                              _currentTagId != null) {
                            FeedbackService.sendPost(
                              title: _titleController.text,
                              content: _bodyController.text,
                              tagId: _currentTagId,
                              imgList: _resultList,
                              onSuccess: () {
                                ToastProvider.success(
                                    S.current.feedback_post_success);
                                Navigator.pop(context);
                              },
                              onFailure: () {
                                ToastProvider.error(
                                    S.current.feedback_post_error);
                              },
                              onSensitive: (String msg) {
                                ToastProvider.error(msg);
                              },
                              onUploadImageFailure: () {
                                ToastProvider.error(
                                    S.current.feedback_upload_image_error);
                              },
                            );
                          } else {
                            ToastProvider.error(
                                S.current.feedback_empty_content_error);
                          }
                        },
                        child: Text(
                          S.current.feedback_submit,
                          style: FontManager.YaHeiRegular.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff303c66),
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TagView extends StatefulWidget {
  @override
  _TagViewState createState() => _TagViewState();
}

class _TagViewState extends State<TagView> {
  String tab;

  _showTags(BuildContext context) async {
    var result = await showModalBottomSheet<String>(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (_) => TabGridView(
        tab: tab,
      ),
    );
    if (result != null)
      setState(() {
        tab = result;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Builder(
        builder: (_) => InkWell(
          onTap: () async => await _showTags(context),
          child: Text(
            tab == null
                ? S.current.feedback_add_tag_hint
                : '#$tab ${S.current.feedback_change_tag_hint}',
            style: FontManager.YaHeiRegular.copyWith(
              fontSize: 12,
              color: Color(0xff303c66),
            ),
          ),
        ),
      ),
    );
  }
}

class TabGridView extends StatefulWidget {
  final String tab;

  const TabGridView({Key key, this.tab}) : super(key: key);

  @override
  _TabGridViewState createState() => _TabGridViewState();
}

class _TabGridViewState extends State<TabGridView>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  String currentTab;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200))
          ..forward();
    currentTab = widget.tab;
  }

  void updateGroupValue(String v, tagId, index) {
    setState(() {
      currentTab = v;
      _currentTagId = tagId;
      _currentTagIndex = index;
      _animationController.forward(from: 0.0);
    });
  }

  TextButton _confirmButton({VoidCallback onPressed}) => TextButton(
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
      ));

  ActionChip _tagChip({String text, tagId, index}) => ActionChip(
        backgroundColor:
            text == currentTab ? Color(0xff62677c) : Color(0xffeeeeee),
        label: Text(
          text,
          style: FontManager.YaHeiRegular.copyWith(
            fontSize: 12,
            color: text == currentTab ? Colors.white : Color(0xff62677c),
          ),
        ),
        onPressed: () {
          updateGroupValue(text, tagId, index);
        },
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxHeight: ScreenUtil.screenHeight - ScreenUtil.paddingTop),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(10.0),
              topRight: const Radius.circular(10.0))),
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 25),
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                visible: false,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: _confirmButton(onPressed: null),
              ),
              Text(
                S.current.feedback_add_tag,
                style: FontManager.YaHeiRegular.copyWith(
                  color: Color(0xff303c66),
                  fontSize: 16,
                ),
              ),
              _confirmButton(
                  onPressed: () => Navigator.of(context).pop(currentTab))
            ],
          ),
          if (currentTab != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                currentTab +
                    ': ' +
                    (Provider.of<FeedbackNotifier>(context, listen: false)
                                .tagList[_currentTagIndex]
                                .description !=
                            null
                        ? Provider.of<FeedbackNotifier>(context, listen: false)
                            .tagList[_currentTagIndex]
                            .description
                        : S.current.feedback_no_description),
                style: FontManager.YaHeiRegular.copyWith(
                  color: Color(0xff303c66),
                  fontSize: 10,
                ),
              ),
            ),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 10,
            children: List.generate(
                Provider.of<FeedbackNotifier>(context, listen: false)
                    .tagList
                    .length, (index) {
              return Provider.of<FeedbackNotifier>(context, listen: false)
                          .tagList[index]
                          .name ==
                      currentTab
                  ? FadeTransition(
                      opacity: Tween(begin: 0.0, end: 1.0)
                          .animate(_animationController),
                      child: _tagChip(
                        text: Provider.of<FeedbackNotifier>(context,
                                listen: false)
                            .tagList[index]
                            .name,
                        tagId: Provider.of<FeedbackNotifier>(context,
                                listen: false)
                            .tagList[index]
                            .id,
                        index: index,
                      ),
                    )
                  : _tagChip(
                      text:
                          Provider.of<FeedbackNotifier>(context, listen: false)
                              .tagList[index]
                              .name,
                      tagId:
                          Provider.of<FeedbackNotifier>(context, listen: false)
                              .tagList[index]
                              .id,
                      index: index,
                    );
            }),
          )
        ],
      ),
    );
  }
}

class TitleInputField extends StatefulWidget {
  @override
  _TitleInputFieldState createState() => _TitleInputFieldState();
}

class _TitleInputFieldState extends State<TitleInputField> {
  String titleCounter;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    titleCounter = '0/200';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
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
                  titleCounter = '${text.characters.length}/20';
                  setState(() {});
                },
                inputFormatters: [
                  _CustomizedLengthTextInputFormatter(20),
                ],
              ),
            ),
            Container(width: 3),
            Text(
              titleCounter,
              style: FontManager.YaHeiRegular.copyWith(
                color: Color(0xffd0d1d6),
                fontSize: 12,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BodyInputField extends StatefulWidget {
  @override
  _BodyInputFieldState createState() => _BodyInputFieldState();
}

class _BodyInputFieldState extends State<BodyInputField> {
  String bodyCounter;

  @override
  void initState() {
    super.initState();
    _bodyController = TextEditingController();
    bodyCounter = '0/200';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          TextField(
            controller: _bodyController,
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
              bodyCounter = '${text.characters.length}/200';
              setState(() {});
            },
            inputFormatters: [
              /// 输入的内容长度为 10 位
              _CustomizedLengthTextInputFormatter(200),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                bodyCounter,
                style: FontManager.YaHeiRegular.copyWith(
                  color: Color(0xffd0d1d6),
                  fontSize: 12,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class ImagesGridView extends StatefulWidget {
  @override
  _ImagesGridViewState createState() => _ImagesGridViewState();
}

class _ImagesGridViewState extends State<ImagesGridView> {
  int maxImage = 3;

  Future<void> loadAssets() async {
    String error;

    try {
      PickedFile pickedFile = await ImagePicker()
          .getImage(source: ImageSource.gallery, imageQuality: 50);
      _resultList.add(File(pickedFile.path));
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _resultList.length == maxImage
            ? _resultList.length
            : _resultList.length + 1,
        itemBuilder: (context, index) => index == _resultList.length
            ? _ImagePickerWidget(
                onTap: loadAssets,
              )
            : InkWell(
                onLongPress: () async {
                  var result = await showDialog<String>(
                      context: context,
                      builder: (context) => AlertDialog(
                            title:
                                Text(S.current.feedback_delete_dialog_content),
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
                          ));

                  if (result == 'ok')
                    setState(() {
                      _resultList.removeAt(index);
                    });
                },
                child: _MyImage(image: _resultList[index])),
        physics: NeverScrollableScrollPhysics(),
      ),
    );
  }
}

class _MyImage extends StatelessWidget {
  const _MyImage({
    Key key,
    @required this.image,
  }) : super(key: key);

  final File image;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.file(
        image,
        fit: BoxFit.cover,
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
      child: Container(
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
      ),
    );
  }
}

class _BasePage extends StatelessWidget {
  final Widget body;

  const _BasePage({this.body, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(35),
              child: AppBar(
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
                  icon: Icon(
                    Icons.arrow_back,
                    color: Color(0XFF62677B),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                backgroundColor: Colors.transparent,
              ),
            ),
            body: Container(
              child: body,
            ),
          ),
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
