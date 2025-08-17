// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:focus_timer/main.dart';

void main() {
  testWidgets('Focus Timer app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FocusTimerApp());

    // Verify that the app title is displayed.
    expect(find.text('Focus Timer'), findsOneWidget);

    // Verify that the timer button is present.
    expect(find.byType(GestureDetector), findsWidgets);

    // Verify that preset buttons are present.
    expect(find.text('5m'), findsOneWidget);
    expect(find.text('10m'), findsOneWidget);
    expect(find.text('15m'), findsOneWidget);
    expect(find.text('25m'), findsOneWidget);
    expect(find.text('30m'), findsOneWidget);
  });
}
