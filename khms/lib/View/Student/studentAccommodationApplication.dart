import 'dart:async';
import 'package:flutter/material.dart';
import 'package:khms/View/Student/studentCheckInPage.dart';
import 'package:khms/View/Student/studentCheckOutPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccommodationApplicationPage extends StatelessWidget {
  const AccommodationApplicationPage({super.key});

  Future<String?> _getStudentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getStudentId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Student ID not found.'));
        }

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
        );
      },
    );
  }
}
