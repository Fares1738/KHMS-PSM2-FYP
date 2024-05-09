// ignore_for_file: file_names, unused_local_variable, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khms/Model/Complaint.dart';
import 'dart:io';
import 'package:khms/View/Common/appBar.dart';
import 'package:khms/Controller/complaintsController.dart';

class AddComplaintPage extends StatefulWidget {
  const AddComplaintPage({super.key});

  @override
  State<AddComplaintPage> createState() => _AddComplaintPageState();
}

class _AddComplaintPageState extends State<AddComplaintPage> {
  // State Variables
  String? _selectedLocation; // Room or Location
  String? _selectedMaintenanceType;
  String? _selectedSubType;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _pickedImage;
  final _controller = ComplaintsController();

  String? _roomNumber;

  @override
  void initState() {
    super.initState();
    _fetchRoomNumber();
  }

  void _fetchRoomNumber() async {
    final roomNumber = await ComplaintsController().fetchStudentRoomNumber();
    setState(() {
      _roomNumber = roomNumber;
    });
  }

  // Dropdown Lists
  final _maintenanceTypes = [
    "Electrical",
    "Pest Control",
    "Piping",
    "Sanitary",
    "Other"
  ];

  final Map<String, List<String>> _subTypes = {
    "Electrical": [
      "Blackout / Trip",
      "Lamp",
      "Fan",
      "Socket",
      "Switch",
      "Air Conditioner"
    ],
    "Pest Control": ["Termites / Rat / Bat / Snake / Caterpillar"],
    "Piping": [
      "Shower head missing / Damage",
      "Lost water supply",
      "Head pipe Damage / Broken"
    ],
    "Sanitary": [
      "Toilet bowl clogged / Damage",
      "Sink Clogged / Damage / Leakage",
      "Cistern Broken / Damaged"
    ],
    "Other": [] // No pre-defined sub-types for 'Other'
  };

  // Image Selection
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildLocationRadio(),
              const SizedBox(
                height: 10,
              ),
              _buildMaintenanceTypeDropdown(),
              const SizedBox(
                height: 10,
              ),
              _buildSubTypeDropdown(), // Only shown if a maintenance type is selected
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                maxLines: 2,
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText:
                      "Description for the maintenance/complaint request",
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              _pickedImage != null
                  ? Stack(
                      alignment:
                          AlignmentDirectional.topEnd, // Position delete button
                      children: [
                        SizedBox(
                          height: 200,
                          width: double.infinity, // Adjust as needed
                          child: Image.file(_pickedImage!),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _pickedImage = null;
                            });
                          },
                          icon: const Icon(Icons.delete_forever,
                              color: Colors.red, size: 40),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Upload Image'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final complaintDescription = _descriptionController
                      .text; // Example assuming a TextField with a controller
                  final complaintLocation = _selectedLocation == 'Location'
                      ? _locationController.text
                      : _selectedLocation; // Conditional logic based on radio button

                  // 3. Create Complaint Object
                  final complaint = Complaint(
                      complaintDate: DateTime.now(),
                      complaintDescription: complaintDescription,
                      complaintLocation: complaintLocation as String,
                      complaintStatus:
                          ComplaintStatus.Pending, // Initially Pending
                      complaintType: _selectedMaintenanceType!,
                      complaintSubType: _selectedSubType!,
                      complaintId:
                          '', // Omit for auto-generated ID in Firestore
                      studentId: '',
                      studentRoomNo: '',
                      complaintImageUrl: '');

                  try {
                    final isSubmitted = await _controller.submitComplaint(
                        context, complaint, _pickedImage);
                  } catch (e) {
                    print('Error submitting complaint: $e');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Error submitting complaint.')));
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRadio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Room or Location"),
        Row(
          children: [
            Radio<String>(
              value: "Room",
              groupValue: _selectedLocation,
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value;
                });
              },
            ),
            const Text("Room"),
            Radio<String>(
              value: "Location",
              groupValue: _selectedLocation,
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value;
                });
              },
            ),
            const Text("Location"),
          ],
        ),
        if (_selectedLocation == 'Room' && _roomNumber != null)
          Text(
            'Your Room: $_roomNumber',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ), // Display room number
        if (_selectedLocation == 'Location') _buildLocationField(),
      ],
    );
  }

  Widget _buildLocationField() {
    return TextField(
      controller: _locationController,
      decoration: const InputDecoration(hintText: "Enter location"),
      onChanged: (value) {
        setState(() {
          _locationController.text = value;
        });
      },
    );
  }

  Widget _buildMaintenanceTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedMaintenanceType,
      hint: const Text("Select Maintenance Type"),
      items: _maintenanceTypes
          .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedMaintenanceType = value;
          _selectedSubType = null; // Reset sub-type when the main type changes
        });
      },
    );
  }

  Widget _buildSubTypeDropdown() {
    if (_selectedMaintenanceType == null ||
        _selectedMaintenanceType == 'Other') {
      return const SizedBox.shrink();
    }

    return DropdownButtonFormField<String>(
      value: _selectedSubType,
      hint: const Text("Select Sub-Type"),
      items: _subTypes[
              _selectedMaintenanceType]! // Access sub-types based on selection
          .map((subType) => DropdownMenuItem(
                value: subType,
                child: Text(subType),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedSubType = value;
        });
      },
      // Handle the case when the maintenance type is 'Other'
      validator: (value) {
        if (_selectedMaintenanceType == 'Other' && value == null) {
          return "Please select a sub-type or provide a description";
        }
        return null;
      },
    );
  }
}
