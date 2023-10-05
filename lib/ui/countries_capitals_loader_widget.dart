import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:randstad_flutter_assessment/providers.dart';

class CountriesCapitalsLoaderWidget extends ConsumerWidget {
  const CountriesCapitalsLoaderWidget({super.key});

  @override
  Widget build(context, ref) {
    final result = ref.read(countriesCapitalsProvider);
    final isLoading = !result.hasValue;
    // Loading data
    if (isLoading) {
      return const Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox.square(dimension: 20, child: CircularProgressIndicator()),
          SizedBox(height: 8),
          Text('Loading...'),
        ],
      );
    }
    // Got error
    final value = result.requireValue;
    if (value.error != null) {
      final error = value.error!;
      return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text.rich(
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
          )
        ],
      );
    }
    // Got data
    final capitals = value.data!;
    return ListView.builder(
      itemCount: capitals.length,
      itemBuilder: (context, idx) {
        final entry = capitals[idx];
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text.rich(TextSpan(children: [
              TextSpan(
                text: entry.name,
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
              const TextSpan(text: ' '),
              TextSpan(
                text: entry.capital,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ])),
          ),
        );
      },
    );
  }
}
