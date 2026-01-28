
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Blocs/RoomFeatureBloc/AdminRoomFeaturesBloc.dart';
import '../Blocs/RoomFeatureBloc/roomEvent.dart';
import '../Blocs/RoomFeatureBloc/roomState.dart';


class AdminAddRoomFeaturesPage extends StatelessWidget {
  final String roomId;
  const AdminAddRoomFeaturesPage({super.key, required this.roomId});

  static const mealsOptions = ['Breakfast', 'Lunch', 'Dinner', 'All inclusive'];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminRoomFeaturesBloc, AdminRoomFeaturesState>(
      listener: (context, state) {
        if (state.saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Room features saved ✅')),
          );
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Admin • Room Features')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                value: state.wifi,
                onChanged: (v) => context.read<AdminRoomFeaturesBloc>().add(WifiToggled(v)),
                title: const Text('Wi-Fi'),
              ),
              SwitchListTile(
                value: state.ac,
                onChanged: (v) => context.read<AdminRoomFeaturesBloc>().add(AcToggled(v)),
                title: const Text('Air Conditioning'),
              ),
              SwitchListTile(
                value: state.parking,
                onChanged: (v) => context.read<AdminRoomFeaturesBloc>().add(ParkingToggled(v)),
                title: const Text('Parking'),
              ),
              SwitchListTile(
                value: state.pool,
                onChanged: (v) => context.read<AdminRoomFeaturesBloc>().add(PoolToggled(v)),
                title: const Text('Pool'),
              ),
              SwitchListTile(
                value: state.gym,
                onChanged: (v) => context.read<AdminRoomFeaturesBloc>().add(GymToggled(v)),
                title: const Text('Gym'),
              ),

              const SizedBox(height: 14),
              const Text('Meals', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: mealsOptions.map((m) {
                  final selected = state.meals.contains(m);
                  return FilterChip(
                    selected: selected,
                    label: Text(m),
                    onSelected: (v) => context.read<AdminRoomFeaturesBloc>().add(
                      MealToggled(meal: m, selected: v),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: state.isSubmitting
                    ? null
                    : () => context.read<AdminRoomFeaturesBloc>().add(RoomFeaturesSubmitted(roomId)),
                child: state.isSubmitting
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Features'),
              ),
            ],
          ),
        );
      },
    );
  }
}
