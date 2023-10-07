import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:randstad_flutter_assessment/repositories/countries_repository.dart';

final countriesRepositoryProvider =
    Provider((ref) => CountriesRepository(client: http.Client()));

final countriesCapitalsProvider = FutureProvider(
    (ref) => ref.read(countriesRepositoryProvider).listCountriesCapitals());
