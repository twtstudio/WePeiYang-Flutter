import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/feedback/model/post.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';

import 'components/post_card.dart';

class DetailPage extends StatefulWidget {
  final Post post;

  DetailPage(this.post);

  @override
  _DetailPageState createState() => _DetailPageState(this.post);
}

class _DetailPageState extends State<DetailPage> {
  final Post post;

  _DetailPageState(this.post);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: ColorUtil.mainColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              '问题详情',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ColorUtil.boldTextColor,
              ),
            ),
            centerTitle: true,
            floating: true,
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: PostCard.detail(post),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: AppBar().preferredSize.height,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '写回答…',
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(1080),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  fillColor: ColorUtil.searchBarBackgroundColor,
                  filled: true,
                ),
                enabled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
