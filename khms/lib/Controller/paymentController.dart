import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentController {
  static const String _publishableKey =
      'pk_test_51PURV8GEl1f5CNC2poQSXGf4NZeuFDerQr9NaJEavzD0oWhEKKJsuBn6qg2mJ6JVrKtpAk1PFZzgE6pT2H1oa2xi00CzAUqFA3'; // Replace
  static const String _secretKey =
      'sk_test_51PURV8GEl1f5CNC2ZsqpoKxa2u574F9D5fPLHc3FXmGgGbmtJBBSAv1uMFeTikBLac1or9yqiEGaT6vLqRfbqkCj006KzpD7AQ'; // Replace

  PaymentController() {
    Stripe.publishableKey = _publishableKey;
  }

  Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      final response = await http
          .post(Uri.parse('https://api.stripe.com/v1/payment_intents'), body: {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
      }, headers: {
        'Authorization': 'Bearer $_secretKey',
        'Content-Type': 'application/x-www-form-urlencoded'
      });

      return jsonDecode(response.body);
    } catch (err) {
      throw Exception('Error creating PaymentIntent: $err');
    }
  }

  Future<void> initializePaymentSheet(
      Map<String, dynamic> paymentIntentData, BuildContext context) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          merchantDisplayName: 'KHMS',
          // ...add other parameters as needed
          googlePay: const PaymentSheetGooglePay(
              merchantCountryCode: "MY", currencyCode: "MYR", testEnv: true),
        ),
      );
    } catch (e) {
      // Handle initialization error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing payment sheet: $e')),
      );
      throw e; // Re-throw the error to be caught in the calling function
    }
  }

  Future<bool> displayPaymentSheet(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return true; // Payment was successful
    } on Exception catch (e) {
      if (e is StripeException) {
        if (e.error.code == FailureCode.Canceled) {
          // Payment was canceled by the user
          return false;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing payment: $e')),
      );
      return false; // Payment failed
    }
  }

  Future<bool> checkPaymentStatus(String paymentIntentId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.stripe.com/v1/payment_intents/$paymentIntentId'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
      );

      final paymentIntent = jsonDecode(response.body);
      return paymentIntent['status'] == 'succeeded';
    } catch (e) {
      print('Error checking payment status: $e');
      return false;
    }
  }

  final _firestore = FirebaseFirestore.instance;

  Future<void> updateFacilitySubscription(String studentId) async {
    await _firestore
        .collection('Students')
        .doc(studentId)
        .update({'facilitySubscription': true});
  }
}
