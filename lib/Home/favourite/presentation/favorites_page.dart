import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../favourite/presentation/favorites_cubit.dart';
import '../../favourite/presentation/FavoritesState.dart';

import '../../presentaion/Blocs/Hotels_cubit/Hotels_Bloc.dart';
import '../../presentaion/Blocs/Hotels_cubit/hotel_state.dart';
import '../../presentaion/pages/hotel_list_screen.dart'; // for HotelCardModern (or import your card widget)

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F7FB),
        title: const Text('Favorites', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: BlocBuilder<HotelsCubit, HotelsState>(
        builder: (context, hotelsState) {
          if (hotelsState is HotelsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (hotelsState is HotelsError) {
            return Center(child: Text(hotelsState.message));
          }

          if (hotelsState is HotelsLoaded) {
            return BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, favState) {
                final favIds = favState.favoriteHotelIds;
                final favHotels = hotelsState.hotels
                    .where((h) => favIds.contains(h.id))
                    .toList();

                if (favHotels.isEmpty) {
                  return const Center(
                    child: Text(
                      'No favorites yet',
                      style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: favHotels.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    // ✅ Use your modern card (or your existing HotelCard)
                    return HotelCardModern(hotel: favHotels[index]);
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
