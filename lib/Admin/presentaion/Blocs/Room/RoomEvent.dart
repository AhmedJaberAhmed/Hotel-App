

import 'package:equatable/equatable.dart';

abstract class AdminAddRoomEvent extends Equatable {
  const AdminAddRoomEvent();
  @override
  List<Object?> get props => [];
}

class RoomTitleChanged extends AdminAddRoomEvent {
  final String value;
  const RoomTitleChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class RoomPricingModelChanged extends AdminAddRoomEvent {
  final String value; // per_person / per_room
  const RoomPricingModelChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class RoomPriceChanged extends AdminAddRoomEvent {
  final String value;
  const RoomPriceChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class RoomMaxPersonsChanged extends AdminAddRoomEvent {
  final String value;
  const RoomMaxPersonsChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class RoomBedsChanged extends AdminAddRoomEvent {
  final String value;
  const RoomBedsChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class RoomSubmitted extends AdminAddRoomEvent {
  final String hotelId;
  const RoomSubmitted(this.hotelId);
  @override
  List<Object?> get props => [hotelId];
}
