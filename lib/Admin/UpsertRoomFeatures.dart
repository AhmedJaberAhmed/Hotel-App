
import 'domain/repo/AdminRepository.dart';

class UpsertRoomFeatures {
  final AdminRepository repo;
  UpsertRoomFeatures(this.repo);

  Future<void> call({
    required String roomId,
    required bool wifi,
    required List<String> meals,
    required bool ac,
    required bool parking,
    required bool pool,
    required bool gym,
  }) {
    return repo.upsertRoomFeatures(
      roomId: roomId,
      wifi: wifi,
      meals: meals,
      ac: ac,
      parking: parking,
      pool: pool,
      gym: gym,
    );
  }
}

