// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:khms/View/Common/appBar.dart';

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
  File? _pickedImage;

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
              _buildDescriptionField(),
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
                onPressed: () {
                  // Handle form submission
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
        if (_selectedLocation == 'Location') _buildLocationField(),
      ],
    );
  }

  Widget _buildLocationField() {
    return const TextField(
      decoration: InputDecoration(hintText: "Enter location"),
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

  // ... _buildSubTypeDropdown() and _buildDescriptionField() functions
  // ... (The rest of your AddComplaintPage code)

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

  Widget _buildDescriptionField() {
    return TextFormField(
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: "Description for the maintenance/complaint request",
      ),

      // Consider adding a validator if the description field is mandatory
    );
  }

// ... (The rest of your AddComplaintPage code)
}
