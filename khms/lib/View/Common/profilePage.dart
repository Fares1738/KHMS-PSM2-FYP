import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khms/Controller/userController.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  final UserController _userController = UserController();
  File? _imageFile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userController.addListener(() {
      setState(() {});
    });
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      await _userController.fetchStudentData();
    } catch (e) {
      print('Error fetching student data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching student data!')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });

        await _userController.updateStudentData(_imageFile);
        _fetchData(); // Refresh data after updating the image
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error picking image!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : (_userController
                                              .student?.studentPhoto.isNotEmpty ==
                                          true
                                      ? NetworkImage(
                                          _userController.student!.studentPhoto)
                                      : const AssetImage(
                                          'assets/images/default_profile_image.png'))
                                  as ImageProvider,
                          backgroundColor: Colors.grey[200],
                        ),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.edit, size: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_userController.student != null) ...[
                      Text(
                        '${_userController.student!.studentFirstName} ${_userController.student!.studentLastName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildProfileCard(
                          'Email', _userController.student!.studentEmail),
                      _buildProfileCard('Matric No',
                          _userController.student!.studentMatricNo),
                      _buildProfileCard(
                          'IC No', _userController.student!.studentIcNumber),
                      _buildProfileCard(
                          'Room No', _userController.student!.studentRoomNo),
                      _buildProfileCard('Phone No',
                          _userController.student!.studentPhoneNumber),
                      _buildProfileCard(
                          'Date of Birth',
                          DateFormat('dd-MM-yyyy')
                              .format(_userController.student!.studentDoB)),
                      _buildProfileCard('MyKad/Passport',
                          _userController.student!.studentmyKadPassportNumber),
                    ] else ...[
                      const Text('No student data available'),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileCard(String title, String value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
