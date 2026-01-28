import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/BookingRepository.dart';



String _paypalCurrency(String appCurrency) {
  const supported = {'USD', 'EUR', 'GBP', 'AUD', 'CAD'};
  final c = appCurrency.toUpperCase();
  return supported.contains(c) ? c : 'USD';
}


double _convertToPayPalAmount({
  required double amount,
  required String appCurrency,
  required String paypalCurrency,
}) {
  if (appCurrency.toUpperCase() == 'EGP' && paypalCurrency == 'USD') {
    return amount / 50.0;
  }
  return amount;
}


String? _extractPaypalOrderId(Map params) {
  try {
    final data = params['data'];
    if (data is Map && data['id'] != null) {
      return data['id'].toString();
    }
  } catch (_) {}
  return null;
}

Future<void> startPayPalBooking({
  required BuildContext context,
  required String hotelId,
  required String roomId,


  required DateTime checkIn,
  required DateTime checkOut,
  required int nights,
  required int persons,
  required int roomsCount,


  required double totalAmount,
  required String currency,


  required String paypalClientId,
  required String paypalSecret,

  bool sandboxMode = true,
}) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please sign in first')),
    );
    return;
  }

  final bookingRepo = BookingRepository(supabaseClient: supabase);


  final payCurrency = _paypalCurrency(currency);


  final payAmount = _convertToPayPalAmount(
    amount: totalAmount,
    appCurrency: currency,
    paypalCurrency: payCurrency,
  );


  final total = payAmount.toStringAsFixed(2);

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PaypalCheckoutView(
        sandboxMode: sandboxMode,
        clientId: paypalClientId,
        secretKey: paypalSecret,
        transactions: [
          {
            "amount": {
              "total": total,
              "currency": payCurrency,
              "details": {
                "subtotal": total,
                "shipping": "0",
                "shipping_discount": 0,
              }
            },
            "description": "Hotel booking payment",
            "item_list": {
              "items": [
                {
                  "name": "Hotel Room Booking",
                  "quantity": 1,
                  "price": total,
                  "currency": payCurrency,
                }
              ],
            }
          }
        ],
        note: "Contact us for any questions on your booking.",

        onSuccess: (Map params) async {
          log("PAYPAL SUCCESS: $params");


          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }


          final messenger = ScaffoldMessenger.of(context);
          final paypalOrderId = _extractPaypalOrderId(params);

          try {
            await bookingRepo.createPaidBooking(
              userId: user.id,
              hotelId: hotelId,
              roomId: roomId,

              checkIn: checkIn,
              checkOut: checkOut,
              nights: nights,
              persons: persons,
              roomsCount: roomsCount,

              totalPrice: payAmount,
              currency: payCurrency,
              paymentProvider: 'paypal',
              paymentStatus: 'paid',
              paypalOrderId: paypalOrderId,
            );

            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,

                content: Text('Payment successful  Booking confirmed'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 3),
              ),
            );
          } catch (e) {
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              SnackBar(
                content: Text('Paid  but failed to save booking: $e'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },

        onError: (error) {
          log("PAYPAL ERROR: $error");

          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text('Payment failed: $error'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },

        onCancel: () {
          log("PAYPAL CANCELLED");

          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Payment cancelled'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    ),
  );
}
