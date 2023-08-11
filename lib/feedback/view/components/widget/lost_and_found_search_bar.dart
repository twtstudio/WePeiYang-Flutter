import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';

List<SearchTag> tagUtil = [];

typedef SubmitCallback = void Function(String);
typedef ChangeCallback = void Function(String);

class LostAndFoundSearchBar extends StatefulWidget {
  final SubmitCallback onSubmitted;

  const LostAndFoundSearchBar({Key? key, required this.onSubmitted}) : super(key: key);

  @override
  _LostAndFoundSearchBarState createState() => _LostAndFoundSearchBarState();
}

class _LostAndFoundSearchBarState extends State<LostAndFoundSearchBar>
    with SingleTickerProviderStateMixin {
  TextEditingController _controller = TextEditingController();
  FocusNode _fNode = FocusNode();
  List<Widget> tagList = [SizedBox(height: 4)];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      setState(() {});
    });
  }


  @override
  Widget build(BuildContext context) {
    Widget searchInputField = ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 30,
      ),
      child: Padding(
          padding: const EdgeInsets.only(left: 45, right: 12),
          child: Row(
            children: [
              Expanded(
                child: Consumer<FbHotTagsProvider>(
                  builder: (_, data, __) => TextField(
                    controller: _controller,
                    focusNode: _fNode,
                    style: TextStyle().black2A.NotoSansSC.w400.sp(15),
                    decoration: InputDecoration(
                      hintStyle: TextStyle().grey6C.NotoSansSC.w400.sp(15),
                      hintText: data.recTag == null
                          ? '天大不能没有微北洋'
                          : '暂无相关内容',
                      contentPadding: const EdgeInsets.only(right: 6),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(1080),
                      ),
                      fillColor: ColorUtil.backgroundColor,
                      filled: true,
                      prefixIcon: Icon(
                        Icons.search,
                        size: 19,
                        color: ColorUtil.grey108,
                      ),
                    ),
                    enabled: true,
                    onSubmitted: (content) {
                      if (content.isNotEmpty) {
                        widget.onSubmitted.call(content);
                      } else {

                      }
                    },
                    textInputAction: TextInputAction.search,
                  ),
                ),
              ),
              SizedBox(width: 6),
            ],
          )),
    );

    return Column(
      children: [
        Container(
            color: Colors.white,
            child: searchInputField,
            padding: EdgeInsets.symmetric(vertical: 6)),
        SizedBox(height: 8),
      ],
    );
  }
}
