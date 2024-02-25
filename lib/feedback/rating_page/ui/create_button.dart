import 'package:flutter/material.dart';

class CreateButton extends StatefulWidget {
  final VoidCallback onPressed;

  const CreateButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  _CreateButtonState createState() => _CreateButtonState();
}

class _CreateButtonState extends State<CreateButton> {

  Offset position = Offset(0, 0);
  bool isInit = true;

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double mm = screenWidth * 0.9 / 60;

    if(isInit){
      position = Offset(screenWidth*0.8, screenWidth*1.4);
      isInit = false;
    }

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          setState(() {
            position += details.delta;
          });
        },
        child: FloatingActionButton(
          onPressed: widget.onPressed,
          elevation: 0,
          backgroundColor: Colors.black.withOpacity(0.8),
          child: Icon(
              Icons.create_outlined,
              size: 6 * mm,
          ),
        ),
      ),
    );
  }
}


