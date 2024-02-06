import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';

List<SearchTag> tagUtil = [];

class SearchTagCard extends StatefulWidget {
  const SearchTagCard({Key? key}) : super(key: key);

  @override
  _SearchTagCardState createState() => _SearchTagCardState();
}

class _SearchTagCardState extends State<SearchTagCard>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _useThisTag = false;
  List<Widget> tagList = [SizedBox(height: 4)];

  @override
  void initState() {
    super.initState();
    initSearchTag();
    _controller.addListener(() {
      _useThisTag = false;
      refreshSearchTag(_controller.text);
    });
  }

  _searchTags(List<SearchTag> list) {
    tagList.clear();
    tagList.add(SizedBox(height: 4));
    tagUtil = list;
    var _showAdd = true;
    if (!_useThisTag) {
      for (int total = 0; total < tagUtil.length; total++) {
        if (tagUtil[total].name == _controller.text.toString())
          _showAdd = false;
        tagList.add(WButton(
          onPressed: () {
            _controller.text = tagUtil[total].name;
            FocusScope.of(context).unfocus();
            context.read<NewPostProvider>().tag =
                Tag(id: tagUtil[total].id, name: tagUtil[total].name);
            _useThisTag = true;
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 3, 8),
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
                Text(
                  "",
                  style: TextUtil.base.w500.NotoSansSC.sp(16).infoText(context),
                )
              ],
            ),
          ),
        ));
      }
      if (tagList.length > 5) tagList = tagList.sublist(0, 5);
      _showAdd
          ? tagList.add(WButton(
              onPressed: () async {
                await FeedbackService.postTags(
                  name: _controller.text,
                  onSuccess: (tags) {
                    context.read<NewPostProvider>().tag = Tag(id: tags.id);
                    ToastProvider.success("成功添加 “${_controller.text}” 话题");
                    FeedbackService.searchTags(
                        name: _controller.text,
                        onResult: (list) {
                          setState(() {
                            _searchTags(list);
                            _controller.text = tagUtil[0].name;
                            FocusScope.of(context).unfocus();
                            context.read<NewPostProvider>().tag =
                                Tag(id: tagUtil[0].id, name: tagUtil[0].name);
                            _useThisTag = true;
                          });
                        },
                        onFailure: (e) {
                          ToastProvider.error(e.toString());
                        });
                  },
                  onFailure: (e) async {
                    // context.read<NewPostProvider>().tag = Tag(id: tags.id);
                    ToastProvider.error(e.toString());
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 3, 10),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/svg_pics/lake_butt_icons/hashtag.svg",
                      width: 14,
                    ),
                    SizedBox(width: 16),
                    SizedBox(
                        width: ScreenUtil().setWidth(230),
                        child: Text(
                          "添加“${_controller.text}”话题",
                          style: TextUtil.base.w400.NotoSansSC
                              .sp(16)
                              .label(context),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        )),
                  ],
                ),
              ),
            ))
          : tagList.add(
              //Text('已经存在 ${_controller.text} 标签了哦')
              SizedBox());
    }
  }

  initSearchTag() {
    if (_controller.text != '')
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
    FeedbackService.searchTags(
        name: text,
        onResult: (list) {
          setState(() {
            _searchTags(list);
          });
        },
        onFailure: (e) {
          ToastProvider.error("操作过快，请稍后");
        });
  }

  @override
  Widget build(BuildContext context) {
    var searchBar = TextField(
      controller: _controller,
      scrollPadding: EdgeInsets.zero,
      decoration: InputDecoration(
        icon: SvgPicture.asset(
          "assets/svg_pics/lake_butt_icons/hashtag.svg",
          width: 14,
          color: _controller.text == ''
              ? WpyTheme.of(context).get(WpyThemeKeys.unlabeledColor)
              : WpyTheme.of(context).get(WpyThemeKeys.defaultActionColor),
        ),
        labelStyle: TextUtil.base.label(context).NotoSansSC.w400.sp(16),
        fillColor:
            WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor),
        hintStyle: TextUtil.base.secondaryInfo(context).NotoSansSC.w400.sp(16),
        hintText: '试着添加话题吧',
        contentPadding: const EdgeInsets.all(0),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
      ),
      enabled: true,
      textInputAction: TextInputAction.search,
    );

    return WButton(
      onPressed: initSearchTag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6),
          if (_useThisTag)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '使用此tag:',
                style: TextUtil.base.w600.NotoSansSC.sp(12).unlabeled(context),
              ),
            ),
          searchBar,
          Offstage(
            offstage: _controller.text == '',
            child: AnimatedSize(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Column(children: tagList)),
          ),
        ],
      ),
    );
  }
}
