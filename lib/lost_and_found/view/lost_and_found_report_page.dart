import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LostAndFoundReportPage extends StatelessWidget {
  LostAndFoundReportPage(reportPageArgs);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0, // 取消阴影
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Image.asset(
              'assets/images/back.png',
              width: 30.w,
              height: 30.h,
            ),
            onPressed: () => Navigator.pop(context),
          ),

          title: Text(
            '举报',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(20), // 使用 EdgeInsets.all 设置 padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 360,
                height: 50,
                child: TextFormField(
                  style: TextStyle(
                    fontSize: 19,
                  ),
                  decoration: InputDecoration(
                    hintText: "你正在举报“MP000001",
                  ),
                ),
              ),
              SizedBox(height: 33.h),
              Text(
                '请填写举报理由，如“色情暴力”“政治敏感”等',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 17,
                ),
              ),
              GestureDetector(
                onTap: () {                },
                child: Container(
                  margin: EdgeInsets.only(left: 290.w, top: 270.h),
                  width: 80.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(44, 126, 223, 1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      '发送',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),


            ],
          ),
        ));

    // 在这里可以继续添加其他 Row 或 Column
  }
}
