// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print, must_be_immutable

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khms/Controller/checkInController.dart';
import 'package:khms/Model/CheckInApplication.dart';
import 'package:khms/View/Custom_Widgets/appBar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:khms/View/Custom_Widgets/loadingDialog.dart';
import 'package:khms/View/Custom_Widgets/textFormFieldDesign.dart';

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

  final _formKey = GlobalKey<FormState>(); // Add a GlobalKey for the Form
  List<bool> _imageUploaded =
      List.generate(4, (index) => false); // Track image upload status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GeneralCustomAppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                    const SizedBox(height: 16),
                    CustomTextFormField(
                        controller: _firstNameController,
                        labelText: "First Name",
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        }),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                        controller: _lastNameController,
                        labelText: "Last Name",
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        }),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                        controller: _passportController,
                        labelText: "Passport/MyKad No.",
                        prefixIcon: Icons.document_scanner,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your passport/MyKad number';
                          }
                          return null;
                        }),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate;

                        // Function to check if a day is selectable (not Saturday)
                        bool isSelectableDay(DateTime date) {
                          return date.weekday != DateTime.saturday;
                        }

                        // Start checking from today to find the next selectable day
                        DateTime initialDate = DateTime.now();
                        while (!isSelectableDay(initialDate)) {
                          initialDate =
                              initialDate.add(const Duration(days: 1));
                        }

                        pickedDate = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 5)),
                          selectableDayPredicate: isSelectableDay,
                          builder: (BuildContext context, Widget? child) {
                            // Customize the appearance of each day in the calendar
                            if (child is Text) {
                              DateTime date = DateTime.parse(child.data!);
                              bool isDisabled =
                                  date.weekday == DateTime.saturday;

                              return Container(
                                decoration: BoxDecoration(
                                  color: isDisabled
                                      ? Colors.grey.withOpacity(0.4)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                alignment: Alignment.center,
                                child: child,
                              );
                            }
                            return child!;
                          },
                        );

                        if (pickedDate != null && pickedDate != _checkInDate) {
                          setState(() {
                            _checkInDate = pickedDate;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Check In Date',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.blue, width: 2),
                          ),
                        ),
                        child: Text(
                          _checkInDate != null
                              ? DateFormat('dd/MM/yyyy').format(_checkInDate!)
                              : 'Check In Date',
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: _phoneNoController,
                      labelText: "Phone Number",
                      prefixIcon: Icons.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null; // You can add more specific phone number validation here
                      },
                      isPhoneNumber:
                          true, // Enable numeric keyboard for this field
                    ),

                    const SizedBox(height: 16),

                    CustomTextFormField(
                        controller: _nationalityController,
                        labelText: "Nationality",
                        prefixIcon: Icons.flag,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your nationality';
                          }
                          return null;
                        },
                        isCountry:
                            true), // Set isCountry to true for this field
                    const SizedBox(height: 16),
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
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          prefixIcon: const Icon(Icons.calendar_month),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.blue, width: 2),
                          ),
                        ),
                        child: Text(
                          _dateOfBirth != null
                              ? DateFormat('dd/MM/yyyy').format(_dateOfBirth!)
                              : 'Date of Birth',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                        controller: _iCController,
                        labelText: "IC Number",
                        prefixIcon: Icons.credit_card,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your IC number';
                          }
                          return null;
                        }),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                        controller: _matricController,
                        labelText: "Matric Number",
                        prefixIcon: Icons.school,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your matric number';
                          }
                          return null;
                        }),

                    const SizedBox(height: 16),
                    const Text(
                      "Type of Room",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                    const Text(
                        "Note: Double and Triple rooms are shared rooms"),

                    const SizedBox(height: 16),

                    if (roomType != null && priceToDisplay != null)
                      Text(
                        'Price: $priceToDisplay RM',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),

                    const SizedBox(height: 16),
                    Row(
                      // Add the row for buttons
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Center the buttons
                      children: [
                        _buildUploadButton(
                            "Upload Front Matric Card", 1, _frontMatricPic),
                        _buildUploadButton(
                            "Upload Back Matric Card", 2, _backMatricPic),
                      ],
                    ),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Center the buttons
                      children: [
                        if (_frontMatricPic != null)
                          Image.file(_frontMatricPic!, height: 250, width: 175),
                        const SizedBox(width: 10),
                        if (_backMatricPic != null)
                          Image.file(_backMatricPic!, height: 250, width: 175),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildUploadButton(
                            "Upload Passport/MyKad", 3, _passportMyKadPic),
                        _buildUploadButton(
                            "Upload Personal Photo", 4, _studentPhoto),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_passportMyKadPic != null)
                          Image.file(_passportMyKadPic!,
                              height: 250, width: 175),
                        const SizedBox(width: 10),
                        if (_studentPhoto != null)
                          Image.file(_studentPhoto!, height: 250, width: 175),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text("Note: Only Image uploads are allowed"),
                    const SizedBox(height: 30),

                    // Button
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          // Update _imageUploaded state based on file selection
                          for (int i = 0; i < _imageUploaded.length; i++) {
                            _imageUploaded[i] = [
                                  _frontMatricPic,
                                  _backMatricPic,
                                  _passportMyKadPic,
                                  _studentPhoto
                                ][i] !=
                                null;
                          }
                        });
                        print(
                            "Form is invalid. Don't proceed to payment."); // Debugging message

                        if (_formKey.currentState!.validate() &&
                            _imageUploaded.every((element) => element)) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const LoadingDialog(
                                message:
                                    "Submitting check in application.\nRedirecting to payment...",
                              );
                            },
                          );

                          await _controller.submitCheckInApplication(
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
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Please fill out all fields and upload all required images."),
                            ),
                          );
                        }
                      },
                      child: const Text("Proceed to Payment"),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  Widget _buildUploadButton(String label, int buttonIndex, File? pickedFile) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
              color:
                  _imageUploaded[buttonIndex - 1] ? Colors.green : Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          height: 85,
          child: TextButton(
            onPressed: () => _pickFile(buttonIndex),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                ),
                if (!_imageUploaded[buttonIndex - 1] && pickedFile == null)
                  const Text(
                    "No image uploaded",
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDateField({
    required BuildContext context,
    required String labelText,
    required IconData prefixIcon,
    DateTime? initialDate,
    required Function(DateTime?) onDateChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        // Function to check if a day is selectable (not Saturday)
        bool isSelectableDay(DateTime date) {
          return date.weekday != DateTime.saturday;
        }

        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate ?? DateTime.now(),
          firstDate:
              labelText == "Check In Date" ? DateTime.now() : DateTime(1900),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          selectableDayPredicate:
              labelText == "Check In Date" ? isSelectableDay : null,
        );

        if (pickedDate != null) {
          onDateChanged(pickedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(prefixIcon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        child: Text(
          initialDate != null
              ? DateFormat('dd/MM/yyyy').format(initialDate)
              : 'Select $labelText',
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
