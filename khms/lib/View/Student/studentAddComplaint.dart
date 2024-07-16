import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khms/Model/Complaint.dart';
import 'dart:io';
import 'package:khms/Controller/complaintsController.dart';
import '../Custom_Widgets/appBar.dart';
import 'package:photo_view/photo_view.dart';

class AddComplaintPage extends StatefulWidget {
  final String? studentRoomNo;
  const AddComplaintPage({super.key, this.studentRoomNo});

  @override
  State<AddComplaintPage> createState() => _AddComplaintPageState();
}

class _AddComplaintPageState extends State<AddComplaintPage> {
  String? _selectedLocation;
  String? _selectedMaintenanceType;
  String? _selectedSubType;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _pickedImage;
  final _controller = ComplaintsController();

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
    "Other": [
      "Other",
    ],
  };

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (pickedFile != null) {
      File file = File(pickedFile.path);

      // Check file size
      int fileSizeInBytes = await file.length();
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > 5) {
        // Show error message if file size exceeds 5 MB
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Image size exceeds 5 MB. Please choose a smaller image."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _pickedImage = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GeneralCustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Submit a Complaint',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildLocationSection(),
              const SizedBox(height: 20),
              _buildMaintenanceTypeDropdown(),
              const SizedBox(height: 20),
              _buildSubTypeDropdown(),
              const SizedBox(height: 20),
              _buildDescriptionField(),
              const SizedBox(height: 20),
              _buildImageSection(),
              const SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Location",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
                const Text("Other Location"),
              ],
            ),
            if (_selectedLocation == 'Room' && widget.studentRoomNo != null)
              Text(
                'Your Room: ${widget.studentRoomNo}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            if (_selectedLocation == 'Location') _buildLocationField(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return TextField(
      controller: _locationController,
      decoration: const InputDecoration(
        hintText: "Enter location",
        border: OutlineInputBorder(),
      ),
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
      decoration: const InputDecoration(
        labelText: "Maintenance Type",
        border: OutlineInputBorder(),
      ),
      items: _maintenanceTypes
          .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedMaintenanceType = value;
          _selectedSubType = null;
        });
      },
    );
  }

  Widget _buildSubTypeDropdown() {
    if (_selectedMaintenanceType == null) {
      return const SizedBox.shrink();
    }

    return DropdownButtonFormField<String>(
      value: _selectedSubType,
      decoration: const InputDecoration(
        labelText: "Sub-Type",
        border: OutlineInputBorder(),
      ),
      items: _subTypes[_selectedMaintenanceType]!
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
      validator: (value) {
        if (_selectedMaintenanceType == 'Other' && value == null) {
          return "Please select a sub-type or provide a description";
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      maxLines: 3,
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: "Description",
        hintText: "Provide details about the maintenance/complaint request",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Attach Image",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _pickedImage != null
            ? Stack(
                alignment: AlignmentDirectional.topEnd,
                children: [
                  GestureDetector(
                    onTap: () {
                      _showFullScreenImage(_pickedImage!);
                    },
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(_pickedImage!),
                          fit: BoxFit.contain,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
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
            : ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Image'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
      ],
    );
  }

  void _showFullScreenImage(File image) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Container(
            child: PhotoView(
              imageProvider: FileImage(image),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              backgroundDecoration: const BoxDecoration(
                color: Colors.black,
              ),
              heroAttributes:
                  const PhotoViewHeroAttributes(tag: "complaintImage"),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_selectedLocation == null ||
            _selectedMaintenanceType == null ||
            _selectedSubType == null ||
            _descriptionController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please fill in all required fields.')),
          );
          return;
        }

        final complaintDescription = _descriptionController.text;
        final complaintLocation = _selectedLocation == 'Location'
            ? _locationController.text
            : _selectedLocation;

        final complaint = Complaint(
          complaintDate: DateTime.now(),
          complaintDescription: complaintDescription,
          complaintLocation: complaintLocation as String,
          complaintStatus: ComplaintStatus.Pending,
          complaintType: _selectedMaintenanceType!,
          complaintSubType: _selectedSubType!,
          complaintId: '',
          studentId: '',
          studentRoomNo: widget.studentRoomNo,
          complaintImageUrl: '',
        );

        try {
          await _controller.submitComplaint(context, complaint, _pickedImage);
        } catch (e) {
          print('Error submitting complaint: $e');
        }
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text('Submit Complaint'),
    );
  }
}
