import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';

class ReportLoadingDialog extends StatefulWidget {
  @override
  _ReportLoadingDialogState createState() => _ReportLoadingDialogState();
}

class _ReportLoadingDialogState extends State<ReportLoadingDialog> {
  @override
  Widget build(BuildContext context) {
    final body = Container(
      width: 200,
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(0xfff7f7f8),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "正在上传数据，请稍微等待几秒",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xff62677b),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Loading(),
        ],
      ),
    );
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: body,
      ),
    );
  }
}
