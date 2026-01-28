
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/city_model.dart';
import 'data/hotelImageModel.dart';
import 'data/hotel_model.dart';

abstract class HotelsRemoteDataSource {
  Future<List<HotelModel>> getHotels();
  Future<HotelModel> getHotelById(String hotelId);
  Future<List<RoomModel>> getRoomsByHotelId(String hotelId);
  Future<List<CityModel>> getCities();
}

class HotelsRemoteDataSourceImpl implements HotelsRemoteDataSource {
  final SupabaseClient supabaseClient;

  HotelsRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<HotelModel>> getHotels() async {
    try {
      final response = await supabaseClient
          .from('hotels')
          .select('''
            *,
            cities(id, name, country),
            hotel_images(id, hotel_id, image_path, sort_order)
          ''')
          .order('created_at', ascending: false);

      return (response as List)
          .map((hotel) => HotelModel.fromJson(hotel))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch hotels: ${e.toString()}');
    }
  }

  @override
  Future<HotelModel> getHotelById(String hotelId) async {
    try {
      final response = await supabaseClient
          .from('hotels')
          .select('''
            *,
            cities(id, name, country),
            hotel_images(id, hotel_id, image_path, sort_order)
          ''')
          .eq('id', hotelId)
          .single();

      return HotelModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch hotel: ${e.toString()}');
    }
  }

  @override
  Future<List<RoomModel>> getRoomsByHotelId(String hotelId) async {
    try {
      final response = await supabaseClient
          .from('rooms')
          .select('''
            *,
            room_features(*)
          ''')
          .eq('hotel_id', hotelId)
          .order('price_per_night', ascending: true);

      return (response as List)
          .map((room) => RoomModel.fromJson(room))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch rooms: ${e.toString()}');
    }
  }

  @override
  Future<List<CityModel>> getCities() async {
    try {
      final response = await supabaseClient
          .from('cities')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((city) => CityModel.fromJson(city))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch cities: ${e.toString()}');
    }
  }
}