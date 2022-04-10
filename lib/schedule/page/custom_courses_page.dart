// @dart = 2.12
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';

class CustomCoursesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('page build!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    var len = context.read<CourseProvider>().customCourses.length;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('我的自定义课程',
            style: TextUtil.base.PingFangSC.bold.black2A.sp(18)),
      ),
      body: ListView.builder(
        itemCount: len,
        itemBuilder: (context, index) {
          return Builder(builder: (context) {
            print('index $index build?????????????????????????????????????');
            var course =
                context.select((CourseProvider p) => p.customCourses[index]);
            return _item(course);
          });
        },
      ),
    );
  }

  Widget _item(Course course) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(course.name,
                  style: TextUtil.base.PingFangSC.bold.black2A.sp(14)),
              Spacer(),
              Container(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                decoration: BoxDecoration(
                  color: FavorColors.scheduleTitleColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.white),
                    SizedBox(width: 3),
                    Text('46教A311',
                        style: TextUtil.base.PingFangSC.regular.white.sp(11)),
                    SizedBox(width: 10),
                    Text('王萍',
                        style: TextUtil.base.PingFangSC.bold.white.sp(11)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
