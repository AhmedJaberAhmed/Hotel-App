
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Hotel_Repo_Repo_Imp.dart';
import 'hotel_state.dart';

class HotelsCubit extends Cubit<HotelsState> {
  final HotelsRepository repository;

  HotelsCubit({required this.repository}) : super(HotelsInitial());

  Future<void> loadHotels() async {
    emit(HotelsLoading());
    final result = await repository.getHotels();

    if (result.isRight) {
      emit(HotelsLoaded(result.right!));
    } else {
      emit(HotelsError(result.left!));
    }
  }

  Future<void> refreshHotels() async {
    await loadHotels();
  }
}

// ============================================================================
// 7. PRESENTATION LAYER - Hotel Details Cubit
// ============================================================================
// lib/features/hotels/presentation/cubit/hotel_details_cubit.dart

class HotelDetailsCubit extends Cubit<HotelDetailsState> {
  final HotelsRepository repository;

  HotelDetailsCubit({required this.repository}) : super(HotelDetailsInitial());

  Future<void> loadHotelDetails(String hotelId) async {
    emit(HotelDetailsLoading());

    final hotelResult = await repository.getHotelById(hotelId);
    final roomsResult = await repository.getRoomsByHotelId(hotelId);

    if (hotelResult.isRight && roomsResult.isRight) {
      emit(HotelDetailsLoaded(
        hotel: hotelResult.right!,
        rooms: roomsResult.right!,
      ));
    } else {
      final error = hotelResult.isLeft ? hotelResult.left! : roomsResult.left!;
      emit(HotelDetailsError(error));
    }
  }
}