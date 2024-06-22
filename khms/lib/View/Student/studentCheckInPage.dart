// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print, must_be_immutable

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khms/Controller/checkInController.dart';
import 'package:khms/Model/CheckInApplication.dart';
import 'package:khms/View/Custom_Widgets/appBar.dart';
import 'package:file_picker/file_picker.dart';

class CheckInPage extends StatefulWidget {
  String studentId;
  Map<String, dynamic> studentData;
  Map<String, dynamic> applicationData;
  CheckInPage({
    super.key,
    this.studentId = '',
    this.studentData = const {},
    this.applicationData = const {},
  });

  @override
  _CheckInPageState createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  final CheckInController _controller = CheckInController();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _passportController;
  late TextEditingController _phoneNoController;
  late TextEditingController _nationalityController;
  late TextEditingController _iCController;
  late TextEditingController _matricController;
  String? rejectReason;
  String? roomType;
  int? priceToDisplay;
  String? checkInApplicationId;
  DateTime? _dateOfBirth; // For the date of birth picker
  DateTime? _checkInDate; // For the check-in date picker

  File? _frontMatricPic;
  File? _backMatricPic;
  File? _passportMyKadPic;
  File? _studentPhoto;

  Future<void> _pickFile(int buttonIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);

      setState(() {
        if (buttonIndex == 1) {
          _frontMatricPic = file;
        } else if (buttonIndex == 2) {
          _backMatricPic = file;
        } else if (buttonIndex == 3) {
          _passportMyKadPic = file;
        } else if (buttonIndex == 4) {
          _studentPhoto = file;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _firstNameController =
        TextEditingController(text: widget.studentData['studentFirstName']);
    _lastNameController =
        TextEditingController(text: widget.studentData['studentLastName']);
    _passportController = TextEditingController(
        text: widget.studentData['studentmyKadPassportNumber']);
    _phoneNoController =
        TextEditingController(text: widget.studentData['studentPhoneNumber']);
    _nationalityController =
        TextEditingController(text: widget.studentData['studentNationality']);
    _iCController =
        TextEditingController(text: widget.studentData['studentIcNumber']);
    _matricController =
        TextEditingController(text: widget.studentData['studentMatricNo']);
    roomType = widget.applicationData['roomType'];
    priceToDisplay = widget.applicationData['price'];
    _dateOfBirth = (widget.studentData['studentDoB'] as Timestamp?)?.toDate();
    _checkInDate =
        (widget.applicationData['checkInDate'] as Timestamp?)?.toDate();
    rejectReason = widget.applicationData['rejectionReason'];
    checkInApplicationId = widget.applicationData['checkInApplicationId'] ?? '';

    if (roomType != null) {
      _calculatePrice();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GeneralCustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(30)
                  .add(const EdgeInsets.only(bottom: 100)),
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Check In",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  if (rejectReason != null)
                    Text(
                      'Reject Reason: $rejectReason',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.red),
                    ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                        labelText: "First Name",
                        prefixIcon: Icon(Icons.person)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                        labelText: "Last Name", prefixIcon: Icon(Icons.person)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passportController,
                    decoration: const InputDecoration(
                        labelText: "Passport/MyKad No.",
                        prefixIcon: Icon(Icons.document_scanner)),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null && pickedDate != _checkInDate) {
                        setState(() {
                          _checkInDate = pickedDate;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Check In Date",
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _checkInDate != null
                            ? DateFormat('dd/MM/yyyy').format(_checkInDate!)
                            : 'Select Check In Date',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _phoneNoController,
                    decoration: const InputDecoration(
                        labelText: "Phone No.", prefixIcon: Icon(Icons.phone)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nationalityController,
                    decoration: const InputDecoration(
                        labelText: "Nationality", prefixIcon: Icon(Icons.flag)),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null && pickedDate != _dateOfBirth) {
                        setState(() {
                          _dateOfBirth = pickedDate;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Date of Birth",
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _dateOfBirth != null
                            ? DateFormat('dd/MM/yyyy').format(_dateOfBirth!)
                            : 'Select Date of Birth',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _iCController,
                    decoration: const InputDecoration(
                        labelText: "UTM I/C No.",
                        prefixIcon: Icon(Icons.document_scanner)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _matricController,
                    decoration: const InputDecoration(
                        labelText: "Matric Number",
                        prefixIcon: Icon(Icons.numbers)),
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    "Type of Room",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 5),

                  Column(
                    children: [
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Single',
                            groupValue: roomType,
                            onChanged: (String? value) {
                              setState(() {
                                roomType = value;
                                if (roomType != null) {
                                  _calculatePrice();
                                } else {
                                  priceToDisplay = null;
                                }
                              });
                            },
                          ),
                          const Text("Single Room"),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Double',
                            groupValue: roomType,
                            onChanged: (String? value) {
                              setState(() {
                                roomType = value;
                                if (roomType != null) {
                                  _calculatePrice();
                                } else {
                                  priceToDisplay = null;
                                }
                              });
                            },
                          ),
                          const Text("Double Room"),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Triple',
                            groupValue: roomType,
                            onChanged: (String? value) {
                              setState(() {
                                roomType = value;
                                if (roomType != null) {
                                  _calculatePrice();
                                } else {
                                  priceToDisplay = null;
                                }
                              });
                            },
                          ),
                          const Text("Triple Room"),
                        ],
                      ),
                    ],
                  ),
                  const Text("Note: Double and Triple rooms are shared rooms"),

                  const SizedBox(height: 10),

                  if (roomType != null && priceToDisplay != null)
                    Text(
                      'Price: $priceToDisplay RM',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),

                  const SizedBox(height: 10),
                  Row(
                    // Add the row for buttons
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center the buttons
                    children: [
                      _buildUploadButton("Upload Front Matric Card", 1),
                      _buildUploadButton("Upload Back Matric Card", 2),
                    ],
                  ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center the buttons
                    children: [
                      if (_frontMatricPic != null)
                        Image.file(_frontMatricPic!, height: 250),
                      const SizedBox(width: 10),
                      if (_backMatricPic != null)
                        Image.file(_backMatricPic!, height: 250),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildUploadButton("Upload Passport/MyKad", 3),
                      _buildUploadButton("Upload Personal Photo", 4),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_passportMyKadPic != null)
                        Image.file(_passportMyKadPic!, height: 250),
                      const SizedBox(width: 10),
                      if (_studentPhoto != null)
                        Image.file(_studentPhoto!, height: 250),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Button
                  ElevatedButton(
                    onPressed: () {
                      _controller.submitCheckInApplication(
                          context,
                          _firstNameController.text,
                          _lastNameController.text,
                          _passportController.text,
                          _checkInDate!,
                          _phoneNoController.text,
                          _nationalityController.text,
                          _matricController.text,
                          _iCController.text,
                          _dateOfBirth!,
                          roomType!,
                          priceToDisplay!,
                          checkInApplicationId,
                          '',
                          _frontMatricPic,
                          _backMatricPic,
                          _passportMyKadPic,
                          _studentPhoto);
                    },
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

  void _calculatePrice() {
    CheckInApplication application = CheckInApplication(
        roomType: roomType,
        checkInApplicationDate: DateTime.now(),
        checkInApplicationId: '',
        checkInDate: DateTime.now(),
        studentId: '',
        checkInStatus: '',
        price: priceToDisplay, // Placeholder
        isPaid: null,
        );

    int calculatedPrice = application.calculatePrice();
    setState(() {
      priceToDisplay = calculatedPrice;
    });
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passportController.dispose();
    _phoneNoController.dispose();
    _nationalityController.dispose();
    _iCController.dispose();
    _matricController.dispose();
    super.dispose();
  }
}
