import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:randstad_flutter_assessment/providers.dart';
import 'package:randstad_flutter_assessment/repositories/countries_repository.dart';

class MockCountriesRepository extends Mock implements CountriesRepository {}

void main() {
  late ProviderContainer providerContainer;

  setUp(() {
    // called each time any test runs
    providerContainer = ProviderContainer(
      overrides: [
        countriesRepositoryProvider
            .overrideWithValue(MockCountriesRepository()),
      ],
    );
  });

  group('countriesCapitalsProvider', () {
    test(
        'ensure that CountriesRepository.listCountriesCapitals() is called by the provider',
        () async {
      // Arrange
      final repository = providerContainer.read(countriesRepositoryProvider)
          as MockCountriesRepository;

      when(() => repository.listCountriesCapitals())
          .thenAnswer((_) async => (error: null, data: null));

      // Ensure no interactions
      verifyZeroInteractions(repository);
      verifyNever(() => repository.listCountriesCapitals());

      // Act
      await providerContainer.read(countriesCapitalsProvider.future);

      // Assert
      verify(() => repository.listCountriesCapitals()).called(1);
    });
  });
}
