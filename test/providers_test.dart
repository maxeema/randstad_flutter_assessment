import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:randstad_flutter_assessment/providers.dart';
import 'package:randstad_flutter_assessment/repositories/countries_repository.dart';

class MockCountriesRepository extends Mock implements CountriesRepository {}

void main() {
  group('countriesCapitalsProvider', () {
    late ProviderContainer providerContainer;

    setUp(() {
      // called each time any test runs of the group
      providerContainer = ProviderContainer(
        overrides: [
          countriesRepositoryProvider
              .overrideWithValue(MockCountriesRepository()),
        ],
      );
    });

    test(
        'ensure that CountriesRepository.listCountriesCapitals() is called by the provider',
        () async {
      // Arrange
      final repository = providerContainer.read(countriesRepositoryProvider)
          as MockCountriesRepository;

      when(() => repository.listCountriesCapitals())
          .thenAnswer((_) async => (error: null, data: null));

      // ensure 0 interactions on repository before using provider
      verifyZeroInteractions(repository);
      verifyNever(() => repository.listCountriesCapitals());

      // Act
      await providerContainer.read(countriesCapitalsProvider.future);

      // Assert
      verify(() => repository.listCountriesCapitals()).called(1);
    });
  });
}
