
import 'package:equatable/equatable.dart';

import '../../../CityEntity.dart';

class AdminCitiesState extends Equatable {
  final bool isLoading;
  final List<CityEntity> cities;
  final String? error;

  const AdminCitiesState({
    this.isLoading = false,
    this.cities = const [],
    this.error,
  });

  AdminCitiesState copyWith({
    bool? isLoading,
    List<CityEntity>? cities,
    String? error,
  }) {
    return AdminCitiesState(
      isLoading: isLoading ?? this.isLoading,
      cities: cities ?? this.cities,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, cities, error];
}
