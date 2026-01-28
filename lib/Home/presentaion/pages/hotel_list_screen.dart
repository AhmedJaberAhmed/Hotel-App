import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Auth/presentaion/Blocs/Auth Bloc/Auth Cubit.dart';
import '../../Hotel_Repo_Repo_Imp.dart';
import '../../data/hotel_model.dart';
import '../../favourite/presentation/FavoritesState.dart';
import '../../favourite/presentation/favorites_cubit.dart';
import '../Blocs/Hotels_cubit/Hotels_Bloc.dart';
import '../Blocs/Hotels_cubit/hotel_state.dart';
import 'hotel_details_screen.dart';

class HotelsListScreen extends StatefulWidget {
  const HotelsListScreen({Key? key}) : super(key: key);

  @override
  State<HotelsListScreen> createState() => _HotelsListScreenState();
}

class _HotelsListScreenState extends State<HotelsListScreen> {
  final _searchCtrl = TextEditingController();

  String _query = '';
  bool _onlyFavorites = false;

  @override
  void initState() {
    super.initState();
    context.read<HotelsCubit>().loadHotels();
    // make sure favorites loaded (if not already loaded at app root)
    // context.read<FavoritesCubit>().load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _UI.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _UI.bg,
        foregroundColor: _UI.navy,
        title: const Text(
          'Find your stay',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: _SearchBar(
              controller: _searchCtrl,
              hint: 'Search hotels, cities...',
              onChanged: (v) => setState(() => _query = v.trim()),
              onClear: () {
                _searchCtrl.clear();
                setState(() => _query = '');
              },
            ),
          ),
        ),
      ),

      body: BlocBuilder<HotelsCubit, HotelsState>(
        builder: (context, state) {
          if (state is HotelsLoading) return const _HotelsListLoading();
          if (state is HotelsError) {
            return _ErrorState(
              message: state.message,
              onRetry: () => context.read<HotelsCubit>().loadHotels(),
            );
          }

          if (state is HotelsLoaded) {
            return BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, favState) {
                final favIds = favState.favoriteHotelIds;

                // 1) filter favorites if enabled
                var hotels = _onlyFavorites
                    ? state.hotels.where((h) => favIds.contains(h.id)).toList()
                    : List<HotelModel>.from(state.hotels);

                // 2) search query filter
                if (_query.isNotEmpty) {
                  final q = _query.toLowerCase();
                  hotels = hotels.where((h) {
                    final name = h.name.toLowerCase();
                    final city = (h.city?.name ?? '').toLowerCase();
                    final country = (h.city?.country ?? '').toLowerCase();
                    return name.contains(q) || city.contains(q) || country.contains(q);
                  }).toList();
                }

                return RefreshIndicator(
                  onRefresh: () => context.read<HotelsCubit>().refreshHotels(),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                          child: _TopChipsRow(
                            onlyFavorites: _onlyFavorites,
                            onToggleFavorites: () =>
                                setState(() => _onlyFavorites = !_onlyFavorites),
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                          child: _SectionHeader(
                            title: _onlyFavorites ? 'Your favorites' : 'Popular stays',
                            subtitle: _onlyFavorites
                                ? 'Saved hotels on this device'
                                : 'Top picks based on ratings & price',
                            count: hotels.length,
                          ),
                        ),
                      ),

                      if (hotels.isEmpty)
                        const SliverToBoxAdapter(child: _ModernEmptyState())
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          sliver: SliverList.separated(
                            itemCount: hotels.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              return HotelCardModern(hotel: hotels[index]);
                            },
                          ),
                        ),
                    ],
                  ),
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

/// ========================= Modern UI tokens =========================
class _UI {
  static const Color navy = Color(0xFF0B1220);
  static const Color blue = Color(0xFF2563EB);
  static const Color gold = Color(0xFFF5B301);

  static const Color bg = Color(0xFFF6F7FB);
  static const Color white = Colors.white;
  static const Color divider = Color(0xFFE9EEF5);

  static const Color text = Color(0xFF0F172A);
  static const Color text2 = Color(0xFF475569);
  static const Color text3 = Color(0xFF64748B);

  static const double cardR = 24;

  static List<BoxShadow> shadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 28,
      offset: const Offset(0, 12),
    ),
  ];
}

/// ========================= Search Bar =========================
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _UI.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _UI.shadow,
        border: Border.all(color: _UI.divider),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _UI.text3, fontWeight: FontWeight.w700),
          prefixIcon: const Icon(Icons.search_rounded, color: _UI.text2),
          suffixIcon: controller.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: onClear,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        ),
      ),
    );
  }
}

/// ========================= Filter Chips Row =========================
class _TopChipsRow extends StatelessWidget {
  final bool onlyFavorites;
  final VoidCallback onToggleFavorites;

  const _TopChipsRow({
    required this.onlyFavorites,
    required this.onToggleFavorites,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            icon: Icons.tune_rounded,
            label: 'Filters',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filters UI coming soon')),
              );
            },
          ),
          const SizedBox(width: 10),
          _Chip(
            icon: Icons.location_on_rounded,
            label: 'City',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('City filter coming soon')),
              );
            },
          ),
          const SizedBox(width: 10),
          _Chip(
            icon: Icons.star_rounded,
            label: 'Rating 4.0+',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rating filter coming soon')),
              );
            },
          ),
          const SizedBox(width: 10),
          _Chip(
            icon: onlyFavorites ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            label: 'Favorites',
            selected: onlyFavorites,
            onTap: onToggleFavorites,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _UI.navy : _UI.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? _UI.navy : _UI.divider),
          boxShadow: selected ? [] : _UI.shadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: selected ? Colors.white : _UI.text2),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : _UI.text,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ========================= Section Header =========================
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _UI.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _UI.text3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _UI.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _UI.divider),
          ),
          child: Text(
            '$count',
            style: const TextStyle(fontWeight: FontWeight.w900, color: _UI.text2),
          ),
        ),
      ],
    );
  }
}

