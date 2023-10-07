import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:randstad_flutter_assessment/repositories/countries_repository.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  final repository = CountriesRepository(client: MockHttpClient());

  // setUpAll(() {
  //   // registerFallbackValue(...);
  // });

  group('CountriesRepository', () {
    group('validate listCountriesCapitals() method', () {
      test(
          'listCountriesCapitals() returns success result when API responds with 200 OK',
          () async {
        // Arrange
        when(() =>
                repository.client.get(CountriesRepository.countriesCapitalsUri))
            .thenAnswer((_) async {
          return http.Response(
            jsonEncode({
              'error': false,
              'msg': 'Data recieved successfully',
              'data': [
                {'name': 'France', 'capital': 'Paris'},
                {'name': 'Germany', 'capital': 'Berlin'},
              ],
            }),
            200,
          );
        });

        // Act
        final result = await repository.listCountriesCapitals();

        // Assert
        expect(result.error, null);

        final data = result.data!;
        expect(data.length, 2);
        expect(data[0].name, 'France');
        expect(data[1].capital, 'Berlin');
      });

      test(
          'listCountriesCapitals() returns error result when API responds with non-200 status code',
          () async {
        // Arrange
        when(() =>
                repository.client.get(CountriesRepository.countriesCapitalsUri))
            .thenAnswer((_) async {
          return http.Response('Invalid query', 400);
        });

        // Act
        final result = await repository.listCountriesCapitals();

        // Assert
        expect(result.error.toString(),
            contains('Bad response (status code: 400)'));
        expect(result.data, null);
      });

      test(
          'listCountriesCapitals() returns error result when API responds with "error": true and filled "msg"',
          () async {
        const msg = 'Server is over busy. Try later.';
        // Arrange
        when(() =>
                repository.client.get(CountriesRepository.countriesCapitalsUri))
            .thenAnswer((_) async {
          return http.Response(
            jsonEncode({
              'error': true,
              'msg': msg,
            }),
            200,
          );
        });

        // Act
        final result = await repository.listCountriesCapitals();

        // Assert
        expect(result.error.toString(), contains(msg));
        expect(result.data, null);
      });

      test(
          'listCountriesCapitals() returns error result when API responds with "error": true and missing "msg"',
          () async {
        // Arrange
        when(() =>
                repository.client.get(CountriesRepository.countriesCapitalsUri))
            .thenAnswer((_) async {
          return http.Response(
            jsonEncode({
              'error': true,
            }),
            200,
          );
        });

        // Act
        final result = await repository.listCountriesCapitals();

        // Assert
        expect(result.error.toString(), contains('Unexpected API error'));
        expect(result.data, null);
      });

      test(
          'listCountriesCapitals() returns error result when API responds with empty "data" list',
          () async {
        // Arrange
        when(() =>
                repository.client.get(CountriesRepository.countriesCapitalsUri))
            .thenAnswer((_) async {
          return http.Response(
            jsonEncode({
              'error': false,
              'data': [],
            }),
            200,
          );
        });

        // Act
        final result = await repository.listCountriesCapitals();

        // Assert
        expect(result.error.toString(), contains('Empty data'));
        expect(result.data, null);
      });

      test(
          'listCountriesCapitals() returns error result when client throws an exception',
          () async {
        const reason = 'Platform IO error';
        // Arrange
        when(() =>
                repository.client.get(CountriesRepository.countriesCapitalsUri))
            .thenThrow(Exception(reason));

        // Act
        final result = await repository.listCountriesCapitals();

        // Assert
        expect(result.error.toString(), contains(reason));
        expect(result.data, null);
      });
    });
  });
}
