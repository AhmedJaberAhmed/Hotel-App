import 'package:equatable/equatable.dart';

class AdminAddRoomState extends Equatable

{
  final String title;
  final String pricingModel; // per_person / per_room
  final String price;
  final String maxPersons;
  final String bedsCount;

  final bool isSubmitting;
  final String? createdRoomId;
  final String? error;

  const AdminAddRoomState({
    this.title = '',
    this.pricingModel = 'per_person',
    this.price = '',
    this.maxPersons = '2',
    this.bedsCount = '1',
    this.isSubmitting = false,
    this.createdRoomId,
    this.error,
  });

  bool get isValid =>
      title.trim().isNotEmpty &&
          (pricingModel == 'per_person' || pricingModel == 'per_room') &&
          double.tryParse(price) != null &&
          int.tryParse(maxPersons) != null &&
          int.tryParse(bedsCount) != null;

  AdminAddRoomState copyWith({
    String? title,
    String? pricingModel,
    String? price,
    String? maxPersons,
    String? bedsCount,
    bool? isSubmitting,
    String? createdRoomId,
    String? error,
  }) {
    return AdminAddRoomState(
      title: title ?? this.title,
      pricingModel: pricingModel ?? this.pricingModel,
      price: price ?? this.price,
      maxPersons: maxPersons ?? this.maxPersons,
      bedsCount: bedsCount ?? this.bedsCount,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      createdRoomId: createdRoomId,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [title, pricingModel, price, maxPersons, bedsCount, isSubmitting, createdRoomId, error];
}

