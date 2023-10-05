import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'country.dart';

class CountriesRepository {
  // https://countriesnow.space/api/v0.1/countries/capital
  static const authority = 'countriesnow.space';
  static const capitalsPathV1 = 'api/v0.1/countries/capital';

  static final countriesCapitalsUri = Uri.https(authority, capitalsPathV1);

  const CountriesRepository({required this.client});

  @visibleForTesting
  final http.Client client;

  Future<({dynamic error, List<Country>? data})> listCountriesCapitals() async {
    try {
      final response = await client.get(countriesCapitalsUri);
      if (response.statusCode != 200) {
        var details = 'status code: ${response.statusCode}';
        final reason = response.reasonPhrase?.trim();
        if (reason != null && reason.isNotEmpty) {
          details += ", reason: $reason";
        }
        throw 'Bad response ($details)';
      }
      //
      final json = jsonDecode(response.body);
      if (json['error'] == true) {
        throw json['msg'] ?? 'Unexpected API error';
      } else {
        final data = (json['data'] as List).cast<Map<String, dynamic>>();
        if (data.isEmpty) {
          throw 'Empty data';
        }
        return (
          error: null,
          data: [...data.cast<Map<String, dynamic>>().map(Country.fromJson)]
        );
      }
    } catch (error) {
      return (error: error, data: null);
    }
  }
}
