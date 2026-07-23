// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:quiz_app/main.dart';
import 'package:quiz_app/providers/flashcard_provider.dart';

void main() {
  testWidgets('Quiz app loads home screen', (WidgetTester tester) async {
    final flashcardProvider = FlashcardProvider();

    await tester.pumpWidget(
      MyApp(flashcardProvider: flashcardProvider),
    );

    await tester.pumpAndSettle();

    expect(find.text('Quiz App'), findsWidgets);
  });
}
