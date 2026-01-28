import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingRepository {
  final SupabaseClient supabase;

  BookingRepository({SupabaseClient? supabaseClient})
      : supabase = supabaseClient ?? Supabase.instance.client;

  Future<void> createPaidBooking({
    required String userId,
    required String hotelId,
    required String roomId,

    // REQUIRED by your DB schema
    required DateTime checkIn,
    required DateTime checkOut,
    required int nights,
    required int persons,
    required int roomsCount,

    // Payment info
    required double totalPrice,
    required String currency,
    required String paymentProvider, // 'paypal'
    required String paymentStatus,   // 'paid'
    required String? paypalOrderId,  // PAYID...
  }) async {
    try {
      await supabase.from('bookings').insert({
        'user_id': userId,
        'hotel_id': hotelId,
        'room_id': roomId,

        // dates in DB are date type, send YYYY-MM-DD
        'check_in': checkIn.toIso8601String().substring(0, 10),
        'check_out': checkOut.toIso8601String().substring(0, 10),

        'nights': nights,
        'persons': persons,
        'rooms_count': roomsCount,

        'total_price': totalPrice,
        'currency': currency,

        'payment_provider': paymentProvider,
        'payment_status': paymentStatus,
        'paypal_order_id': paypalOrderId,

        // created_at / updated_at have defaults, no need to send
      });
    } on PostgrestException catch (e) {
      log('SUPABASE INSERT ERROR: ${e.message} | code=${e.code} | details=${e.details}');
      rethrow;
    } catch (e) {
      log('UNKNOWN INSERT ERROR: $e');
      rethrow;
    }
  }
}
