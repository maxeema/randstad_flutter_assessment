import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:randstad_flutter_assessment/providers.dart';
import 'package:randstad_flutter_assessment/repositories/country.dart';
import 'package:randstad_flutter_assessment/ui/countries_capitals_async_loader_widget.dart';

import '../test_helpers.dart';

void main() {
  final progressFinder =
      find.byKey(CountriesCapitalsAsyncLoaderWidget.progressIndicatorKey);
  final listFinder =
      find.byKey(CountriesCapitalsAsyncLoaderWidget.countriesListKey);
  final errorFinder =
      find.byKey(CountriesCapitalsAsyncLoaderWidget.errorMessageKey);
  final retryFinder =
      find.byKey(CountriesCapitalsAsyncLoaderWidget.retryButtonKey);

  group('CountriesCapitalsAsyncLoaderWidget', () {
    testWidgets(
        'Displays loading indicator when countriesCapitalsProvider is not yet resolved',
        (tester) async {
      // Create a mock countriesCapitalsProvider
      providerOverride(ref) async {
        // No need in error or data because we just test that progress indicator appears first.
        return (error: null, data: null);
      }

      // Render the widget with the mock countriesCapitalsProvider.
      await tester.pumpWidget(_createWidget(providerOverride));

      // Expect to find a progress indicator
      expect(progressFinder, findsOneWidget);
      // expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Let's finish test without errors or we will get the
      // "A Timer is still pending even after the widget tree was disposed."
      // error caused by progress indicator Timer calls.
      await tester.pumpWidget(const Placeholder());
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets(
        'Displays list of countries and capitals when countriesCapitalsProvider emits a success result with data',
        (tester) async {
      const mockData = [
        Country(name: 'France', capital: 'Paris'),
        Country(name: 'Germany', capital: 'Berlin'),
      ];

      // Create a mock countriesCapitalsProvider that emits a success result with data.
      providerOverride(ref) async {
        return (error: null, data: mockData);
      }

      // Render the widget with the mock countriesCapitalsProvider.
      await tester.pumpWidget(_createWidget(providerOverride));

      // The first frame is a loading state and should be a progress indicator
      expect(progressFinder, findsOneWidget);

      // Re-render. Await for the progress indicator animation completion.
      await tester.pumpAndSettle();

      // Expect to find a ListView with countries.
      expect(listFinder, findsOneWidget);

      // Ensure all the countries are displayed.
      for (var country in mockData) {
        expect(find.byKey(Key('country-${country.name}')), findsOneWidget);
      }
    });
  });

  testWidgets(
      'Displays error message when countriesCapitalsProvider emits an error',
      (tester) async {
    const mockError = 'Mock error occurred.';

    // Create a mock countriesCapitalsProvider that emits an error.
    providerOverride(ref) async {
      return (error: mockError, data: null);
    }

    // Render the widget with the mock countriesCapitalsProvider.
    await tester.pumpWidget(_createWidget(providerOverride));

    // The first frame is a loading state and should be a progress indicator
    expect(listFinder, findsOneWidget);

    // Re-render. Await for the progress indicator animation completion.
    await tester.pumpAndSettle();

    // Ensure there is no longer loading state.
    expect(progressFinder, findsNothing);
    // expect(find.byType(CircularProgressIndicator), findsNothing);

    // Expect to find a Text widget with an error message.
    expect(errorFinder, findsOneWidget);

    // Ensure that the error reason is displayed as well.
    expect(find.textContaining(mockError), findsOneWidget);
  });

  testWidgets(
      'Tap Retry and re-fetch data when appears when countriesCapitalsProvider emits an error',
      (tester) async {
    var firstFetch = true;
    const mockError = 'Mock error occurred.';
    const mockData = [
      Country(name: 'USA', capital: 'Washington'),
      Country(name: 'Brazil', capital: 'Brasília'),
    ];

    // Create a mock countriesCapitalsProvider that emits an error.
    providerOverride(ref) async {
      // Emulate some delay.
      await Future.delayed(const Duration(milliseconds: 300));
      if (firstFetch) {
        firstFetch = false;
        return (error: mockError, data: null);
      } else {
        return (error: null, data: mockData);
      }
    }

    // Render the widget with the mock countriesCapitalsProvider.
    await tester.pumpWidget(_createWidget(providerOverride));

    // Re-render. Await for the progress indicator animation completion.
    await tester.pumpAndSettle();

    // Ensure there is no longer loading state.
    expect(progressFinder, findsNothing);

    // Ensure the "Retry" button appeared
    expect(retryFinder, findsOneWidget);

    // Tap the "Retry" button
    await tester.tap(retryFinder);

    // Await UI rebuild.
    await tester.pump();

    // Ensure the progress indicator appeared.
    expect(progressFinder, findsOneWidget);

    // Ensure UI rerendered to the progress indicator appear.
    // Wait for the second fetching completion. It could be detected that the progress bar disappeared.
    await until(tester, () {
      return progressFinder.evaluate().firstOrNull?.widget == null;
    });

    // Ensure that data appeared after retrying to fetch data again
    expect(listFinder, findsOneWidget);

    // Ensure all the countries are displayed.
    for (var country in mockData) {
      expect(find.byKey(Key('country-${country.name}')), findsOneWidget);
    }
  });
}

Widget _createWidget(providerOverride) {
  return ProviderScope(
    overrides: [
      countriesCapitalsProvider.overrideWith(providerOverride),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: CountriesCapitalsAsyncLoaderWidget(),
      ),
    ),
  );
}
