import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arogyaconnect/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ArogyaConnectApp());

    // Just check that a title or some widget exists instead of counter
    expect(find.text("Login"), findsOneWidget); 
  });
}
