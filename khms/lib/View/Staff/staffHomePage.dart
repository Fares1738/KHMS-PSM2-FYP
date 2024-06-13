// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:khms/View/Custom_Widgets/appBar.dart';
import 'package:khms/View/Custom_Widgets/bottomNavStaff.dart';
import 'package:khms/View/Staff/staffDashboardPage.dart';
import 'package:khms/View/Staff/staffManagePage.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  _StaffHomePageState createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const HomeCustomAppBar(),
        body: IndexedStack(
          index: _currentPageIndex,
          children: const [
            Center(
              child: Text(
                "Staff Home Page",
                style: TextStyle(fontSize: 24),
              ),
            ),
            ManageApplications(),
            DashboardPage(),
          ],
        ),
        bottomNavigationBar: StaffBottomNavigationBar(
          onTap: (index) => setState(() {
            _currentPageIndex = index;
          }),
        ));
  }
}
