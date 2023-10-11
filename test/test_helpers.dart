import 'package:flutter_test/flutter_test.dart';

/// Waits until the given predicate returns true.
/// Note! Avoid using this call directly in widget tests, e.g. in testWidgets()
/// where await Future.delayed() freezes the test execution.
Future<void> untilTrue(bool predicate(), {Duration? interval}) async {
  while (!predicate()) {
    await Future.delayed(interval ?? const Duration(milliseconds: 50));
  }
}

/// Waits in widget testing until the given predicate returns true.
Future<void> until(WidgetTester tester, bool predicate(),
    {Duration? interval}) async {
  while (!predicate()) {
    await tester.pump(interval ?? const Duration(milliseconds: 50));
  }
}
