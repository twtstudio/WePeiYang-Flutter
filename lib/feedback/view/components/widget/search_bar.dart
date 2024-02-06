import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/view/search_result_page.dart';

import '../../../../commons/themes/template/wpy_theme_data.dart';
import '../../../../commons/themes/wpy_theme.dart';
import '../../../../commons/widgets/w_button.dart';

List<SearchTag> tagUtil = [];

typedef SubmitCallback = void Function(String);
typedef ChangeCallback = void Function(String);

class SearchBar extends StatefulWidget {
  final SubmitCallback onSubmitted;

  const SearchBar({Key? key, required this.onSubmitted}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar>
    with SingleTickerProviderStateMixin {
  TextEditingController _controller = TextEditingController();
  FocusNode _fNode = FocusNode();
  bool _showSearch = false;
  List<Widget> tagList = [SizedBox(height: 4)];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initSearchTag();
    _controller.addListener(() {
      setState(() {});
      _controller.text.startsWith('#')
          ? _showSearch = true
          : _showSearch = false;
      if (_showSearch) refreshSearchTag(_controller.text.substring(1));
    });
  }

  _searchTags(List<SearchTag> list) {
    tagList.clear();
    tagList.add(SizedBox(height: 4));
    tagUtil = list;
    for (int total = 0; total < min(tagUtil.length, 5); total++) {
      tagList.add(WButton(
        onPressed: () {
          _controller.text = tagUtil[total].name;
          Navigator.pushNamed(
            context,
            FeedbackRouter.searchResult,
            arguments: SearchResultPageArgs('', '${tagUtil[total].id}', '',
                '搜索结果 #${tagUtil[total].name}', 0, 0),
          ).then((_) {
            Navigator.pop(context);
          });
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 20, 4),
          child: Row(
            children: [
              SvgPicture.asset(
                "assets/svg_pics/lake_butt_icons/hashtag.svg",
                width: 14,
              ),
              SizedBox(width: 16),
              Expanded(
                  child: Text(
                tagUtil[total].name,
                style: TextUtil.base.w500.NotoSansSC.sp(16).infoText(context),
                overflow: TextOverflow.ellipsis,
              )),
              SizedBox(width: 4),
            ],
          ),
        ),
      ));
    }
  }

  initSearchTag() {
    FeedbackService.searchTags(
        name: "",
        onResult: (list) {
          setState(() {
            _searchTags(list);
          });
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
        });
  }

  refreshSearchTag(String text) {
    if (_controller.text != '#MP' &&
        (!_controller.text.startsWith('#MP') ||
            !RegExp(r'^-?[0-9]+').hasMatch(_controller.text.substring(3))))
      FeedbackService.searchTags(
          name: text,
          onResult: (list) {
            setState(() {
              _searchTags(list);
            });
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
          });
  }

