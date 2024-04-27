// ignore_for_file: library_private_types_in_public_api, avoid_print, file_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:khms/View/Common/appBar.dart';
import 'package:file_picker/file_picker.dart';

class CheckInPageSecond extends StatefulWidget {
  const CheckInPageSecond({super.key});

  @override
  _CheckInPageSecondState createState() => _CheckInPageSecondState();
}

class _CheckInPageSecondState extends State<CheckInPageSecond> {
  final _doBController = TextEditingController();
  final _iCController = TextEditingController();
  final _matricController = TextEditingController();

  File? _file1;
  File? _file2;

  Future<void> _pickFile(int buttonIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);

      setState(() {
        if (buttonIndex == 1) {
          _file1 = file;
        } else if (buttonIndex == 2) {
          _file2 = file;
        }
      });
    }
  }

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
                    controller: _doBController,
                    decoration:
                        const InputDecoration(labelText: "Date of Birth"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _iCController,
                    decoration: const InputDecoration(labelText: "UTM I/C No."),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _matricController,
                    decoration:
                        const InputDecoration(labelText: "Matric Number"),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    // Add the row for buttons
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center the buttons
                    children: [
                      _buildUploadButton("Upload Matric Card", 1),
                      _buildUploadButton("Upload Passport/myKad", 2),
                    ],
                  ),
                  if (_file1 != null)
                    Text("Selected File 1: ${_file1!.path.split('/').last}"),
                  if (_file2 != null)
                    Text("Selected File 2: ${_file2!.path.split('/').last}"),

                  const SizedBox(height: 20),
                  // Button
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("Submit"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton(String label, int buttonIndex) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(10), // Spacing between buttons
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          height: 85,
          child: TextButton(
            onPressed: () => _pickFile(buttonIndex),
            child: Text(
              label,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _doBController.dispose();
    _iCController.dispose();
    _matricController.dispose();
    super.dispose();
  }
}
