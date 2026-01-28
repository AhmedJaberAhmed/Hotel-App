import 'package:equatable/equatable.dart';

class FavoritesState extends Equatable {
  final Set<String> favoriteHotelIds;
  final bool loading;
  final String? error;

  const FavoritesState({
    required this.favoriteHotelIds,
    required this.loading,
    this.error,
  });

  factory FavoritesState.initial() =>
      const FavoritesState(favoriteHotelIds: {}, loading: true);

  FavoritesState copyWith({
    Set<String>? favoriteHotelIds,
    bool? loading,
    String? error,
  }) {
    return FavoritesState(
      favoriteHotelIds: favoriteHotelIds ?? this.favoriteHotelIds,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  bool isHotelFavorite(String hotelId) => favoriteHotelIds.contains(hotelId);

  @override
  List<Object?> get props => [favoriteHotelIds, loading, error];
}
