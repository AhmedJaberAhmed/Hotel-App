import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/AdminHotelCreate.dart';
import '../../../use case CreateHotel.dart';
import 'AdminHotelFormEvent.dart';
import 'AdminiHotelstate.dart';

class AdminHotelFormBloc extends Bloc<AdminHotelFormEvent, AdminHotelFormState> {
  final CreateHotel createHotel;

  AdminHotelFormBloc(this.createHotel) : super(const AdminHotelFormState()) {
    on<AdminHotelNameChanged>((e, emit) {
      emit(state.copyWith(name: e.value, error: null, createdHotelId: null));
    });

    on<AdminHotelDescriptionChanged>((e, emit) {
      emit(state.copyWith(description: e.value, error: null, createdHotelId: null));
    });

    on<AdminHotelCityChanged>((e, emit) {
      emit(state.copyWith(cityId: e.cityId, error: null, createdHotelId: null));
    });

    on<AdminHotelMinPriceChanged>((e, emit) {
      emit(state.copyWith(minPrice: e.value, error: null, createdHotelId: null));
    });

    // ✅ NEW: Cover image picked/removed
    on<AdminHotelCoverPicked>((e, emit) {
      if (e.file == null) {
        emit(state.copyWith(clearCoverFile: true, error: null, createdHotelId: null));
      } else {
        emit(state.copyWith(coverFile: e.file, error: null, createdHotelId: null));
      }
    });

    on<AdminHotelSubmitted>((e, emit) async {
      if (!state.isValid) {
        emit(state.copyWith(error: 'Please fill all fields correctly.'));
        return;
      }

      emit(state.copyWith(isSubmitting: true, error: null, createdHotelId: null));

      try {
        final id = await createHotel(
          AdminHotelCreate(
            name: state.name.trim(),
            description: state.description.trim(),
            cityId: state.cityId.trim(),
            minPricePerNight: double.parse(state.minPrice),
            currency: 'EGP',
            coverFile: state.coverFile, // ✅ NEW
          ),
        );

        emit(state.copyWith(isSubmitting: false, createdHotelId: id));
      } catch (err) {
        emit(state.copyWith(isSubmitting: false, error: err.toString()));
      }
    });
  }
}
