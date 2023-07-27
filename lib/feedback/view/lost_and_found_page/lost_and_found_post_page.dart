import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/feedback/view/new_post_page.dart';

class LostAndFoundPostPage extends StatefulWidget{
  @override
  State<LostAndFoundPostPage> createState()=>_LostAndFoundPostPageState();

}
class _LostAndFoundPostPageState extends State<LostAndFoundPostPage>{
  String _selecttitle = "发布失物";
  String _selectClass = "选择分类";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TitleInputField(),
            ContentInputField(),
            ImagesGridView(),
            Container(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  //请填写丢失日期 按钮
                  SelectButton(
                      frontIcon: const Icon(
                        Icons.access_time_filled,
                        color: Color.fromARGB(255, 144, 144, 144),
                      ),
                      buttonText: "请填写丢失日期",
                      onPressed: () {}),
                  const SizedBox(height: 8),
                  //请填写丢失地点 按钮
                  SelectButton(
                      frontIcon: const Icon(
                        Icons.add_location,
                        color: Color.fromARGB(255, 144, 144, 144),
                      ),
                      buttonText: "请填写丢失地点",
                      onPressed: () {}),
                  const SizedBox(height: 8),
                  //请填写联系方式 按钮
                  SelectButton(
                      frontIcon: const Icon(
                        Icons.chat_bubble,
                        color: Color.fromARGB(255, 144, 144, 144),
                      ),
                      buttonText: "请填写联系方式",
                      onPressed: () {}),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            //选择分类 发送
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {},
                    child: Text(
                      "# ${_selectClass}",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 44, 126, 223)),
                    )),
                const SizedBox(width: 8),
                SizedBox(
                  width: 63,
                  height: 32,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0),
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 44, 126, 223)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(16)))),
                      onPressed: () {},
                      child: const Text('发送')),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

}
class SelectButton extends StatelessWidget {
  final Icon frontIcon;
  final String buttonText;
  final VoidCallback onPressed;

  SelectButton({
    required this.frontIcon,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 195,
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            backgroundColor: MaterialStateProperty.all(
                const Color.fromARGB(255, 248, 248, 248)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            frontIcon,
            const SizedBox(width: 8),
            Text(
              buttonText,
              style: const TextStyle(color: Color.fromARGB(255, 144, 144, 144)),
            ),
          ],
        ),
      ),
    );
  }
}
