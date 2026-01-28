
import 'package:supabase_flutter/supabase_flutter.dart';

import 'city_model.dart';
import 'hotelImageModel.dart';

class HotelModel {
  final String id;
  final String cityId;
  final String name;
  final String? description;
  final double? rating;
  final String? coverImagePath; // This is the storage path like "hotels/image.jpg"
  final double minPricePerNight;
  final String currency;
  final CityModel? city;
  final List<HotelImageModel>? images;

  HotelModel({
    required this.id,
    required this.cityId,
    required this.name,
    this.description,
    this.rating,
    this.coverImagePath,
    required this.minPricePerNight,
    required this.currency,
    this.city,
    this.images,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: json['id'],
      cityId: json['city_id'],
      name: json['name'],
      description: json['description'],
      rating: json['rating']?.toDouble(),
      coverImagePath: json['cover_image_path'],
      minPricePerNight: (json['min_price_per_night'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'EGP',
      city: json['cities'] != null ? CityModel.fromJson(json['cities']) : null,
      images: json['hotel_images'] != null
          ? (json['hotel_images'] as List)
          .map((img) => HotelImageModel.fromJson(img))
          .toList()
          : null,
    );
  }

  // ✅ NEW: Get public URL for cover image
  String? get coverImageUrl {
    if (coverImagePath == null) return null;

    // If it's already a full URL, return it
    if (coverImagePath!.startsWith('http')) {
      return coverImagePath;
    }

    // Generate public URL from Supabase Storage
    final supabase = Supabase.instance.client;
    return supabase.storage
        .from('hotel-images')
        .getPublicUrl(coverImagePath!);
  }
}

