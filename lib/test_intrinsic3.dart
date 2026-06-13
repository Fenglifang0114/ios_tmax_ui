import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('IntrinsicHeight test', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      throw Exception('Exception thrown: ${details.exception}');
    };
    
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 100),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Container(height: 200, color: Colors.red),
                  Expanded(child: Container(color: Colors.blue)),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
    expect(find.byType(Text), findsNothing);
  });
}
