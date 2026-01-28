import '../domain/AdminHotelCreate.dart';

class AdminHotelCreateModel {
  final String name;
  final String description;
  final String cityId;
  final double minPricePerNight;
  final String currency;
  final double? rating;

  AdminHotelCreateModel({
    required this.name,
    required this.description,
    required this.cityId,
    required this.minPricePerNight,
    required this.currency,
    this.rating,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'city_id': cityId,
    'min_price_per_night': minPricePerNight,
    'currency': currency,
    'rating': rating,
  };

  factory AdminHotelCreateModel.fromEntity(AdminHotelCreate e) {
    return AdminHotelCreateModel(
      name: e.name,
      description: e.description,
      cityId: e.cityId,
      minPricePerNight: e.minPricePerNight,
      currency: e.currency,
      rating: e.rating,
    );
  }
}
