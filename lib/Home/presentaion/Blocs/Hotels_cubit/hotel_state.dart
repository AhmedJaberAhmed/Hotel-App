
import '../../../data/hotelImageModel.dart';
import '../../../data/hotel_model.dart';

abstract class HotelsState {}

class HotelsInitial extends HotelsState {}

class HotelsLoading extends HotelsState {}

class HotelsLoaded extends HotelsState {
  final List<HotelModel> hotels;
  HotelsLoaded(this.hotels);
}

class HotelsError extends HotelsState {
  final String message;
  HotelsError(this.message);
}

// Hotel Details States
abstract class HotelDetailsState {}

class HotelDetailsInitial extends HotelDetailsState {}

class HotelDetailsLoading extends HotelDetailsState {}

class HotelDetailsLoaded extends HotelDetailsState {
  final HotelModel hotel;
  final List<RoomModel> rooms;

  HotelDetailsLoaded({
    required this.hotel,
    required this.rooms,
  });
}

class HotelDetailsError extends HotelDetailsState {
  final String message;
  HotelDetailsError(this.message);
}