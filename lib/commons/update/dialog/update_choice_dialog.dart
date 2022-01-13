// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/update/update_util.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';

class UpdateChoseDialog extends StatefulWidget {
  final Version version;

  const UpdateChoseDialog(this.version, {Key? key}) : super(key: key);

  @override
  _UpdateChoseDialogState createState() => _UpdateChoseDialogState();
}

class _UpdateChoseDialogState extends State<UpdateChoseDialog> {
  static const titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: const Color(0xff4f586b),
  );

  static const normalStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF62677b),
  );

  static const detailStyle = TextStyle(
    fontSize: 12,
    color: const Color(0xFF62677b),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String versionDetail = '更新内容:';
    int index = 0;
    final size = MediaQuery.of(context).size;
    final width = size.width * 0.7;
    widget.version.content.split("-").forEach((item) {
      if (item.isNotEmpty) {
        versionDetail =
            versionDetail + '\n' + (index > 0 ? '$index. ' : '') + item.trim();
      }
      index++;
    });

    final content = SizedBox(
      width: width * 0.66,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20),
          Center(child: Text("版本更新", style: titleStyle)),
          SizedBox(height: 15),
          Text(versionDetail, style: detailStyle),
          SizedBox(height: 3),
          Row(
            children: [
              Text("版本: ", style: detailStyle),
              FutureBuilder(
                future: UpdateUtil.getVersion(),
                builder: (_, AsyncSnapshot<String> snapshot) => snapshot.hasData
                    ? Text("${snapshot.data} => ${widget.version.version}",
                        style: detailStyle)
                    : Container(),
              ),
            ],
          ),
          SizedBox(height: 3),
          Divider(
            height: 3,
            thickness: 3,
            color: const Color(0xffACAEBA),
          ),
          SizedBox(height: 5),
          // content,
          SizedBox(height: 10),
        ],
      ),
    );

    var updateButton = FractionallySizedBox(
      widthFactor: 1,
      child: ElevatedButton(
        child: Text("热更新", style: normalStyle),
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          elevation: 0,
        ),
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: width,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              // image: DecorationImage(
              //   image: AssetImage('assets/images/account/rocket.png'),
              //   fit: BoxFit.none,
              // ),
            ),
            child: FractionallySizedBox(
              widthFactor: 1,
              child: Stack(
                alignment: AlignmentDirectional.topCenter,
                children: [
                  Positioned(
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 40,
                        width: 40,
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/account/close.png',
                          width: 20,
                        ),
                      ),
                    ),
                    right: 0,
                    top: 10,
                  ),
                  content,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
