import 'dart:io';
import 'package:equatable/equatable.dart';

class AdminHotelFormState extends Equatable {
  final String name;
  final String description;
  final String cityId;
  final String minPrice;
  final bool isSubmitting;
  final String? createdHotelId;
  final String? error;

  final File? coverFile; // ✅ NEW

  const AdminHotelFormState({
    this.name = '',
    this.description = '',
    this.cityId = '',
    this.minPrice = '',
    this.isSubmitting = false,
    this.createdHotelId,
    this.error,
    this.coverFile,
  });

  bool get isValid =>
      name.trim().isNotEmpty &&
          description.trim().isNotEmpty &&
          cityId.trim().isNotEmpty &&
          double.tryParse(minPrice) != null;

  AdminHotelFormState copyWith({
    String? name,
    String? description,
    String? cityId,
    String? minPrice,
    bool? isSubmitting,
    String? createdHotelId,
    String? error,
    File? coverFile,
    bool clearCoverFile = false,
  }) {
    return AdminHotelFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      cityId: cityId ?? this.cityId,
      minPrice: minPrice ?? this.minPrice,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      createdHotelId: createdHotelId,
      error: error,
      coverFile: clearCoverFile ? null : (coverFile ?? this.coverFile),
    );
  }

  @override
  List<Object?> get props =>
      [name, description, cityId, minPrice, isSubmitting, createdHotelId, error, coverFile?.path];
}
