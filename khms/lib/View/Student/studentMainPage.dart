// ignore_for_file: library_private_types_in_public_api, file_names, must_be_immutable, avoid_print

import 'package:flutter/material.dart';
import 'package:khms/View/Custom_Widgets/appBar.dart';
import 'package:khms/View/Student/studentAccommodationApplication.dart';
import 'package:khms/View/Student/studentComplaintsPage.dart';
import 'package:khms/View/Student/studentFacilitiesPage.dart';
import 'package:khms/View/Student/studentHomePage.dart';
import '../Custom_Widgets/bottomNavStudent.dart';

class StudentMainPage extends StatefulWidget {
  String studentName;

  StudentMainPage({super.key, this.studentName = ''});

  @override
  _StudentMainPageState createState() => _StudentMainPageState();
}

class _StudentMainPageState extends State<StudentMainPage> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    dynamic displayName =
        widget.studentName.isNotEmpty ? widget.studentName : 'Student';

    print(displayName);

    return Scaffold(
        appBar: const HomeCustomAppBar(),
        drawer: const CustomDrawer(),
        body: IndexedStack(
          index: _currentPageIndex,
          children: [
            StudentHomePage(
              studentName: displayName,
            ),
            const ComplaintsPage(),
            const BookFacilitiesPage(),
            const AccommodationApplicationPage(),
          ],
        ),
        bottomNavigationBar: StudentBottomNavigationBar(
          onTap: (index) => setState(() {
            _currentPageIndex = index;
          }),
        ));
  }
}
