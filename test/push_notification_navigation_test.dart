import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';

void main() {
  for (final existingPage in [false, true]) {
    testWidgets(
        'notification returns to forum ${existingPage ? "from another page" : "on startup"}',
        (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: Text('App home')),
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => Scaffold(
            body: Text(settings.name == FeedbackRouter.home
                ? (settings.arguments == 1 ? 'Forum' : 'Wrong home tab')
                : settings.name == FeedbackRouter.detail
                    ? 'Post ${(settings.arguments as Post).id}'
                    : 'Previous page'),
          ),
        ),
      ));
      final navigator = navigatorKey.currentState!;
      if (existingPage) {
        navigator.pushNamed('/previous');
        await tester.pumpAndSettle();
      }

      FeedbackRouter.openPostFromNotification(navigator, 123);
      await tester.pumpAndSettle();
      expect(find.text('Post 123'), findsOneWidget);

      await navigator.maybePop();
      await tester.pumpAndSettle();
      expect(find.text('Forum'), findsOneWidget);
      expect(find.text('App home'), findsNothing);
      expect(find.text('Previous page'), findsNothing);
      expect(navigator.canPop(), isFalse);
    });
  }
}
