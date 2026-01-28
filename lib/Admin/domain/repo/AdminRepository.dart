
import '../AdminHotelCreate.dart';

abstract class AdminRepository {
  Future<String> createHotel(AdminHotelCreate input);
  Future<String> createRoom({
    required String hotelId,
    required String title,
    required String pricingModel,
    required double pricePerNight,
    required int maxPersons,
    required int bedsCount,
  });

  Future<void> upsertRoomFeatures({
    required String roomId,
    required bool wifi,
    required List<String> meals,
    required bool ac,
    required bool parking,
    required bool pool,
    required bool gym,
  });
}
