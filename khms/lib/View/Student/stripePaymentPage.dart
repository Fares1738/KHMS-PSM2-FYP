import 'package:flutter/material.dart';
import 'package:khms/Controller/paymentController.dart';
import 'package:khms/Controller/checkInController.dart';
import 'package:khms/View/Student/studentMainPage.dart';

class StripePaymentPage extends StatefulWidget {
  final int? priceToDisplay;
  final String? checkInApplicationId;
  final String? studentId;
  final int? priceWithDeposit;
  final int? rentDaysLeft;
  final int? facilitiesDaysLeft;

  const StripePaymentPage({
    super.key,
    this.priceToDisplay,
    this.checkInApplicationId,
    this.studentId,
    this.priceWithDeposit,
    this.rentDaysLeft,
    this.facilitiesDaysLeft,
  });

  @override
  _StripePaymentPageState createState() => _StripePaymentPageState();
}

class _StripePaymentPageState extends State<StripePaymentPage> {
  final PaymentController _paymentController = PaymentController();
  final CheckInController _checkInController = CheckInController();
  bool _isLoading = true;
  bool _paymentSuccessful = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _makePayment();
    });
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
                : Text(_errorMessage.isNotEmpty
                    ? _errorMessage
                    : 'Payment Cancelled or Failed'),
      ),
    );
  }

  Future<void> _makePayment() async {
    try {
      int price;
      if (widget.priceWithDeposit != null) {
        price = widget.priceWithDeposit! * 100;
      } else if (widget.priceToDisplay != null) {
        price = widget.priceToDisplay! * 100;
      } else {
        throw Exception('Both priceWithDeposit and priceToDisplay are null');
      }

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
      String paymentIntentId = paymentIntent['id'] as String? ?? '';
      if (paymentIntentId.isEmpty) {
        throw Exception('Payment intent ID is empty');
      }

      bool paymentSuccessful =
          await _paymentController.checkPaymentStatus(paymentIntentId);

      if (paymentSuccessful) {
        setState(() {
          _isLoading = false;
          _paymentSuccessful = true;
        });

        if (widget.checkInApplicationId != null && widget.studentId != null) {
          await _checkInController.updateCheckInApplicationWithPayment(
              widget.checkInApplicationId!, widget.studentId!, widget.rentDaysLeft!);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => StudentMainPage()));
        } else if (widget.studentId != null) {
          await _paymentController
              .updateFacilitySubscription(widget.studentId!, widget.facilitiesDaysLeft!);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => StudentMainPage()));
        } else {
          throw Exception('Student ID is null');
        }
      } else {
        setState(() {
          _isLoading = false;
          _paymentSuccessful = false;
          _errorMessage = 'Payment was not successful';
        });
      }
    } catch (err) {
      _showErrorSnackBar('Error: ${err.toString()}');
      print('Error making payment: $err');

      setState(() {
        _isLoading = false;
        _paymentSuccessful = false;
        _errorMessage = 'Payment failed: ${err.toString()}';
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
