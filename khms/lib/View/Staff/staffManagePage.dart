// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:khms/View/Staff/staffComplaintsPage.dart';
import 'package:khms/View/Staff/staffManageCheckInPage.dart';
import 'package:khms/View/Staff/staffManageCheckOutPage.dart';

class ManageApplications extends StatelessWidget {
  const ManageApplications({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Manage Applications",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 250),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(250, 50),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CheckInApplicationsListPage(),
                ),
              );
            },
            child: const Text("Check In Applications"),
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
                  builder: (context) => const CheckOutApplicationsListPage(),
                ),
              );
            },
            child: const Text("Check Out Applications"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(250, 50),
            ),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => ,
              //   ),
              // );
            },
            child: const Text("Facility Bookings"),
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
                  builder: (context) => const StaffComplaintsPage(),
                ),
              );
            },
            child: const Text("Complaints and Maintenance Requests"),
          ),
        ],
      ),
    );
  }
}
