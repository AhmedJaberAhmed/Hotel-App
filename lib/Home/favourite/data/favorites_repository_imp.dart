
import '../favorites_db.dart';

class FavoritesRepository {
  final FavoritesDb db;
  FavoritesRepository({FavoritesDb? db}) : db = db ?? FavoritesDb.instance;

  Future<Set<String>> getFavoriteHotelIds() => db.getAllFavoriteIds();
  Future<bool> isFavoriteHotel(String hotelId) => db.isFavorite(hotelId);

  Future<void> toggleHotel(String hotelId, {required bool makeFavorite}) async {
    if (makeFavorite) {
      await db.addHotel(hotelId);
    } else {
      await db.removeHotel(hotelId);
    }
  }
}
