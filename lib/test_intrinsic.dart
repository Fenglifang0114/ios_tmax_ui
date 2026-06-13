import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('IntrinsicHeight test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Column(
              children: [
                Container(height: 100, color: Colors.red),
                Expanded(child: Container(color: Colors.blue)),
              ],
            ),
          ),
        ),
      ),
    ));
    expect(find.byType(Container), findsWidgets);
  });
}
