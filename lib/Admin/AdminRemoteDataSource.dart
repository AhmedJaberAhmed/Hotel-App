import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRemoteDataSource {
  final SupabaseClient client;

  AdminRemoteDataSource(this.client);







  Future<String> createRoom({
    required String hotelId,
    required String title,
    required String pricingModel, // 'per_person' or 'per_room'
    required double pricePerNight,
    required int maxPersons,
    required int bedsCount,
  }) async {
    final res = await client.from('rooms').insert({
      'hotel_id': hotelId,
      'title': title,
      'pricing_model': pricingModel,
      'price_per_night': pricePerNight,
      'max_persons': maxPersons,
      'beds_count': bedsCount,
    }).select('id').single();

    return res['id'] as String;
  }

  Future<void> upsertRoomFeatures({
    required String roomId,
    required bool wifi,
    required List<String> meals,
    required bool ac,
    required bool parking,
    required bool pool,
    required bool gym,
  }) async {
    // room_features PK = room_id (one row per room)
    await client.from('room_features').upsert({
      'room_id': roomId,
      'wifi': wifi,
      'meals': meals,
      'ac': ac,
      'parking': parking,
      'pool': pool,
      'gym': gym,
    });
  }

  Future<StorageUploadResult> uploadHotelCover({
    required File file,
    required String hotelName,
  }) async {
    final fileExt = p.extension(file.path);
    final safeName = hotelName.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$safeName$fileExt';
    final storagePath = 'covers/$fileName';

    await client.storage.from('hotel-images').upload(
          storagePath,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    final url = client.storage.from('hotel-images').getPublicUrl(storagePath);

    return StorageUploadResult(path: storagePath, url: url);
  }

  Future<String> createHotel(Map<String, dynamic> hotelRow) async {
    final res =
        await client.from('hotels').insert(hotelRow).select('id').single();
    return res['id'] as String;
  }

  Future<void> addHotelImage({
    required String hotelId,
    required String imagePath,
    int sortOrder = 0,
  }) async {
    await client.from('hotel_images').insert({
      'hotel_id': hotelId,
      'image_path': imagePath,
      'sort_order': sortOrder,
    });
  }
}

class StorageUploadResult {
  final String path;
  final String url;

  const StorageUploadResult({
    required this.path,
    required this.url,
  });
}
