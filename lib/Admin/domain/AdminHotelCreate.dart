import 'dart:io';

class AdminHotelCreate {
  final String name;
  final String description;
  final String cityId;
  final double minPricePerNight;
  final String currency;
  final double? rating;

  final File? coverFile; // ✅ NEW

  const AdminHotelCreate({
    required this.name,
    required this.description,
    required this.cityId,
    required this.minPricePerNight,
    this.currency = 'EGP',
    this.rating,
    this.coverFile,
  });
}
