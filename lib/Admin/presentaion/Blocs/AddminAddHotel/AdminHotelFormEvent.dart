import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class AdminHotelFormEvent extends Equatable {
  const AdminHotelFormEvent();
  @override
  List<Object?> get props => [];
}

class AdminHotelCoverPicked extends AdminHotelFormEvent {
  final File? file; // null means removed
  const AdminHotelCoverPicked(this.file);

  @override
  List<Object?> get props => [file?.path];
}
class AdminHotelNameChanged extends AdminHotelFormEvent {
  final String value;
  const AdminHotelNameChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class AdminHotelDescriptionChanged extends AdminHotelFormEvent {
  final String value;
  const AdminHotelDescriptionChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class AdminHotelCityChanged extends AdminHotelFormEvent {
  final String cityId;
  const AdminHotelCityChanged(this.cityId);
  @override
  List<Object?> get props => [cityId];
}

class AdminHotelMinPriceChanged extends AdminHotelFormEvent {
  final String value; // keep string for form
  const AdminHotelMinPriceChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class AdminHotelSubmitted extends AdminHotelFormEvent {
  const AdminHotelSubmitted();
}
