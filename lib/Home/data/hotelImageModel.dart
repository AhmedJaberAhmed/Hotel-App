
import 'package:supabase_flutter/supabase_flutter.dart';

class HotelImageModel {
  final String id;
  final String hotelId;
  final String imagePath; // Storage path like "hotels/hotel1/image1.jpg"
  final int sortOrder;

  HotelImageModel({
    required this.id,
    required this.hotelId,
    required this.imagePath,
    required this.sortOrder,
  });

  factory HotelImageModel.fromJson(Map<String, dynamic> json) {
    return HotelImageModel(
      id: json['id'],
      hotelId: json['hotel_id'],
      imagePath: json['image_path'],
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  // ✅ NEW: Get public URL for this image
  String get imageUrl {
    // If it's already a full URL, return it
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Generate public URL from Supabase Storage
    final supabase = Supabase.instance.client;
    return supabase.storage
        .from('hotel-images')
        .getPublicUrl(imagePath);
  }


}




  class RoomModel {
  final String id;
  final String hotelId;
  final String title;
  final String pricingModel;
  final double pricePerNight;
  final int maxPersons;
  final int bedsCount;
  final RoomFeaturesModel? features;

  RoomModel({
    required this.id,
    required this.hotelId,
    required this.title,
    required this.pricingModel,
    required this.pricePerNight,
    required this.maxPersons,
    required this.bedsCount,
    this.features,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      hotelId: json['hotel_id'],
      title: json['title'],
      pricingModel: json['pricing_model'],
      pricePerNight: (json['price_per_night'] ?? 0).toDouble(),
      maxPersons: json['max_persons'] ?? 2,
      bedsCount: json['beds_count'] ?? 1,
      features: json['room_features'] != null
          ? RoomFeaturesModel.fromJson(json['room_features'])
          : null,
    );
  }
}

// lib/features/hotels/data/models/room_features_model.dart

class RoomFeaturesModel {
  final String roomId;
  final bool wifi;
  final List<String> meals;
  final bool ac;
  final bool parking;
  final bool pool;
  final bool gym;

  RoomFeaturesModel({
    required this.roomId,
    required this.wifi,
    required this.meals,
    required this.ac,
    required this.parking,
    required this.pool,
    required this.gym,
  });

  factory RoomFeaturesModel.fromJson(Map<String, dynamic> json) {
    return RoomFeaturesModel(
      roomId: json['room_id'],
      wifi: json['wifi'] ?? false,
      meals: json['meals'] != null
          ? List<String>.from(json['meals'])
          : [],
      ac: json['ac'] ?? false,
      parking: json['parking'] ?? false,
      pool: json['pool'] ?? false,
      gym: json['gym'] ?? false,
    );
  }

  List<String> get allFeatures {
    List<String> features = [];
    if (wifi) features.add('WiFi');
    if (ac) features.add('AC');
    if (parking) features.add('Parking');
    if (pool) features.add('Pool');
    if (gym) features.add('Gym');
    if (meals.isNotEmpty) features.add('Meals: ${meals.join(", ")}');
    return features;
  }
}