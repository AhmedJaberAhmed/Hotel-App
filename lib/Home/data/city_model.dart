class CityModel {
  final String id;
  final String name;
  final String country;

  CityModel({
    required this.id,
    required this.name,
    required this.country,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'],
      name: json['name'],
      country: json['country'] ?? 'Egypt',
    );
  }
}