import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/feedback/model/feedback_notifier.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
import 'package:wei_pei_yang_demo/feedback/util/feedback_router.dart';
import 'package:wei_pei_yang_demo/feedback/util/screen_util.dart';
import 'package:wei_pei_yang_demo/feedback/view/search_result_page.dart';
import 'package:wei_pei_yang_demo/generated/l10n.dart';

bool _homePostChanged = false;

// ignore: must_be_immutable
class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<FeedbackNotifier>(context, listen: false).initSearchHistory();
      _homePostChanged = false;
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _homePostChanged);
        return true;
      },
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(top: ScreenUtil.paddingTop),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  height: AppBar().preferredSize.height,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 0),
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: S.current.feedback_search_hint,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(1080),
                              ),
                              contentPadding: EdgeInsets.zero,
                              fillColor: ColorUtil.searchBarBackgroundColor,
                              filled: true,
                              prefixIcon: Icon(
                                Icons.search,
                                color: ColorUtil.mainColor,
                              ),
                            ),
                            enabled: true,
                            onSubmitted: (content) {
                              if (content.isNotEmpty) {
                                Provider.of<FeedbackNotifier>(context,
                                        listen: false)
                                    .addSearchHistory(content);
                                _homePostChanged = true;
                                Provider.of<FeedbackNotifier>(context,
                                        listen: false)
                                    .clearHomePostList();
                                Navigator.pushNamed(
                                  context,
                                  FeedbackRouter.searchResult,
                                  arguments: SearchResultPageArgs(
                                    content,
                                    '',
                                    S.current.feedback_search_result,
                                  ),
                                ).then((_) {
                                  Navigator.pop(context, _homePostChanged);
                                });
                              } else {
                                ToastProvider.error(
                                    S.current.feedback_empty_keyword);
                              }
                            },
                            textInputAction: TextInputAction.search,
                          ),
                        ),
                      ),
                      TextButton(
                        child: Text(
                          S.current.feedback_cancel,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ColorUtil.boldTextColor,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context, _homePostChanged);
                        },
                      )
                    ],
                  ),
                ),
                getTagWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///搜索历史
  Widget getHistoryWidget() {
    const titleTextStyle = TextStyle(
        fontSize: 13.0,
        color: Color.fromRGBO(98, 103, 124, 1),
        fontWeight: FontWeight.bold);
    const historyTextStyle = TextStyle(
      fontSize: 15.0,
      color: Color.fromRGBO(48, 60, 102, 1),
    );
    return Column(
      children: [
        Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: EdgeInsets.only(top: 0),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  S.current.feedback_search_history,
                  style: titleTextStyle,
                ),
                InkWell(
                  child: Image.asset(
                    'lib/feedback/assets/img/trash_can.png',
                    fit: BoxFit.cover,
                    height: 18,
                    width: 18,
                  ),
                  onTap: showClearDialog,
                ),
              ],
            )),
        SingleChildScrollView(
          child: Consumer<FeedbackNotifier>(
            builder: (context, notifier, widget) {
              return Column(
                children:
                    List.generate(notifier.searchHistoryList.length, (index) {
                  return InkWell(
                      onTap: () {
                        _homePostChanged = true;
                        notifier.clearHomePostList();
                        _controller.text = notifier.searchHistoryList[index];
                        notifier.addSearchHistory(_controller.text);
                        Navigator.pushNamed(
                          context,
                          FeedbackRouter.searchResult,
                          arguments: SearchResultPageArgs(
                            notifier.searchHistoryList[index],
                            '',
                            S.current.feedback_search_result,
                          ),
                        ).then((_) {
                          Navigator.pop(context, _homePostChanged);
                        });
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              notifier.searchHistoryList[index],
                              style: historyTextStyle,
                            ),
                            InkWell(
                              onTap: () {
                                _controller.text =
                                    notifier.searchHistoryList[index];
                              }, //搜索历史记录,
                              child: Image.asset(
                                'lib/feedback/assets/img/arrow_nw.png',
                                fit: BoxFit.cover,
                                height: 14,
                                width: 14,
                              ),
                            )
                          ],
                        ),
                      ));
                }),
              );
            },
          ),
        )
      ],
    );
  }

  ///标签搜索
  Widget getTagWidget() {
    const titleTextStyle = TextStyle(
        fontSize: 13.0,
        color: Color.fromRGBO(98, 103, 124, 1),
        fontWeight: FontWeight.bold);
    const tagTextStyle =
        TextStyle(fontSize: 12.0, color: Color.fromRGBO(98, 103, 124, 1));
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: Column(
        children: <Widget>[
          getHistoryWidget(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: EdgeInsets.only(top: 20),
            alignment: Alignment.centerLeft,
            child: Text(
              S.current.feedback_search_tag,
              style: titleTextStyle,
            ),
          ),
          Consumer<FeedbackNotifier>(
            builder: (context, notifier, widget) {
              return Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Scrollbar(
                    child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  reverse: false,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(notifier.tagList.length, (index) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(1080),
                        child: Chip(
                          backgroundColor: Color.fromRGBO(238, 238, 238, 1),
                          label: Text(notifier.tagList[index].name,
                              style: tagTextStyle),
                        ),
                        onTap: () {
                          _homePostChanged = true;
                          Provider.of<FeedbackNotifier>(context, listen: false)
                              .clearHomePostList();
                          Navigator.pushNamed(
                            context,
                            FeedbackRouter.searchResult,
                            arguments: SearchResultPageArgs(
                              '',
                              notifier.tagList[index].id.toString(),
                              '#${notifier.tagList[index].name}',
                            ),
                          ).then((_) {
                            Navigator.pop(context, _homePostChanged);
                          });
                        },
                      );
                    }),
                  ),
                )),
              );
            },
          ),
        ],
      ),
    );
  }

  showClearDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(S.current.feedback_clear_history),
            actions: <Widget>[
              FlatButton(
                child: Text(S.current.feedback_cancel),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text(S.current.feedback_ok),
                onPressed: () {
                  Provider.of<FeedbackNotifier>(context, listen: false)
                      .clearSearchHistory();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
