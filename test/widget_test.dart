import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wobbly/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Передаём isFirstLaunch: false (можно true, неважно для теста)
    await tester.pumpWidget(MyApp(isFirstLaunch: false));

    // Проверяем, что MaterialApp существует
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}