// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:khms/View/Staff/staffManageComplaintsPage.dart';
import 'package:khms/View/Staff/staffManageCheckInPage.dart';
import 'package:khms/View/Staff/staffManageCheckOutPage.dart';
import 'package:khms/View/Staff/staffManageFacilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageApplications extends StatefulWidget {
  const ManageApplications({super.key});

  @override
  _ManageApplicationsState createState() => _ManageApplicationsState();
}

class _ManageApplicationsState extends State<ManageApplications> {
  String? userType; // To store userType from SharedPreferences

  @override
  void initState() {
    super.initState();
    _getUserType();
  }

  Future<void> _getUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('userType');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Manage Hostel",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 250),
          if (userType == 'Manager' || userType == 'Staff') ...[
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FacilityManagementPage(),
                  ),
                );
              },
              child: const Text("Manage Facilities and Bookings"),
            ),
            const SizedBox(height: 20)
          ],
          if (userType == 'Maintenance' || userType == 'Manager')
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
