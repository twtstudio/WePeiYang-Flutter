import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';

class RatingCard extends StatefulWidget {
  final void Function(double) onRatingChanged;

  const RatingCard({Key key, this.onRatingChanged}) : super(key: key);

  @override
  _RatingCardState createState() => _RatingCardState(onRatingChanged);
}

class _RatingCardState extends State<RatingCard> {
  final void Function(double) onRatingChanged;

  _RatingCardState(this.onRatingChanged);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        children: [
          Text(
            '请评分:',
            style: TextStyle(
              color: ColorUtil.boldTextColor,
            ),
          ),
          Expanded(
            child: RatingBar.builder(
              onRatingUpdate: onRatingChanged,
              allowHalfRating: true,
              itemBuilder: (BuildContext context, int index) {
                return Icon(
                  Icons.star,
                  color: ColorUtil.mainColor,
                );
              },
              initialRating: 2.5,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 2),
              glow: false,
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              blurRadius: 5,
              color: Color.fromARGB(64, 236, 237, 239),
              offset: Offset(0, 0),
              spreadRadius: 3),
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
    );
  }
}