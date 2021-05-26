import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
import 'package:wei_pei_yang_demo/generated/l10n.dart';

class RatingCard extends StatefulWidget {
  final int initialRating;
  final void Function(double) onRatingChanged;

  const RatingCard({Key key, this.onRatingChanged, this.initialRating})
      : super(key: key);

  @override
  _RatingCardState createState() =>
      _RatingCardState(onRatingChanged, this.initialRating);
}

class _RatingCardState extends State<RatingCard> {
  int initialRating = 5;
  final void Function(double) onRatingChanged;

  _RatingCardState(this.onRatingChanged, this.initialRating);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        children: [
          Text(
            S.current.feedback_please_rating,
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
              initialRating: initialRating.toDouble() / 2,
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
