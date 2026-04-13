import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wobbly/main.dart';
import 'package:wobbly/models/day_record.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MyApp(
        dataFuture: Future.value(<String, DayRecord>{}),
        prefsFuture: SharedPreferences.getInstance(),
        achievementsFuture: Future.value(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
