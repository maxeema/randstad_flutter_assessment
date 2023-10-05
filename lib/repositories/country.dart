import 'package:equatable/equatable.dart';

class Country with EquatableMixin {
  const Country({required this.name, required this.capital});

  final String name;
  final String capital;

  factory Country.fromJson(Map<String, dynamic> json) =>
      Country(name: json['name'], capital: json['capital']);

  @override
  List<Object?> get props => [name, capital];
}
