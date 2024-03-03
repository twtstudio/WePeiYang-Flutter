
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool _isLiked = false;
  int _likeCount = 41; // Starting like count

  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _likeCount -= 1;
      } else {
        _likeCount += 1;
      }
      _isLiked = !_isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double mm = screenWidth * 0.9 / 60; //获取现实中1毫米的像素长度

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            //靠上
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IconButton(
                icon: (_isLiked ? Icon(Icons.favorite,size: 3*mm,) : Icon(Icons.favorite_border,size: 3*mm)),
                color: (_isLiked ? Colors.red : Colors.grey),
                onPressed: _toggleLike,
              ),
              Text('$_likeCount',style: TextStyle(fontSize: 3*mm,color: Colors.grey)),
            ],
          ),
        ],
      )
    );
  }
}