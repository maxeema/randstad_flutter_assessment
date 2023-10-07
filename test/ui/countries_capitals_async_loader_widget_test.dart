import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:randstad_flutter_assessment/providers.dart';
import 'package:randstad_flutter_assessment/repositories/country.dart';
import 'package:randstad_flutter_assessment/ui/countries_capitals_async_loader_widget.dart';

void main() {
  group('CountriesCapitalsAsyncLoaderWidget', () {
    // Test that the widget displays a loading indicator when the countriesCapitalsProvider is not yet resolved.
    testWidgets(
        'Displays loading indicator when countriesCapitalsProvider is not yet resolved',
        (tester) async {
      // Create a mock countriesCapitalsProvider
      mockCountriesCapitalsProvider(ref) async {
        // No need in error or data because we just test that progress indicator appears first.
        return (error: null, data: null);
      }

      // Render the widget with the mock countriesCapitalsProvider.
      await tester.pumpWidget(ProviderScope(
        overrides: [
          countriesCapitalsProvider.overrideWith(mockCountriesCapitalsProvider)
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: CountriesCapitalsAsyncLoaderWidget(),
          ),
        ),
      ));

      // Expect to find a progress indicator
      expect(
        find.byKey(CountriesCapitalsAsyncLoaderWidget.progressIndicatorKey),
        findsOneWidget,
      );
      // expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Let's finish test without errors or we will get the
      // "A Timer is still pending even after the widget tree was disposed."
      // error caused by progress indicator Timer calls.
      await tester.pumpWidget(const Placeholder());
      await tester.pump(const Duration(seconds: 1));
    });

    // Test that the widget displays an error message when the countriesCapitalsProvider emits an error.
    testWidgets(
        'Displays error message when countriesCapitalsProvider emits an error',
        (tester) async {
      const someError = 'Something bad happened.';
      // Create a mock countriesCapitalsProvider that emits an error.
      mockCountriesCapitalsProvider(ref) async {
        return (error: someError, data: null);
      }

      // Render the widget with the mock countriesCapitalsProvider.
      await tester.pumpWidget(ProviderScope(
        overrides: [
          countriesCapitalsProvider.overrideWith(mockCountriesCapitalsProvider)
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: CountriesCapitalsAsyncLoaderWidget(),
          ),
        ),
      ));

      // The first frame is a loading state and should be a progress indicator
      expect(
        find.byKey(CountriesCapitalsAsyncLoaderWidget.progressIndicatorKey),
        findsOneWidget,
      );
      // expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Re-render. Await for the progress indicator animation completion.
      await tester.pumpAndSettle();

      // Ensure there is no longer loading state.
      expect(
        find.byKey(CountriesCapitalsAsyncLoaderWidget.progressIndicatorKey),
        findsNothing,
      );
      // expect(find.byType(CircularProgressIndicator), findsNothing);

      // Expect to find a Text widget with an error message.
      expect(
        find.byKey(CountriesCapitalsAsyncLoaderWidget.errorMessageKey),
        findsOneWidget,
      );

      // Ensure that the error reason is displayed as well.
      expect(find.textContaining(someError), findsOneWidget);
    });

    // Test that the widget displays a list of countries and capitals when the countriesCapitalsProvider emits a success result with data.
    testWidgets(
        'Displays list of countries and capitals when countriesCapitalsProvider emits a success result with data',
        (tester) async {
      // Create a mock countriesCapitalsProvider that emits a success result with data.
      const data = [
        Country(name: 'France', capital: 'Paris'),
        Country(name: 'Germany', capital: 'Berlin'),
      ];
      mockCountriesCapitalsProvider(ref) async {
        return (error: null, data: data);
      }

      // Render the widget with the mock countriesCapitalsProvider.
      await tester.pumpWidget(ProviderScope(
        overrides: [
          countriesCapitalsProvider.overrideWith(mockCountriesCapitalsProvider)
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: CountriesCapitalsAsyncLoaderWidget(),
          ),
        ),
      ));

      // The first frame is a loading state and should be a progress indicator
      expect(
        find.byKey(CountriesCapitalsAsyncLoaderWidget.progressIndicatorKey),
        findsOneWidget,
      );
      // expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Re-render. Await for the progress indicator animation completion.
      await tester.pumpAndSettle();

      // Expect to find a ListView with countries.
      expect(
        find.byKey(CountriesCapitalsAsyncLoaderWidget.countriesListKey),
        findsOneWidget,
      );

      // Ensure all the countries are displayed.
      for (var country in data) {
        expect(find.byKey(Key('country-${country.name}')), findsOneWidget);
      }
    });
  });
}
