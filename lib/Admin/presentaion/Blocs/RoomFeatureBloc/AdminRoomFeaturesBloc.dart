
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_app/Admin/presentaion/Blocs/RoomFeatureBloc/roomEvent.dart';
import 'package:hotel_app/Admin/presentaion/Blocs/RoomFeatureBloc/roomState.dart';


import '../../../UpsertRoomFeatures.dart';

class AdminRoomFeaturesBloc extends Bloc<AdminRoomFeaturesEvent, AdminRoomFeaturesState> {
  final UpsertRoomFeatures upsert;

  AdminRoomFeaturesBloc(this.upsert) : super(const AdminRoomFeaturesState()) {
    on<WifiToggled>((e, emit) => emit(state.copyWith(wifi: e.value, saved: false, error: null)));
    on<AcToggled>((e, emit) => emit(state.copyWith(ac: e.value, saved: false, error: null)));
    on<ParkingToggled>((e, emit) => emit(state.copyWith(parking: e.value, saved: false, error: null)));
    on<PoolToggled>((e, emit) => emit(state.copyWith(pool: e.value, saved: false, error: null)));
    on<GymToggled>((e, emit) => emit(state.copyWith(gym: e.value, saved: false, error: null)));

    on<MealToggled>((e, emit) {
      final next = [...state.meals];
      if (e.selected) {
        if (!next.contains(e.meal)) next.add(e.meal);
      } else {
        next.remove(e.meal);
      }
      emit(state.copyWith(meals: next, saved: false, error: null));
    });

    on<RoomFeaturesSubmitted>((e, emit) async {
      if (state.isSubmitting) return;
      emit(state.copyWith(isSubmitting: true, saved: false, error: null));
      try {
        await upsert(
          roomId: e.roomId,
          wifi: state.wifi,
          meals: state.meals,
          ac: state.ac,
          parking: state.parking,
          pool: state.pool,
          gym: state.gym,
        );
        emit(state.copyWith(isSubmitting: false, saved: true));
      } catch (err) {
        emit(state.copyWith(isSubmitting: false, error: err.toString()));
      }
    });
  }
}



