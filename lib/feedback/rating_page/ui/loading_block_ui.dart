import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';

class LoadingSquare extends StatefulWidget {
  final double width;
  final double height;

  LoadingSquare({
    required this.width,
    required this.height,
  });

  @override
  _LoadingSquareState createState() => _LoadingSquareState();
}

class _LoadingSquareState extends State<LoadingSquare> {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Widget changingBlock = ValueListenableBuilder(
      builder: (BuildContext context, Color value, Widget? child) {
        // This builder will only get called when the _counter
        // is updated.
        return Container(
          width: widget.width,
          height: widget.height,
          color: value,
        );
      },
      valueListenable: context.read<RatingPageData>().lodingBlockColor,
    );
    return changingBlock;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

