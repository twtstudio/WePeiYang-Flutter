
import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/search_model.dart';

class SearchResult extends StatefulWidget {
  final String keyWord;
  final SearchHistoryModel searchHistoryModel;

  SearchResult({this.keyWord,this.searchHistoryModel});

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context,index) {
        return Container(
          child: Text("data"),
        );
      },
    );
  }
}
