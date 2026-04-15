import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  late Razorpay _razorpay;

  /// Initialize Razorpay and attach callbacks
  void init({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
  }) {
    _razorpay = Razorpay();

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      onSuccess,
    );

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      onError,
    );
  }

  /// Open Razorpay checkout
  void openCheckout({
    required String key,
    required String orderId,
    required int amount, // in rupees
    required String name,
    String description = '',
    String? email,
    String? contact,
  }) {
    final options = {
      'key': key,
      'order_id': orderId,
      'amount': amount * 100, // Razorpay expects paise
      'currency': 'INR',
      'name': name,
      'description': description,
      'prefill': {
        if (email != null) 'email': email,
        if (contact != null) 'contact': contact,
      },
      'theme': {
        'color': '#009688',
      }
    };

    _razorpay.open(options);
  }

  /// Clear listeners (VERY IMPORTANT)
  void dispose() {
    _razorpay.clear();
  }
}