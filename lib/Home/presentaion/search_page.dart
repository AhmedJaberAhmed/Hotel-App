import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_app/Home/presentaion/pages/hotel_details_screen.dart';

import '../Hotel_Repo_Repo_Imp.dart';
import '../data/hotel_model.dart';
import 'Blocs/Hotels_cubit/Hotels_Bloc.dart';
import 'Blocs/Hotels_cubit/hotel_state.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<HotelModel> _filterHotels(List<HotelModel> hotels, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    return hotels.where((h) {
      final name = h.name.toLowerCase();
      final city = (h.city?.name ?? '').toLowerCase();
      final country = (h.city?.country ?? '').toLowerCase();
      return name.contains(q) || city.contains(q) || country.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F7FB),
        title: const Text('Search', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: BlocBuilder<HotelsCubit, HotelsState>(
        builder: (context, state) {
          if (state is HotelsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HotelsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(state.message),
              ),
            );
          }

          if (state is HotelsLoaded) {
            final results = _filterHotels(state.hotels, _query);

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE9EEF5)),
                    ),
                    child: TextField(
                      controller: _controller,
                      onChanged: (v) => setState(() => _query = v),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search_rounded),
                        hintText: 'Search hotels, cities...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                        suffixIcon: _query.trim().isEmpty
                            ? null
                            : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Results
                  Expanded(
                    child: _query.trim().isEmpty
                        ? const _SearchHint()
                        : results.isEmpty
                        ? const _NoResults()
                        : ListView.separated(
                      padding: const EdgeInsets.only(top: 4, bottom: 16),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final hotel = results[index];
                        return _SearchHotelCard(hotel: hotel);
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Small hint UI when search is empty
class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Text(
          'Start typing to search hotels by name, city, or country.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

/// No results UI
class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Text(
          'No results found.\nTry another keyword.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

/// A compact modern card for search results (tap -> details)
class _SearchHotelCard extends StatelessWidget {
  final HotelModel hotel;
  const _SearchHotelCard({required this.hotel});

  @override
  Widget build(BuildContext context) {
    final cityText =
    hotel.city != null ? '${hotel.city!.name}, ${hotel.city!.country}' : '—';

    return InkWell(
      borderRadius: BorderRadius.circular(18),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9EEF5)),
        ),
        child: Row(
          children: [
            // image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
              child: _HotelThumb(url: hotel.coverImageUrl),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0B1220),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            cityText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '${hotel.minPricePerNight.toStringAsFixed(0)} ${hotel.currency}',
                          style: const TextStyle(
                            color: Color(0xFF1E3A8A),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        const Text(
                          ' / night',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        if (hotel.rating != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 14, color: Color(0xFFF5B301)),
                                const SizedBox(width: 4),
                                Text(
                                  hotel.rating!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
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
}

class _HotelThumb extends StatelessWidget {
  final String? url;
  const _HotelThumb({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        height: 92,
        width: 92,
        color: const Color(0xFFEAECEF),
        child: const Icon(Icons.hotel_rounded, color: Color(0xFF94A3B8)),
      );
    }

    return Image.network(
      url!,
      height: 92,
      width: 92,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 92,
        width: 92,
        color: const Color(0xFFEAECEF),
        child: const Icon(Icons.hotel_rounded, color: Color(0xFF94A3B8)),
      ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: 92,
          width: 92,
          color: const Color(0xFFF6F7FB),
          child: const Center(
            child: SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }
}
