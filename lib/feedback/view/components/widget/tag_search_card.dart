import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

List<Text> tags = List.filled(
    4,
    Text(
      "暂无此tag哦",
      style: TextUtil.base.w400.NotoSansSC.sp(16).grey97,
    ));
List<Text> hotIndex = List.filled(
    4,
    Text(
      "0",
      style: TextUtil.base.w400.NotoSansSC.sp(14).grey97,
    ));

List<SearchTag> tagUtil = [];

//北洋热搜
class SearchTagCard extends StatefulWidget {
  @override
  _SearchTagCardState createState() => _SearchTagCardState();
}

class _SearchTagCardState extends State<SearchTagCard> {
  final TextEditingController _controller = TextEditingController();
  Tag tag = Tag();
  _SearchTagCardState();

  @override
  void initState() {
    super.initState();
    initSearchTag();
    _controller.addListener(() {
      refreshSearchTag(_controller.text);
    });

  }

  _searchTags(List<SearchTag> list) {
    tagUtil = list;
    for (int total = 0; total < tagUtil.length && total < 4 ; total++) {
      tags[total] = Text(
        tagUtil[total].name,
        style: TextUtil.base.w500.NotoSansSC.sp(16).grey6C,
      );
      hotIndex[total] = Text(
       "${tagUtil[total].id}",
        style: TextUtil.base.w500.NotoSansSC.sp(14).black2A,
      );
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
    var searchBar = TextField(
      controller: _controller,
      decoration: InputDecoration(
        fillColor: ColorUtil.white253,
        hintStyle: TextStyle().black2A.NotoSansSC.w400.sp(16),
        hintText: '试着添加话题吧',
        contentPadding: const EdgeInsets.all(0),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
      ),
      enabled: true,
      textInputAction: TextInputAction.search,
    );
    return InkWell(
      onTap: initSearchTag,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child:  Column(
                children: [
                  searchBar,
                  SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _controller.text =  tagUtil[index].name;
                          context.read<NewPostProvider>().tag = Tag(
                              id:tagUtil[index].id,name: tagUtil[index].name);
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 3, 3, 3),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                "assets/svg_pics/lake_butt_icons/hashtag.svg",
                                width: 14,
                              ),
                              SizedBox(width: 5),
                              Center(child: tags[index]),
                              Spacer(),
                              hotIndex[index]
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                      GestureDetector(
                        onTap: () async {
                          await FeedbackService.postTags(
                            name: _controller.text,
                            onSuccess: (tags) {
                              context.read<NewPostProvider>().tag = Tag(
                                  id:tags.id);
                              ToastProvider.success("成功添加“${_controller.text}”话题");
                            },
                            onFailure: (tags) {
                              context.read<NewPostProvider>().tag = Tag(
                                  id:tags.id);
                              ToastProvider.error("该标签已存在或违规");
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 3, 3, 3),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                "assets/svg_pics/lake_butt_icons/hashtag.svg",
                                width: 14,
                              ),
                              SizedBox(width: 5),
                              SizedBox(
                                  width: ScreenUtil().setWidth(230),
                                  child: Text(
                                    "添加“${_controller.text}”话题",
                                    style: TextUtil.base.w400.NotoSansSC
                                        .sp(16)
                                        .black2A,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  )),
                            ],
                          ),
                        ),
                      )

                ],
              )
      ),
    );
  }
}
