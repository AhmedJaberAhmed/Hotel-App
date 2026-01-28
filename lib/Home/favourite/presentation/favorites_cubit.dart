import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/favorites_repository_imp.dart';
import 'FavoritesState.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository repo;

  FavoritesCubit({required this.repo}) : super(FavoritesState.initial());

  Future<void> load() async {
    try {
      emit(state.copyWith(loading: true, error: null));
      final ids = await repo.getFavoriteHotelIds();
      emit(state.copyWith(favoriteHotelIds: ids, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> toggleHotel(String hotelId) async {
    final currentlyFav = state.isHotelFavorite(hotelId);

    // optimistic update
    final newSet = Set<String>.from(state.favoriteHotelIds);
    if (currentlyFav) {
      newSet.remove(hotelId);
    } else {
      newSet.add(hotelId);
    }
    emit(state.copyWith(favoriteHotelIds: newSet));

    try {
      await repo.toggleHotel(hotelId, makeFavorite: !currentlyFav);
    } catch (e) {
      // rollback if db fails
      final rollback = Set<String>.from(state.favoriteHotelIds);
      if (currentlyFav) {
        rollback.add(hotelId);
      } else {
        rollback.remove(hotelId);
      }
      emit(state.copyWith(favoriteHotelIds: rollback, error: e.toString()));
    }
  }
}
