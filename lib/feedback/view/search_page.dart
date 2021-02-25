import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/feedback/model/tag.dart';
import 'package:wei_pei_yang_demo/feedback/util/http_util.dart';

class DetailSearchPage extends StatefulWidget {
  List<String> historyList = ["微北洋课表", "吃什么", "啦啦啦"];
  // List<String> tagList = [
  //   "单纯吐槽",
  //   "教务处",
  //   "学工部",
  //   "天外天",
  //   "研究生院",
  //   "后勤保障处",
  //   "体育馆、场馆中心",
  // ];
  @override
  State<StatefulWidget> createState() {
    return _DetailSearchPageState();
  }
}

class _DetailSearchPageState extends State<DetailSearchPage> {
  String searchValue = "";
  TextEditingController _controller = new TextEditingController();
  List<String> tagList = List();

  /// Get tags using Dio.
  Future _getTags() async {
    try {
      await HttpUtil().get('tag/get/all').then((value) {
        if (0 != value['data'][0]['children'].length) {
          tagList.clear();
          for (Map<String, dynamic> json in value['data'][0]['children']) {
            tagList.add(Tag.fromJson(json).name);
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    _getTags().then((_) {
      setState(() {});
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
    double statusHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(16, statusHeight + 12, 16, 16),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(236, 237, 239, 1),
                        borderRadius: BorderRadius.circular(1080)),
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 6),
                        Icon(Icons.search),
                        SizedBox(width: 6),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            decoration: new InputDecoration(
                                hintText: '搜索问题', border: InputBorder.none),
                            style: TextStyle(
                                fontSize: 14.0,
                                color: Color.fromRGBO(207, 208, 213, 1)),
                            onChanged: (value) {
                              setState(() {
                                searchValue = value;
                              });
                            },
                            controller: _controller,
                          ),
                        ),
                        searchValue != ""
                            ? InkWell(
                                onTap: () {
                                  setState(() {
                                    searchValue = "";
                                  });
                                  _controller.text = searchValue;
                                },
                                child: Icon(Icons.close, size: 14),
                              )
                            : Container(),
                        SizedBox(width: 6)
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text("取消"),
                )
              ],
            ),
            SizedBox(
              height: 32,
            ),
            searchValue == "" ? getTagWidget() : getSearchResultWidget()
          ],
        ),
      ),
    );
  }

  ///搜索结果
  Widget getSearchResultWidget() {
    List<String> results = [];
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
    const tagTextStyle =
        TextStyle(fontSize: 12.0, color: Color.fromARGB(1, 98, 103, 124));
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
                  "历史记录",
                  style: titleTextStyle,
                ),
                InkWell(
                  onTap: showClearDialog,
                  child: Icon(Icons.delete, size: 25),
                )
              ],
            )),
        SingleChildScrollView(
          child: Column(
            children: List.generate(widget.historyList.length, (index) {
              return InkWell(
                  onTap: () {
                    _controller.text = widget.historyList[index];
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.historyList[index],
                          style: historyTextStyle,
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              searchValue = widget.historyList[index];
                            });
                            _controller.text = searchValue;
                          }, //搜索历史记录,
                          child: Image.asset(
                            'assets/images/arrow_up.png',
                            height: 25,
                            width: 25,
                          ),
                        )
                      ],
                    ),
                  ));
            }),
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
    return Column(
      children: <Widget>[
        getHistoryWidget(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          margin: EdgeInsets.only(top: 20),
          alignment: Alignment.centerLeft,
          child: Text(
            "标签搜索",
            style: titleTextStyle,
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 20),
          child: Scrollbar(
              child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            reverse: false,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(tagList.length, (index) {
                return InkWell(
                  onTap: () {
                    //点击标签的逻辑
                    setState(() {
                      searchValue = tagList[index];
                    });
                    _controller.text = searchValue;
                  },
                  child: Chip(
                    backgroundColor: Color.fromRGBO(238, 238, 238, 1),
                    label: Text(tagList[index], style: tagTextStyle),
                  ),
                );
              }),
            ),
          )),
        ),
      ],
    );
  }

  showClearDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(""),
            content: Text("确认清除所有搜索记录吗？"),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("取消"),
                onPressed: () {
                  Navigator.pop(context);
                  print("取消");
                },
              ),
              CupertinoDialogAction(
                child: Text("确定"),
                onPressed: () {
                  setState(() {
                    widget.historyList = [];
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
