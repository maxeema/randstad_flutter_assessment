import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:randstad_flutter_assessment/providers.dart';

class CountriesCapitalsAsyncLoaderWidget extends ConsumerWidget {
  @visibleForTesting
  static const errorMessageKey = Key('error-message');
  @visibleForTesting
  static const progressIndicatorKey = Key('progress-indicator');
  @visibleForTesting
  static const countriesListKey = Key('countries-list');

  const CountriesCapitalsAsyncLoaderWidget({super.key});

  @override
  Widget build(context, ref) {
    final state = ref.watch(countriesCapitalsProvider);
    if (state.isLoading || !state.hasValue) {
      return const Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              key: progressIndicatorKey,
            ),
          ),
          SizedBox(height: 8),
          Text('Loading...'),
        ],
      );
    }
    //
    final (:error, :data) = state.requireValue;
    if (data != null) {
      final countries = data;
      return ListView.builder(
        key: countriesListKey,
        itemCount: countries.length,
        itemBuilder: (context, index) {
          final country = countries[index];
          return Card(
            key: Key('country-${country.name}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text.rich(TextSpan(children: [
                TextSpan(
                  text: country.name,
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: country.capital,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ])),
            ),
          );
        },
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text.rich(
            key: errorMessageKey,
            textAlign: TextAlign.center,
            TextSpan(children: [
              const TextSpan(
                text: "An error occurred.",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '$error',
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              // Retry the data fetch.
              ref.invalidate(countriesCapitalsProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      );
    }
  }
}
