// ignore_for_file: library_private_types_in_public_api, file_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:khms/View/Custom_Widgets/CheckInStatusWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentHomePage extends StatefulWidget {
  String studentName;

  StudentHomePage({super.key, this.studentName = ''});

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  Future<String?> _getStudentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('studentID');
  }

  @override
  Widget build(BuildContext context) {
    dynamic displayName =
        widget.studentName.isNotEmpty ? widget.studentName : 'Student';

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Welcome $displayName",
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              FutureBuilder<String?>(
                future: _getStudentId(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null) {
                    return const Center(child: Text('Student ID not found.'));
                  }

                  return CheckInStatusWidget(studentId: snapshot.data!);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
