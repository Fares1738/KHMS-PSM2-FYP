// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:khms/Controller/paymentController.dart';
import 'package:khms/Controller/checkInController.dart';

class StripePaymentPage extends StatefulWidget {
  final int priceToDisplay;
  final String checkInApplicationId;

  const StripePaymentPage(
      {super.key,
      required this.priceToDisplay,
      required this.checkInApplicationId});

  @override
  _StripePaymentPageState createState() => _StripePaymentPageState();
}

class _StripePaymentPageState extends State<StripePaymentPage> {
  final PaymentController _paymentController = PaymentController();
  final CheckInController _checkInController = CheckInController();
  bool _isLoading = true;
  bool _paymentSuccessful = false;

  @override
  void initState() {
    super.initState();
    _makePayment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Payment'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _paymentSuccessful
                ? const Text('Payment Successful')
                : const Text('Payment Cancelled or Failed'),
      ),
    );
  }

  Future<void> _makePayment() async {
    try {
      int price = widget.priceToDisplay * 100;

      // Create payment intent
      final paymentIntent = await _paymentController.createPaymentIntent(
        price.toString(),
        'MYR',
      );

      // Initialize payment sheet
      await _paymentController.initializePaymentSheet(paymentIntent, context);

      // Display payment sheet
      await _paymentController.displayPaymentSheet(context);

      // Check if the payment was successful
      // You'll need to implement this method in your PaymentController
      bool paymentSuccessful =
          await _paymentController.checkPaymentStatus(paymentIntent['id']);

      if (paymentSuccessful) {
        // Payment was successful
        setState(() {
          _isLoading = false;
          _paymentSuccessful = true;
        });

        // Update the check-in application with payment status
        await _checkInController
            .updateCheckInApplicationWithPayment(widget.checkInApplicationId);
      } else {
        // Payment was cancelled or failed
        setState(() {
          _isLoading = false;
          _paymentSuccessful = false;
        });
      }
    } catch (err) {
      // Handle errors and show a Snackbar or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment was not successful: $err')),
      );
      print('Error making payment: $err');

      // If there's an error, update UI state
      setState(() {
        _isLoading = false;
        _paymentSuccessful = false;
      });
    }
  }
}
