import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class StarUI extends StatefulWidget {
  final double rating;
  final double size;
  final Function(double) onRatingUpdate;

  StarUI({this.rating = 0, required this.size, required this.onRatingUpdate});

  @override
  _StarUIState createState() => _StarUIState();
}

class _StarUIState extends State<StarUI> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: _rating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: widget.size,
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.lightBlue,
      ),
      onRatingUpdate: (rating) {
        setState(() {
          _rating = rating;
        });
        widget.onRatingUpdate(rating);
      },
    );
  }
}
