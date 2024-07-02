import 'dart:async';
import 'package:flutter/material.dart';
import 'package:khms/View/Student/stripePaymentPage.dart';
import 'package:khms/View/Student/studentCheckInPage.dart';
import 'package:khms/View/Student/studentCheckOutPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccommodationApplicationPage extends StatelessWidget {
  const AccommodationApplicationPage({Key? key}) : super(key: key);

  Future<String?> _getStudentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<Map<String, dynamic>?> _getApplicationData(String studentId) async {
    final applicationSnapshot = await FirebaseFirestore.instance
        .collection('CheckInApplications')
        .where('studentId', isEqualTo: studentId)
        .get();

    if (applicationSnapshot.docs.isNotEmpty) {
      return applicationSnapshot.docs.first.data();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accommodation Applications'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<String?>(
        future: _getStudentId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return _buildErrorWidget('Student ID not found.');
          }

          final studentId = snapshot.data!;

          return FutureBuilder<Map<String, dynamic>?>(
            future: _getApplicationData(studentId),
            builder: (context, applicationSnapshot) {
              if (applicationSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (applicationSnapshot.hasError) {
                return _buildErrorWidget('Error fetching application data.');
              }

              final applicationData = applicationSnapshot.data;
              final isPaid =
                  applicationData != null && applicationData['isPaid'] == true;
              final price =
                  applicationData != null ? applicationData['price'] : 0;
              final checkInApplicationId = applicationData != null
                  ? applicationData['checkInApplicationId']
                  : '';

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeaderCard(context),
                      const SizedBox(height: 20),
                      if (applicationData != null && !isPaid)
                        _buildUnpaidApplicationCard(
                            context, price, checkInApplicationId)
                      else
                        _buildApplicationButtons(
                            context, applicationData, isPaid),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Card(
        color: Colors.red[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            message,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.house, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            const Text(
              "Accommodation Applications",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Manage your check-in and check-out applications here.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnpaidApplicationCard(
      BuildContext context, int price, String checkInApplicationId) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.warning, size: 48, color: Colors.orange),
            const SizedBox(height: 8),
            const Text(
              "Application Submitted",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "You have submitted the application but have not paid yet.",
              style: TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.payment),
              label: const Text("Continue with payment"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StripePaymentPage(
                      checkInApplicationId: checkInApplicationId,
                      priceToDisplay: price,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationButtons(BuildContext context,
      Map<String, dynamic>? applicationData, bool isPaid) {
    return Column(
      children: [
        _buildActionButton(
          context: context,
          icon: Icons.login,
          label: "Check In",
          onPressed: applicationData != null && isPaid
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CheckInPage()),
                  );
                },
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          context: context,
          icon: Icons.logout,
          label: "Check Out",
          onPressed: applicationData != null &&
                  applicationData['isPaid'] == true &&
                  applicationData['checkInStatus'] == "Approved"
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CheckOutPage()),
                  );
                }
              : null, // Disable if no check-in application or not paid
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
    );
  }
}
