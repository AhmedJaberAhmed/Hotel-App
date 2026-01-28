
import '../Auth/domain/Auth Repo.dart';
import 'HotelRemoteDataSource.dart';
import 'data/city_model.dart';
import 'data/hotelImageModel.dart';
import 'data/hotel_model.dart';

abstract class HotelsRepository {
  Future<Either<String, List<HotelModel>>> getHotels();
  Future<Either<String, HotelModel>> getHotelById(String hotelId);
  Future<Either<String, List<RoomModel>>> getRoomsByHotelId(String hotelId);
  Future<Either<String, List<CityModel>>> getCities();
}

// ============================================================================
// 4. DATA LAYER - Repository Implementation
// ============================================================================
// lib/features/hotels/data/repositories/hotels_repository_impl.dart

class HotelsRepositoryImpl implements HotelsRepository {
  final HotelsRemoteDataSource remoteDataSource;

  HotelsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<HotelModel>>> getHotels() async {
    try {
      final hotels = await remoteDataSource.getHotels();
      return Either.right(hotels);
    } catch (e) {
      return Either.left(e.toString());
    }
  }

  @override
  Future<Either<String, HotelModel>> getHotelById(String hotelId) async {
    try {
      final hotel = await remoteDataSource.getHotelById(hotelId);
      return Either.right(hotel);
    } catch (e) {
      return Either.left(e.toString());
    }
  }

  @override
  Future<Either<String, List<RoomModel>>> getRoomsByHotelId(
      String hotelId) async {
    try {
      final rooms = await remoteDataSource.getRoomsByHotelId(hotelId);
      return Either.right(rooms);
    } catch (e) {
      return Either.left(e.toString());
    }
  }

  @override
  Future<Either<String, List<CityModel>>> getCities() async {
    try {
      final cities = await remoteDataSource.getCities();
      return Either.right(cities);
    } catch (e) {
      return Either.left(e.toString());
    }
  }
}
