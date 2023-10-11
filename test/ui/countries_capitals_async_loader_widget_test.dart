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

  const mockError = 'Mock error occurred.';
  const mockData = [
    Country(name: 'France', capital: 'Paris'),
    Country(name: 'Germany', capital: 'Berlin'),
  ];

  group('CountriesCapitalsAsyncLoaderWidget', () {
    testWidgets('loading indicator works correctly when provider return error',
        (tester) async {
      mockProviderOverride(ref) async {
        return (error: mockError, data: null);
      }

      await tester.pumpWidget(_createWidget(mockProviderOverride));
      expect(progressFinder, findsOneWidget);
      await tester.waitForNo(progressFinder);
      expect(progressFinder, findsNothing);
    });
    testWidgets('loading indicator works correctly when provider returns data',
        (tester) async {
      mockProviderOverride(ref) async {
        return (error: null, data: mockData);
      }

      await tester.pumpWidget(_createWidget(mockProviderOverride));

      expect(progressFinder, findsOneWidget);
      await tester.waitForNo(progressFinder);
      expect(progressFinder, findsNothing);
    });

    testWidgets('error appears when provider returns error', (tester) async {
      mockProviderOverride(ref) async {
        return (error: mockError, data: null);
      }

      await tester.pumpWidget(_createWidget(mockProviderOverride));

      expect(errorFinder, findsNothing);
      await tester.waitFor(errorFinder);
      expect(errorFinder, findsOneWidget);
      expect(find.textContaining(mockError), findsOneWidget);
    });

    testWidgets('error doesn\'t appear when provider returns data',
        (tester) async {
      mockProviderOverride(ref) async {
        return (error: null, data: mockData);
      }

      await tester.pumpWidget(_createWidget(mockProviderOverride));
      expect(errorFinder, findsNothing);
      await tester.waitFor(listFinder);
      expect(errorFinder, findsNothing);
    });

    testWidgets(
        'list of countries and capitals appears when provider returns data',
        (tester) async {
      mockProviderOverride(ref) async {
        return (error: null, data: mockData);
      }

      await tester.pumpWidget(_createWidget(mockProviderOverride));

      expect(listFinder, findsNothing);
      await tester.waitFor(listFinder);
      expect(listFinder, findsOneWidget);
      for (var country in mockData) {
        expect(find.byKey(Key('country-${country.name}')), findsOneWidget);
      }
    });
  });

  testWidgets(
      'list of countries and capitals doesn\'t appear when provider returns error',
      (tester) async {
    mockProviderOverride(ref) async {
      return (error: mockError, data: null);
    }

    await tester.pumpWidget(_createWidget(mockProviderOverride));

    expect(listFinder, findsNothing);
    await tester.waitForNo(progressFinder);
    expect(listFinder, findsNothing);
  });

  testWidgets('tap Retry to re-fetch data when provider returned error',
      (tester) async {
    var firstFetch = true;
    providerOverride(ref) async {
      // Emulate some delay
      await Future.delayed(const Duration(milliseconds: 100));
      if (firstFetch) {
        firstFetch = false;
        return (error: mockError, data: null);
      } else {
        return (error: null, data: mockData);
      }
    }

    await tester.pumpWidget(_createWidget(providerOverride));

    await tester.waitFor(errorFinder);
    expect(retryFinder, findsOneWidget);

    await tester.tap(retryFinder);
    await tester.pump();

    expect(retryFinder, findsNothing);
    await tester.waitFor(listFinder);
    expect(listFinder, findsOneWidget);

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
