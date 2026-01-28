


import 'package:equatable/equatable.dart';

class AdminRoomFeaturesState extends Equatable {
  final bool wifi;
  final bool ac;
  final bool parking;
  final bool pool;
  final bool gym;
  final List<String> meals;

  final bool isSubmitting;
  final bool saved;
  final String? error;

  const AdminRoomFeaturesState({
    this.wifi = false,
    this.ac = false,
    this.parking = false,
    this.pool = false,
    this.gym = false,
    this.meals = const [],
    this.isSubmitting = false,
    this.saved = false,
    this.error,
  });

  AdminRoomFeaturesState copyWith({
    bool? wifi,
    bool? ac,
    bool? parking,
    bool? pool,
    bool? gym,
    List<String>? meals,
    bool? isSubmitting,
    bool? saved,
    String? error,
  }) {
    return AdminRoomFeaturesState(
      wifi: wifi ?? this.wifi,
      ac: ac ?? this.ac,
      parking: parking ?? this.parking,
      pool: pool ?? this.pool,
      gym: gym ?? this.gym,
      meals: meals ?? this.meals,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      saved: saved ?? this.saved,
      error: error,
    );
  }

  @override
  List<Object?> get props => [wifi, ac, parking, pool, gym, meals, isSubmitting, saved, error];
}
