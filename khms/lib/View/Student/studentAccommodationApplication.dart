// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:khms/View/Student/studentCheckInPage_First.dart';
import 'studentHomePage.dart';

class AccommodationApplicationPage extends StatelessWidget {
  const AccommodationApplicationPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  builder: (context) => const CheckInPage(),
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
                  builder: (context) => const MyHomePage(),
                ),
              );
            },
            child: const Text("Check Out"),
          ),
        ],
      ),
    );
  }
}
