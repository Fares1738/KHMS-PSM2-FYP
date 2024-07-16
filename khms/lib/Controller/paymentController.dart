import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:khms/api/firebase_api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentController {
  final _publishableKey = dotenv.env['STRIPE_PUBLIC_KEY'] as String;
  final _secretKey = dotenv.env['STRIPE_SECRET_KEY'] as String;
  final _firestore = FirebaseFirestore.instance;

  PaymentController() {
    Stripe.publishableKey = _publishableKey;
  }

  Future<String> getOrCreateStripeCustomerId(String? email) async {
    try {
      // Retrieve studentId from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? studentId = prefs.getString('userId');

      DocumentSnapshot studentDoc =
          await _firestore.collection('Students').doc(studentId).get();
      String? stripeCustomerId = studentDoc.get('stripeCustomerId');
      String studentEmail = studentDoc.get('studentEmail');
      String studentName = studentDoc.get('studentFirstName') +
          ' ' +
          studentDoc.get('studentLastName');
      String studentPhone = studentDoc.get('studentPhoneNumber');

      if (stripeCustomerId != null && stripeCustomerId.isNotEmpty) {
        return stripeCustomerId;
      } else {
        // If no Stripe customer ID exists, create a new customer
        Map<String, dynamic> customerData = await createCustomer(
            email: studentEmail, name: studentName, phone: studentPhone);

        stripeCustomerId = customerData['id'];

        // Store the new Stripe customer ID in Firestore
        await _firestore.collection('Students').doc(studentId).update({
          'stripeCustomerId': stripeCustomerId,
        });

        return stripeCustomerId!;
      }
    } catch (e) {
      print('Error in getOrCreateCustomerId: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createCustomer({
    required String email,
    required String name,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': email,
          'name': name,
          'phone': phone,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create Stripe customer: ${response.body}');
      }
    } catch (err) {
      throw Exception('Error creating Stripe customer: $err');
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency,
      {String? customerId}) async {
    try {
      final body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      if (customerId != null) {
        body['customer'] = customerId;
      }

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
      );

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
          googlePay: const PaymentSheetGooglePay(
              merchantCountryCode: "MY", currencyCode: "MYR", testEnv: true),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing payment sheet: $e')),
      );
      rethrow; // Re-throw the error to be caught in the calling function
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

  Future<void> updateFacilitySubscription(
      String studentId, int? facilitiesDaysLeft) async {
    await _firestore.collection('Students').doc(studentId).update({
      'facilitySubscription': true,
      'lastFacilitySubscriptionPaidDate':
          DateTime.now().add(Duration(days: facilitiesDaysLeft ?? 0)),
    });

    FirebaseApi.sendNotification(
        collectionName: 'Students',
        documentId: studentId,
        'Facility Subscription',
        'Your facility subscription has been activated. Enjoy the facilities!');
  }
}
