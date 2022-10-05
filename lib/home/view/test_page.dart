// @dart=2.12

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';

class TestPage extends StatefulWidget {
  TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String ttt = 'hahahaahah';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          ttt,
          style: TextUtil.base,
        ),
        Row(
          children: [
            WButton(
              child: Icon(Icons.check),
              onPressed: () async {
                ttt = 'dawdawd';
                setState(() {});
              },
            )
          ],
        )
      ],
    );
  }
}
