import 'package:equatable/equatable.dart';

abstract class AdminCitiesEvent extends Equatable {
  const AdminCitiesEvent();

  @override
  List<Object?> get props => [];
}

class AdminCitiesLoadRequested extends AdminCitiesEvent {
  const AdminCitiesLoadRequested();
}