  @override
  Widget build(BuildContext context) {
    Widget searchInputField = ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 30,
      ),
      child: Padding(
          padding: const EdgeInsets.only(left: 38, right: 12),
          child: Row(
            children: [
              Expanded(
                child: Consumer<FbHotTagsProvider>(
                  builder: (_, data, __) => TextField(
                    controller: _controller,
                    focusNode: _fNode,
                    style: TextUtil.base.label(context).NotoSansSC.w400.sp(15),
                    decoration: InputDecoration(
                      hintStyle: TextUtil.base
                          .infoText(context)
                          .NotoSansSC
                          .w400
                          .sp(15),
                      hintText: data.recTag == null
                          ? '搜索发现'
                          : '#${data.recTag?.name}#，输入“#”号搜索更多Tag',
                      contentPadding: const EdgeInsets.only(right: 6),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(1080),
                      ),
                      fillColor: WpyTheme.of(context)
                          .get(WpyColorKey.secondaryBackgroundColor),
                      filled: true,
                      prefixIcon: Icon(
                        Icons.search,
                        size: 19,
                        color: WpyTheme.of(context)
                            .get(WpyColorKey.infoTextColor),
                      ),
                    ),
                    enabled: true,
                    onSubmitted: (content) {
                      if (content.isNotEmpty) {
                        if (_controller.text.startsWith('#MP') &&
                            RegExp(r'^-?[0-9]+')
                                .hasMatch(_controller.text.substring(3))) {
                          FeedbackService.getPostById(
                            id: int.parse(_controller.text.substring(3)),
                            onResult: (post) {
                              Navigator.popAndPushNamed(
                                context,
                                FeedbackRouter.detail,
                                arguments: post,
                              );
                            },
                            onFailure: (e) {
                              ToastProvider.error('无法找到对应帖子，报错信息：${e.error}');
                              return;
                            },
                          );
                        } else if ((_controller.text.startsWith('#MP') &&
                            RegExp(r'^-?[0-9]+')
                                .hasMatch(_controller.text.substring(3)))) {
                          _controller.text = '#MP';
                          ToastProvider.error('后面跟数字啦！！！');
                        } else {
                          widget.onSubmitted.call(content);
                        }
                      } else {
                        Navigator.pushNamed(
                          context,
                          FeedbackRouter.searchResult,
                          arguments: SearchResultPageArgs(
                              '',
                              '${data.recTag?.tagId}',
                              '',
                              '推荐：#${data.recTag?.name}',
                              0,
                              0),
                        );
                      }
                    },
                    textInputAction: TextInputAction.search,
                  ),
                ),
              ),
              SizedBox(width: 6),
              SizedBox(
                  width: 24,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (!_fNode.hasFocus)
                          FocusScope.of(context).requestFocus(_fNode);
                        if (_controller.text == '') {
                          _controller.text = '#';
                        } else
                          _controller.clear();
                      });
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: MaterialStateProperty.all(
                          WpyTheme.of(context)
                              .get(WpyColorKey.primaryBackgroundColor)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                      elevation: MaterialStateProperty.all(2),
                    ),
                    child: _controller.text == ''
                        ? SvgPicture.asset(
                            "assets/svg_pics/lake_butt_icons/hashtag.svg",
                            width: 12,
                          )
                        : Icon(Icons.clear,
                            size: 14,
                            color: WpyTheme.of(context)
                                .get(WpyColorKey.defaultActionColor)),
                  ))
            ],
          )),
    );

    return Column(
      children: [
        Container(
            color:
                WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            child: searchInputField,
            padding: EdgeInsets.symmetric(vertical: 6)),
        ColoredBox(
          color:
              WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
          child: AnimatedSize(
            curve: Curves.easeOutCirc,
            duration: Duration(milliseconds: 400),
            child: _showSearch
                ? Container(
                    padding: EdgeInsets.only(bottom: 10),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: WpyTheme.of(context)
                            .get(WpyColorKey.primaryBackgroundColor),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: WpyTheme.of(context)
                                  .get(WpyColorKey.iconAnimationStartColor),
                              offset: Offset(0.0, 4.0), //阴影xy轴偏移量
                              blurRadius: 3.0, //阴影模糊程度
                              spreadRadius: 1.0 //阴影扩散程度
                              )
                        ]),
                    child: Column(
                      children: [
                        if (_controller.text.startsWith('#MP') ||
                            _controller.text.startsWith('#'))
                          WButton(
                            onPressed: () {
                              if (_controller.text.startsWith('#MP') &&
                                  RegExp(r'^-?[0-9]+').hasMatch(
                                      _controller.text.substring(3))) {
                                FeedbackService.getPostById(
                                  id: int.parse(_controller.text.substring(3)),
                                  onResult: (post) {
                                    Navigator.popAndPushNamed(
                                      context,
                                      FeedbackRouter.detail,
                                      arguments: post,
                                    );
                                  },
                                  onFailure: (e) {
                                    ToastProvider.error(
                                        '无法找到对应帖子，报错信息：${e.error}');
                                    return;
                                  },
                                );
                              } else {
                                _controller.text = '#MP';
                                ToastProvider.error('后面跟数字啦！！！');
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 20, 4),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/svg_pics/lake_butt_icons/send.svg",
                                    width: 14,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                      child: Text(
                                    _controller.text.length < 3
                                        ? '按照MP号跳转'
                                        : '跳转至：${_controller.text}',
                                    style: TextUtil.base.w500.NotoSansSC
                                        .sp(16)
                                        .infoText(context),
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                  SizedBox(width: 4),
                                ],
                              ),
                            ),
                          ),
                        if (_controller.text != '#MP' &&
                            (!_controller.text.startsWith('#MP') ||
                                !RegExp(r'^-?[0-9]+')
                                    .hasMatch(_controller.text.substring(3))))
                          Column(children: tagList),
                      ],
                    ))
                : SizedBox(),
          ),
        ),
        if (!_showSearch) SizedBox(height: 8),
      ],
    );
  }
}
