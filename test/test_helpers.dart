import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterX on WidgetTester {
  /// Wait for widget appearance in the widget tree.
  /// Use it like that:
  ///  await tester.waitFor(find.byKey(key));
  Future waitFor(Finder finder) async {
    while (finder.evaluate().isEmpty) {
      await pump(const Duration(milliseconds: 20));
    }
  }

  /// Wait for widget removal from the widget tree.
  /// Use it like that:
  ///  await tester.waitFor(find.byKey(key));
  Future waitForNo(Finder finder) async {
    while (finder.evaluate().isNotEmpty) {
      await pump(const Duration(milliseconds: 20));
    }
  }

  /// Wait until the predicate() returned true first time.
  /// Use it like that:
  ///  await tester.untilTrue(() => ...);
  Future untilTrue(bool predicate()) async {
    while (!predicate()) {
      await pump(const Duration(milliseconds: 20));
    }
  }
}

/// Waits until the given predicate returns true.
///
/// Note! Avoid using this call directly in widget tests, e.g. in testWidgets()
/// where the "await Future.delayed(..)" call freezes the test execution
/// because Flutter widget tests are ran in a FakeAsync (mock clock) by default.
/// Otherwise, use it like that:
///  await tester.runAsync(() => untilTrue(() => ...));
Future<void> untilTrue(bool predicate(), {Duration? interval}) async {
  while (!predicate()) {
    await Future.delayed(interval ?? const Duration(milliseconds: 50));
  }
}
