import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

List<SearchTag> tagUtil = [];

class SearchTagCard extends StatefulWidget {
  @override
  _SearchTagCardState createState() => _SearchTagCardState();
}

class _SearchTagCardState extends State<SearchTagCard>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  Tag tag = Tag();
  bool _showAdd;
  bool _useThisTag;
  List<Widget> tagList = [SizedBox(height: 4)];

  _SearchTagCardState();

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
    _showAdd = true;
    if (!_useThisTag) {
      for (int total = 0; total < tagUtil.length; total++) {
        if (tagUtil[total].name == _controller.text.toString()) _showAdd = false;
        tagList.add(GestureDetector(
          onTap: () {
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
                  style: TextUtil.base.w500.NotoSansSC.sp(16).grey6C,
                  overflow: TextOverflow.ellipsis,
                )),
                SizedBox(width: 4),
                Text(
                  "",
                  style: TextUtil.base.w500.NotoSansSC.sp(16).grey6C,
                )
              ],
            ),
          ),
        ));
      }
      if (tagList.length > 5) tagList = tagList.sublist(0, 5);
      _showAdd
          ? tagList.add(GestureDetector(
              onTap: () async {
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
                          ToastProvider.error(e.error.toString());
                        });
                  },
                  onFailure: (tags) {
                    context.read<NewPostProvider>().tag = Tag(id: tags.id);
                    ToastProvider.error("该标签已存在或违规");
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
                          style: TextUtil.base.w400.NotoSansSC.sp(16).black2A,
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
              ? ColorUtil.grey97Color
              : ColorUtil.mainColor,
        ),
        labelStyle: TextStyle().black2A.NotoSansSC.w400.sp(16),
        fillColor: ColorUtil.whiteFDFE,
        hintStyle: TextStyle().grey97.NotoSansSC.w400.sp(16),
        hintText: '试着添加话题吧',
        contentPadding: const EdgeInsets.all(0),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
      ),
      enabled: true,
      textInputAction: TextInputAction.search,
    );

    return InkWell(
      onTap: initSearchTag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6),
          if (_useThisTag ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '使用此tag:',
                style: TextUtil.base.w600.NotoSansSC.sp(12).greyA6,
              ),
            ),
          searchBar,
          Offstage(
            offstage: _controller.text == '',
            child: AnimatedSize(
                duration: Duration(milliseconds: 300),
                vsync: this,
                curve: Curves.easeInOut,
                child: Column(children: tagList ?? [SizedBox()])),
          ),
        ],
      ),
    );
  }
}
