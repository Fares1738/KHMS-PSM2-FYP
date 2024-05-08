// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:khms/View/Common/appBar.dart';
import 'package:khms/View/Student/studentAccommodationApplication.dart';
import 'package:khms/View/Student/studentComplaintsPage.dart';
import 'package:khms/View/Student/studentFacilitiesPage.dart';
import 'Custom_Widgets/bottomNavStudent.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
                "Home Page",
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
