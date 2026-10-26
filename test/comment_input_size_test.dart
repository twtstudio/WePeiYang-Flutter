import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/comment_input_size.dart';

void main() {
  testWidgets('editor resizes with keyboard open and retains its draft',
      (tester) async {
    final controller = TextEditingController();
    var height = 60.0;
    var keyboardVisible = true;
    late StateSetter update;
    await tester.pumpWidget(MaterialApp(
      home: StatefulBuilder(builder: (_, setState) {
        update = setState;
        return Scaffold(
          body: Column(children: [
            const Spacer(),
            CommentInputSize(
              keyboardVisible: keyboardVisible,
              child: SizedBox(
                height: height,
                child: TextField(controller: controller),
              ),
            ),
          ]),
        );
      }),
    ));
    await tester.enterText(find.byType(TextField), 'draft comment');
    await tester.pumpAndSettle();

    for (final nextHeight in [120.0, 60.0]) {
      update(() => height = nextHeight);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(controller.text, 'draft comment');
    }
    update(() => keyboardVisible = false);
    await tester.pumpAndSettle();
    expect(controller.text, 'draft comment');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
