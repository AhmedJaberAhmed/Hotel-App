
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Blocs/Room/RoomEvent.dart';
import '../Blocs/Room/room_bloc.dart';
import '../Blocs/Room/room_state.dart';
import 'AdminAddRoomFeaturesPage.dart';

class AdminAddRoomPage extends StatelessWidget {
  final String hotelId;
  const AdminAddRoomPage({super.key, required this.hotelId});

  // Luxury palette
  static const Color _navy = Color(0xFF1E3A8A);
  static const Color _gold = Color(0xFFFBBF24);
  static const Color _bg = Color(0xFFF6F7FB);
  static const Color _muted = Color(0xFF6B7280);

  InputDecoration _dec(String label, {String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon, color: _navy.withOpacity(.85)),
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: _muted),
      hintStyle: const TextStyle(color: _muted),
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminAddRoomBloc, AdminAddRoomState>(
      listener: (context, state) {
        if (state.createdRoomId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: _navy,
              content: Text('Room created: ${state.createdRoomId}'),
            ),
          );

          // ✅ Navigate to room features
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminAddRoomFeaturesPage(roomId: state.createdRoomId!),
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
            title: const Text(
              'Admin • Add Room',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
            ),
          ),

          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Room details',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add pricing + capacity. Next you’ll add features.',
                      style: TextStyle(color: _muted.withOpacity(.95)),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      decoration: _dec(
                        'Room title',
                        hint: 'Standard / Deluxe / Suite',
                        icon: Icons.meeting_room_outlined,
                      ),
                      onChanged: (v) => context.read<AdminAddRoomBloc>().add(RoomTitleChanged(v)),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: state.pricingModel,
                      decoration: _dec('Pricing model', icon: Icons.tune),
                      borderRadius: BorderRadius.circular(16),
                      items: const [
                        DropdownMenuItem(value: 'per_person', child: Text('Per person')),
                        DropdownMenuItem(value: 'per_room', child: Text('Per room')),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        context.read<AdminAddRoomBloc>().add(RoomPricingModelChanged(v));
                      },
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      decoration: _dec(
                        'Price per night (EGP)',
                        hint: 'e.g. 1200',
                        icon: Icons.payments_outlined,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => context.read<AdminAddRoomBloc>().add(RoomPriceChanged(v)),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: _dec(
                              'Max persons',
                              hint: 'e.g. 2',
                              icon: Icons.people_outline,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => context.read<AdminAddRoomBloc>().add(RoomMaxPersonsChanged(v)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            decoration: _dec(
                              'Beds count',
                              hint: 'e.g. 1',
                              icon: Icons.bed_outlined,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => context.read<AdminAddRoomBloc>().add(RoomBedsChanged(v)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: _gold.withOpacity(.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.star_rounded, color: Color(0xFF8A5A00)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tip: Use premium pricing & clear capacity for best UX.',
                              style: TextStyle(
                                color: Color(0xFF8A5A00),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Sticky button
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
                      : () => context.read<AdminAddRoomBloc>().add(RoomSubmitted(hotelId)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    disabledBackgroundColor: _navy.withOpacity(.55),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: state.isSubmitting
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                  )
                      : const Text(
                    'Add Room',
                    style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
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
