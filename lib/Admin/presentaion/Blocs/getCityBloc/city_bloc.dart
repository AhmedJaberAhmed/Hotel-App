import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../CityEntity.dart';
import 'cityEvent.dart';
import 'cityState.dart';

class AdminCitiesBloc extends Bloc<AdminCitiesEvent, AdminCitiesState> {
  final GetCitiesUseCase getCities;

  AdminCitiesBloc(this.getCities) : super(const AdminCitiesState()) {
    on<AdminCitiesLoadRequested>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        final cities = await getCities();
        emit(state.copyWith(isLoading: false, cities: cities));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
  }
}