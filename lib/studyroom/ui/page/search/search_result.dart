
import 'package:flutter/material.dart';

class SearchResult extends StatefulWidget {
  final String keyWord;

  SearchResult({this.keyWord});

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
