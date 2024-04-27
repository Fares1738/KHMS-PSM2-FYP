// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:khms/View/Common/appBar.dart';
import 'package:khms/View/Student/studentCheckInPage_Second.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  _CheckInPageState createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passportController = TextEditingController();
  final _checkInDateController = TextEditingController();
  final _phoneNoController = TextEditingController();
  final _nationalityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(50)
                  .add(const EdgeInsets.only(bottom: 100)),
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Check In",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 50),
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: "First Name"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: "Last Name"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passportController,
                    decoration:
                        const InputDecoration(labelText: "Passport/MyKad No."),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _checkInDateController,
                    decoration:
                        const InputDecoration(labelText: "Check In Date"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _phoneNoController,
                    decoration: const InputDecoration(labelText: "Phone No."),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nationalityController,
                    decoration: const InputDecoration(labelText: "Nationality"),
                  ),
                  const SizedBox(height: 20),
                  // Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CheckInPageSecond(),
                        ),
                      );
                    },
                    child: const Text("Next"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passportController.dispose();
    _checkInDateController.dispose();
    _phoneNoController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }
}
