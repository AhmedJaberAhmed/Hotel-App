
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_app/Admin/presentaion/Blocs/Room/room_state.dart';

import '../../../use case CreateHotel.dart';
import 'RoomEvent.dart';

class AdminAddRoomBloc extends Bloc<AdminAddRoomEvent, AdminAddRoomState> {
  final CreateRoom createRoom;
  AdminAddRoomBloc(this.createRoom) : super(const AdminAddRoomState()) {
    on<RoomTitleChanged>((e, emit) => emit(state.copyWith(title: e.value, error: null, createdRoomId: null)));
    on<RoomPricingModelChanged>((e, emit) => emit(state.copyWith(pricingModel: e.value, error: null, createdRoomId: null)));
    on<RoomPriceChanged>((e, emit) => emit(state.copyWith(price: e.value, error: null, createdRoomId: null)));
    on<RoomMaxPersonsChanged>((e, emit) => emit(state.copyWith(maxPersons: e.value, error: null, createdRoomId: null)));
    on<RoomBedsChanged>((e, emit) => emit(state.copyWith(bedsCount: e.value, error: null, createdRoomId: null)));

    on<RoomSubmitted>((e, emit) async {
      if (!state.isValid) {
        emit(state.copyWith(error: 'Please fill room fields correctly.'));
        return;
      }

      emit(state.copyWith(isSubmitting: true, error: null, createdRoomId: null));
      try {
        final id = await createRoom(
          hotelId: e.hotelId,
          title: state.title.trim(),
          pricingModel: state.pricingModel,
          pricePerNight: double.parse(state.price),
          maxPersons: int.parse(state.maxPersons),
          bedsCount: int.parse(state.bedsCount),
        );
        emit(state.copyWith(isSubmitting: false, createdRoomId: id));
      } catch (err) {
        emit(state.copyWith(isSubmitting: false, error: err.toString()));
      }
    });
  }
}
