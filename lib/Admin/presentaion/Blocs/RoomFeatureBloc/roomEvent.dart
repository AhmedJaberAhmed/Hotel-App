
import 'package:equatable/equatable.dart';

abstract class AdminRoomFeaturesEvent extends Equatable {
  const AdminRoomFeaturesEvent();
  @override
  List<Object?> get props => [];
}

class WifiToggled extends AdminRoomFeaturesEvent {
  final bool value;
  const WifiToggled(this.value);
  @override
  List<Object?> get props => [value];
}

class AcToggled extends AdminRoomFeaturesEvent {
  final bool value;
  const AcToggled(this.value);
  @override
  List<Object?> get props => [value];
}

class ParkingToggled extends AdminRoomFeaturesEvent {
  final bool value;
  const ParkingToggled(this.value);
  @override
  List<Object?> get props => [value];
}

class PoolToggled extends AdminRoomFeaturesEvent {
  final bool value;
  const PoolToggled(this.value);
  @override
  List<Object?> get props => [value];
}

class GymToggled extends AdminRoomFeaturesEvent {
  final bool value;
  const GymToggled(this.value);
  @override
  List<Object?> get props => [value];
}

class MealToggled extends AdminRoomFeaturesEvent {
  final String meal; // "Breakfast" ...
  final bool selected;
  const MealToggled({required this.meal, required this.selected});
  @override
  List<Object?> get props => [meal, selected];
}

class RoomFeaturesSubmitted extends AdminRoomFeaturesEvent {
  final String roomId;
  const RoomFeaturesSubmitted(this.roomId);
  @override
  List<Object?> get props => [roomId];
}
