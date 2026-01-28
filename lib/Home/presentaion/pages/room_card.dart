import 'package:flutter/material.dart';
import '../../booking/presentation/paypal_checkout_helper.dart';
import '../../data/hotelImageModel.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final String currency;

  const RoomCard({
    Key? key,
    required this.room,
    required this.currency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pricingLabel =
    room.pricingModel == 'per_person' ? 'per person / night' : 'per room / night';

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
          Text(
            room.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: _UI.text,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(
                icon: Icons.people_alt_rounded,
                label: '${room.maxPersons} persons',
              ),
              _InfoPill(
                icon: Icons.bed_rounded,
                label: '${room.bedsCount} bed${room.bedsCount > 1 ? "s" : ""}',
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (room.features != null && room.features!.allFeatures.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: room.features!.allFeatures.map((feature) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    feature,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _UI.text,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${room.pricePerNight.toStringAsFixed(0)} $currency',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: _UI.blue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pricingLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _UI.text3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              // CTA
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    final totalAmount = room.pricePerNight; // or * nights

                    final checkIn = DateTime.now();
                    final checkOut = DateTime.now().add(const Duration(days: 2));
                    final nights = checkOut.difference(checkIn).inDays;

                    startPayPalBooking(
                      context: context,
                      hotelId: room.hotelId,
                      roomId: room.id,

                      checkIn: checkIn,
                      checkOut: checkOut,
                      nights: nights,
                      persons: room.maxPersons,
                      roomsCount: 1,

                      totalAmount: room.pricePerNight * nights,
                      currency: currency,

                      sandboxMode: true,
                      paypalClientId: "",
                      paypalSecret: "",
                    );

                  },

                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: _UI.navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text(
                    'Book now',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Luxury UI tokens (local to this file)
class _UI {
  static const Color navy = Color(0xFF0B1220);
  static const Color blue = Color(0xFF1D4ED8);
  static const Color gold = Color(0xFFF5B301);

  static const Color white = Colors.white;
  static const Color divider = Color(0xFFE9EEF5);

  static const Color text = Color(0xFF0F172A);
  static const Color text3 = Color(0xFF64748B);

  static const double cardR = 22;

  static List<BoxShadow> shadow = const [
    BoxShadow(
      blurRadius: 24,
      offset: Offset(0, 10),
      color: Color(0x12000000),
    ),
  ];
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
