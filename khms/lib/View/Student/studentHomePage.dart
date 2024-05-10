// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:khms/View/Custom_Widgets/appBar.dart';
import 'package:khms/View/Student/studentAccommodationApplication.dart';
import 'package:khms/View/Student/studentComplaintsPage.dart';
import 'package:khms/View/Student/studentFacilitiesPage.dart';
import '../Custom_Widgets/bottomNavStudent.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppBar(),
        body: IndexedStack(
          index: _currentPageIndex,
          children: const [
            Center(
              child: Text(
                "Student Home Page",
                style: TextStyle(fontSize: 24),
              ),
            ),
            ComplaintsPage(),
            FacilitiesPage(),
            AccommodationApplicationPage(),
          ],
        ),
        bottomNavigationBar: StudentBottomNavigationBar(
          onTap: (index) => setState(() {
            _currentPageIndex = index;
          }),
        ));
  }
}
