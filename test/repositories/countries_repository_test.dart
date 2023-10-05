import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:randstad_flutter_assessment/repositories/countries_repository.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  // setUpAll(() {
  //   registerFallbackValue(CountriesRepository.countriesCapitalsUri);
  // });
  group('CountriesRepository', () {
    test('listCountriesCapitals() returns a list of countries with capitals',
        () async {
      // Arrange
      registerFallbackValue(CountriesRepository.countriesCapitalsUri);
      final mockHttpClient = MockHttpClient();
      final countriesRepository = CountriesRepository(client: mockHttpClient);

      // Mock the HTTP response
      when(() => mockHttpClient.get(any())).thenAnswer((_) async {
        return http.Response(
          '''
          {
            "error": false,
            "data": [
              {
                "name": "Brazil",
                "capital": "Brasília"
              },
              {
                "name": "United States",
                "capital": "Washington, D.C."
              }
            ]
          }
          ''',
          200,
        );
      });

      // Act
      final result = await countriesRepository.listCountriesCapitals();

      // Assert
      expect(result.error, null);
      expect(result.data, isNotNull);
      expect(result.data!.length, 2);
      expect(result.data![0].name, 'Brazil');
      expect(result.data![0].capital, 'Brasília');
      expect(result.data![1].name, 'United States');
      expect(result.data![1].capital, 'Washington, D.C.');
    });

    test(
        'listCountriesCapitals() returns an error if the HTTP response is not successful',
        () async {
      // Arrange
      registerFallbackValue(CountriesRepository.countriesCapitalsUri);
      final mockHttpClient = MockHttpClient();
      final countriesRepository = CountriesRepository(client: mockHttpClient);

      // Mock the HTTP response
      when(() => mockHttpClient.get(any())).thenAnswer((_) async {
        return http.Response('Bad response', 500, reasonPhrase: 'Internal server error');
      });

      // Act and assert
      final result = await countriesRepository.listCountriesCapitals();
      expect(result.data, isNull);
      expect(result.error, isNotNull);
      expect(result.error, contains('Bad response'));
      expect(result.error, contains('Internal server error'));
    });
  });
}