/// ========================= Empty State =========================
class _ModernEmptyState extends StatelessWidget {
  const _ModernEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _UI.white,
            borderRadius: BorderRadius.circular(_UI.cardR),
            border: Border.all(color: _UI.divider),
            boxShadow: _UI.shadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.search_off_rounded, size: 54, color: Color(0xFF94A3B8)),
              SizedBox(height: 12),
              Text(
                'No results',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _UI.text),
              ),
              SizedBox(height: 6),
              Text(
                'Try different keywords or turn off Favorites.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _UI.text3, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ========================= Loading skeleton =========================
class _HotelsListLoading extends StatelessWidget {
  const _HotelsListLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: _UI.white,
        borderRadius: BorderRadius.circular(_UI.cardR),
        boxShadow: _UI.shadow,
      ),
      child: Column(
        children: [
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Color(0xFFEAECEF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(_UI.cardR)),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Container(height: 14, decoration: _sk()),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: Container(height: 12, decoration: _sk())),
                    const SizedBox(width: 10),
                    Container(width: 70, height: 12, decoration: _sk()),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(width: 120, height: 30, decoration: _sk(r: 12)),
                    const Spacer(),
                    Container(width: 44, height: 44, decoration: _sk(r: 16)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  static BoxDecoration _sk({double r = 10}) => BoxDecoration(
    color: const Color(0xFFEAECEF),
    borderRadius: BorderRadius.circular(r),
  );
}

/// ========================= Error State =========================
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

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
                'Something went wrong',
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
                    elevation: 0,
                    backgroundColor: _UI.navy,
                    foregroundColor: Colors.white,
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

/// ========================= Modern Hotel Card =========================
class HotelCardModern extends StatelessWidget {
  final HotelModel hotel;

  const HotelCardModern({Key? key, required this.hotel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cityText = hotel.city != null ? '${hotel.city!.name}, ${hotel.city!.country}' : '—';

    return InkWell(
      borderRadius: BorderRadius.circular(_UI.cardR),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context) => HotelDetailsCubit(
                repository: context.read<HotelsRepository>(),
              )..loadHotelDetails(hotel.id),
              child: HotelDetailsScreen(hotelId: hotel.id),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _UI.white,
          borderRadius: BorderRadius.circular(_UI.cardR),
          border: Border.all(color: _UI.divider),
          boxShadow: _UI.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(_UI.cardR)),
              child: Stack(
                children: [
                  _HotelImage(url: hotel.coverImageUrl),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.00),
                            Colors.black.withOpacity(0.55),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // rating
                  if (hotel.rating != null)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: _RatingBadge(value: hotel.rating!.toStringAsFixed(1)),
                    ),

                  // favorite
                  Positioned(
                    right: 12,
                    top: 12,
                    child: BlocBuilder<FavoritesCubit, FavoritesState>(
                      buildWhen: (p, c) => p.favoriteHotelIds != c.favoriteHotelIds,
                      builder: (context, favState) {
                        final isFav = favState.isHotelFavorite(hotel.id);
                        return _IconCircle(
                          icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          onTap: () => context.read<FavoritesCubit>().toggleHotel(hotel.id),
                        );
                      },
                    ),
                  ),

                  // name on image
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Text(
                      hotel.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        height: 1.15,
                        shadows: [
                          Shadow(offset: Offset(0, 2), blurRadius: 12, color: Color(0xAA000000)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // location
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: _UI.text3),
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
                  ),

                  const SizedBox(height: 10),

                  // perks row (optional)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _MiniTag(icon: Icons.wifi_rounded, label: 'Wi-Fi'),
                      _MiniTag(icon: Icons.free_breakfast_rounded, label: 'Breakfast'),
                      _MiniTag(icon: Icons.verified_rounded, label: 'Top rated'),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // price row
                  Row(
                    children: [
                      const Text(
                        'From ',
                        style: TextStyle(color: _UI.text3, fontWeight: FontWeight.w800),
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
                        style: TextStyle(color: _UI.text3, fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(fontWeight: FontWeight.w900, color: _UI.text),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HotelImage extends StatelessWidget {
  final String? url;
  const _HotelImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_UI.navy.withOpacity(0.12), _UI.blue.withOpacity(0.12)],
          ),
        ),
        child: const Icon(Icons.hotel_rounded, size: 64, color: Color(0xFF94A3B8)),
      );
    }

    return Image.network(
      url!,
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: 220,
          width: double.infinity,
          color: _UI.bg,
          child: const Center(child: CircularProgressIndicator(color: _UI.blue)),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        height: 220,
        width: double.infinity,
        color: const Color(0xFFEAECEF),
        child: const Icon(Icons.hotel_rounded, size: 64, color: Color(0xFF94A3B8)),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final String value;
  const _RatingBadge({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 16, color: _UI.gold),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconCircle({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
            ),
          ],
        ),
        child: Icon(icon, color: _UI.navy, size: 20),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _UI.blue),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: _UI.text,
            ),
          ),
        ],
      ),
    );
  }
}
