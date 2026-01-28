import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/hotel_model.dart';
import '../../favourite/presentation/FavoritesState.dart';
import '../../favourite/presentation/favorites_cubit.dart';
import '../Blocs/Hotels_cubit/Hotels_Bloc.dart';
import '../Blocs/Hotels_cubit/hotel_state.dart';
import 'room_card.dart';

class HotelDetailsScreen extends StatelessWidget {
  final String hotelId;

  const HotelDetailsScreen({Key? key, required this.hotelId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _UI.bg,
      body: SafeArea(
        top: false,
        child: BlocBuilder<HotelDetailsCubit, HotelDetailsState>(
          builder: (context, state) {
            if (state is HotelDetailsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: _UI.blue),
              );
            }

            if (state is HotelDetailsError) {
              return _DetailsError(
                message: state.message,
                onRetry: () => context.read<HotelDetailsCubit>().loadHotelDetails(hotelId),
              );
            }

            if (state is HotelDetailsLoaded) {
              return CustomScrollView(
                slivers: [
                  _DetailsHeader(hotel: state.hotel),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                      child: _HotelSummaryCard(hotel: state.hotel),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 18, 16, 8),
                      child: Text(
                        'Available Rooms',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: _UI.text,
                        ),
                      ),
                    ),
                  ),

                  if (state.rooms.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No rooms available',
                            style: TextStyle(
                              color: _UI.text3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList.separated(
                        itemCount: state.rooms.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final room = state.rooms[index];
                          return RoomCard(
                            room: room,
                            currency: state.hotel.currency,
                          );
                        },
                      ),
                    ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

/// Luxury UI tokens (local to this page)
class _UI {
  static const Color navy = Color(0xFF0B1220);
  static const Color blue = Color(0xFF1D4ED8);
  static const Color gold = Color(0xFFF5B301);

  static const Color bg = Color(0xFFF6F7FB);
  static const Color white = Colors.white;
  static const Color divider = Color(0xFFE9EEF5);

  static const Color text = Color(0xFF0F172A);
  static const Color text2 = Color(0xFF475569);
  static const Color text3 = Color(0xFF64748B);

  static const double cardR = 22;

  static List<BoxShadow> shadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}

class _DetailsHeader extends StatelessWidget {
  final HotelModel hotel;

  const _DetailsHeader({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 380,
      pinned: true,
      backgroundColor: _UI.white,
      leading: _CircleIconButton(
        icon: Icons.arrow_back_rounded,
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        BlocBuilder<FavoritesCubit,  FavoritesState>(
          builder: (context, favState) {
            final isFav = favState.isHotelFavorite(hotel.id);
            return _CircleIconButton(
              icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              onPressed: () => context.read<FavoritesCubit>().toggleHotel(hotel.id),
            );
          },
        ),
      ],

      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildHotelDetailImage(hotel),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.45),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: Text(
                hotel.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 12,
                      color: Color(0xAA000000),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelDetailImage(HotelModel hotel) {
    final imageUrl = hotel.coverImageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholderImage();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: _UI.bg,
          child: const Center(
            child: CircularProgressIndicator(color: _UI.blue),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFFEAECEF),
      child: const Center(
        child: Icon(Icons.hotel_rounded, size: 64, color: Color(0xFF94A3B8)),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _UI.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        color: _UI.navy,
        onPressed: onPressed,
      ),
    );
  }
}

class _HotelSummaryCard extends StatelessWidget {
  final HotelModel hotel;

  const _HotelSummaryCard({required this.hotel});

  @override
  Widget build(BuildContext context) {
    final cityText =
    hotel.city != null ? '${hotel.city!.name}, ${hotel.city!.country}' : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _UI.white,
        borderRadius: BorderRadius.circular(_UI.cardR),
        boxShadow: _UI.shadow,
        border: Border.all(color: _UI.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (cityText != null) ...[
                const Icon(Icons.location_on_rounded, size: 18, color: _UI.text3),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    cityText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _UI.text3,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
              if (hotel.rating != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: _UI.gold),
                      const SizedBox(width: 5),
                      Text(
                        hotel.rating!.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 14),

          if (hotel.description != null && hotel.description!.trim().isNotEmpty)
            Text(
              hotel.description!,
              style: const TextStyle(
                color: _UI.text2,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Text(
                'From ',
                style: TextStyle(
                  color: _UI.text3,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${hotel.minPricePerNight.toStringAsFixed(0)} ${hotel.currency}',
                style: const TextStyle(
                  color: _UI.blue,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const Text(
                ' / night',
                style: TextStyle(
                  color: _UI.text3,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DetailsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _UI.white,
            borderRadius: BorderRadius.circular(_UI.cardR),
            boxShadow: _UI.shadow,
            border: Border.all(color: _UI.divider),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 12),
              const Text(
                'Failed to load details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: _UI.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _UI.text3),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w900)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _UI.navy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
