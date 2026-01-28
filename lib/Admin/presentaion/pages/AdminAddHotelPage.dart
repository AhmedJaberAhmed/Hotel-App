import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../AdminCitiesRemoteDataSource.dart';
import '../../use case CreateHotel.dart';
import '../Blocs/AddminAddHotel/AdminHotelFormBloc.dart';
import '../Blocs/AddminAddHotel/AdminHotelFormEvent.dart';
import '../Blocs/AddminAddHotel/AdminiHotelstate.dart';
import '../Blocs/getCityBloc/cityEvent.dart';
import '../Blocs/getCityBloc/cityState.dart';
import '../Blocs/getCityBloc/city_bloc.dart';
import 'AdminAddRoomPage.dart';

class AdminAddHotelPage extends StatefulWidget {
  const AdminAddHotelPage({super.key});

  @override
  State<AdminAddHotelPage> createState() => _AdminAddHotelPageState();
}

class _AdminAddHotelPageState extends State<AdminAddHotelPage> {
  final ImagePicker _picker = ImagePicker();
  bool _citiesLoaded = false;

  // Luxury palette
  static const Color _navy = Color(0xFF1E3A8A);
  static const Color _gold = Color(0xFFFBBF24);
  static const Color _bg = Color(0xFFF6F7FB);
  static const Color _card = Colors.white;
  static const Color _mutedText = Color(0xFF6B7280);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_citiesLoaded) {
      context.read<AdminCitiesBloc>().add(const AdminCitiesLoadRequested());
      _citiesLoaded = true;
    }
  }

  Future<void> _pickCoverImage() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (xfile == null) return;

    context.read<AdminHotelFormBloc>().add(
      AdminHotelCoverPicked(File(xfile.path)),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null
          ? null
          : Icon(
        icon,
        color: _navy.withOpacity(.85),
      ),
      labelStyle: const TextStyle(color: _mutedText),
      hintStyle: const TextStyle(color: _mutedText),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withOpacity(.06)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withOpacity(.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _navy, width: 1.3),
      ),
    );
  }

  Widget _sectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12.5,
                color: _mutedText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminHotelFormBloc, AdminHotelFormState>(
      listener: (context, state) {
        if (state.createdHotelId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: _navy,
              content: Text('Hotel created: ${state.createdHotelId}'),
            ),
          );

          // ✅ Go to Add Rooms screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminAddRoomPage(hotelId: state.createdHotelId!),
            ),
          );
        }

        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.shade700,
              content: Text(state.error!),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: _bg,
          appBar: AppBar(
            backgroundColor: _bg,
            elevation: 0,
            centerTitle: false,
            title: const Text(
              'Admin • Add Hotel',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
              children: [
                // Top info card
                Container(
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: _navy.withOpacity(.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.hotel_rounded, color: _navy),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add a new hotel',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.5,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Fill details, pick a cover image, and publish.',
                              style: TextStyle(
                                color: _mutedText,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _gold.withOpacity(.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Premium',
                          style: TextStyle(
                            color: Color(0xFF8A5A00),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Form card
                Container(
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Hotel details'),
                      TextField(
                        decoration: _inputDecoration(
                          label: 'Hotel name',
                          hint: 'e.g. Cairo Nile Palace',
                          icon: Icons.badge_outlined,
                        ),
                        onChanged: (v) => context
                            .read<AdminHotelFormBloc>()
                            .add(AdminHotelNameChanged(v)),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        maxLines: 3,
                        decoration: _inputDecoration(
                          label: 'Description',
                          hint: 'Short description for guests',
                          icon: Icons.notes_rounded,
                        ),
                        onChanged: (v) => context
                            .read<AdminHotelFormBloc>()
                            .add(AdminHotelDescriptionChanged(v)),
                      ),
                      const SizedBox(height: 16),

                      _sectionTitle('Location'),
                      BlocBuilder<AdminCitiesBloc, AdminCitiesState>(
                        builder: (context, citiesState) {
                          if (citiesState.isLoading) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: LinearProgressIndicator(),
                            );
                          }

                          if (citiesState.error != null) {
                            return Text(
                              'Failed to load cities: ${citiesState.error}',
                              style: TextStyle(color: Colors.red.shade700),
                            );
                          }

                          return DropdownButtonFormField<String>(
                            value: state.cityId.isEmpty ? null : state.cityId,
                            decoration: _inputDecoration(
                              label: 'City',
                              hint: 'Select a city',
                              icon: Icons.location_on_outlined,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            items: citiesState.cities
                                .map(
                                  (c) => DropdownMenuItem<String>(
                                value: c.id,
                                child: Text(c.name),
                              ),
                            )
                                .toList(),
                            onChanged: (cityId) {
                              if (cityId == null) return;
                              context
                                  .read<AdminHotelFormBloc>()
                                  .add(AdminHotelCityChanged(cityId));
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      _sectionTitle(
                        'Pricing',
                        subtitle:
                        'Use Gold for the price to emphasize value & luxury.',
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          label: 'Min price per night (EGP)',
                          hint: 'e.g. 1500',
                          icon: Icons.payments_outlined,
                        ),
                        onChanged: (v) => context
                            .read<AdminHotelFormBloc>()
                            .add(AdminHotelMinPriceChanged(v)),
                      ),

                      const SizedBox(height: 18),

                      _sectionTitle('Cover image'),
                      _CoverImageCard(
                        navy: _navy,
                        gold: _gold,
                        mutedText: _mutedText,
                        file: state.coverFile,
                        isSubmitting: state.isSubmitting,
                        onPick: _pickCoverImage,
                        onRemove: () => context
                            .read<AdminHotelFormBloc>()
                            .add(const AdminHotelCoverPicked(null)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sticky CTA
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: _bg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.06),
                    blurRadius: 16,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () => context
                      .read<AdminHotelFormBloc>()
                      .add(const AdminHotelSubmitted()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    disabledBackgroundColor: _navy.withOpacity(.55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: state.isSubmitting
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Create Hotel',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CoverImageCard extends StatelessWidget {
  final Color navy;
  final Color gold;
  final Color mutedText;
  final File? file;
  final bool isSubmitting;
  final Future<void> Function() onPick;
  final VoidCallback onRemove;

  const _CoverImageCard({
    required this.navy,
    required this.gold,
    required this.mutedText,
    required this.file,
    required this.isSubmitting,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = file != null;

    return Container(
      decoration: BoxDecoration(
        color: navy.withOpacity(.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(.06)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: navy.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.photo_camera_back_rounded, color: Color(0xFF1E3A8A)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasFile ? 'Cover selected' : 'Choose a luxury cover photo',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
              if (hasFile)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: gold.withOpacity(.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Ready',
                    style: TextStyle(
                      color: Color(0xFF8A5A00),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasFile)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    file!,
                    height: 190,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    onTap: isSubmitting ? null : onRemove,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite_border, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Remove',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(.06)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_rounded, color: mutedText.withOpacity(.7), size: 36),
                  const SizedBox(height: 8),
                  Text(
                    'No image selected',
                    style: TextStyle(color: mutedText.withOpacity(.95)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSubmitting ? null : onPick,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Pick cover image'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: navy,
                    side: BorderSide(color: navy.withOpacity(.35)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tip: use a bright, high-quality hotel photo for a premium feel.',
            style: TextStyle(fontSize: 12, color: mutedText.withOpacity(.9)),
          ),
        ],
      ),
    );
  }
}
