import 'dart:async';
import 'package:flutter/material.dart';
import 'package:khms/View/Student/stripePaymentPage.dart';
import 'package:khms/View/Student/studentCheckInPage.dart';
import 'package:khms/View/Student/studentCheckOutPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class AccommodationApplicationPage extends StatelessWidget {
  const AccommodationApplicationPage({super.key});

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
    return FutureBuilder<String?>(
      future: _getStudentId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text('Student ID not found.'));
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
              return const Center(
                  child: Text('Error fetching application data.'));
            }

            final applicationData = applicationSnapshot.data;
            final isPaid =
                applicationData != null && applicationData['isPaid'] == true;
            final price =
                applicationData != null ? applicationData['price'] : 0;
            final checkInApplicationId = applicationData != null
                ? applicationData['checkInApplicationId']
                : '';

            return Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Accommodation Applications",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 300),
                  if (applicationData != null && !isPaid)
                    Column(
                      children: [
                        const Text(
                          "You have submitted the application but have not paid yet.",
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(250, 50),
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
                          child: const Text("Continue with payment"),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(250, 50),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckInPage(),
                              ),
                            );
                          },
                          child: const Text("Check In"),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(250, 50),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CheckOutPage(),
                              ),
                            );
                          },
                          child: const Text("Check Out"),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
