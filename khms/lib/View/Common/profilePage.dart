// ignore_for_file: library_private_types_in_public_api, file_names, use_build_context_synchronously, avoid_print, no_leading_underscores_for_local_identifiers

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:khms/Controller/userController.dart';

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
      await _userController.fetchUserData();
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

        await _userController.updateUserData(_imageFile);
        _fetchData(); 
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error picking image!')),
      );
    }
  }

  void _showEditDialog(
      String title, String currentValue, Function(String) onSave) {
    TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: title),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
                              : _determineProfileImage(),
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
                        'Email',
                        _userController.student!.studentEmail,
                        Icons.email,
                        (newValue) async {
                          await _userController.updateUserEmail(newValue);
                          _fetchData();
                        },
                      ),
                      _buildProfileCard(
                        'Matric No',
                        _userController.student!.studentMatricNo,
                        Icons.school,
                      ),
                      _buildProfileCard(
                        'IC No',
                        _userController.student!.studentIcNumber,
                        Icons.credit_card,
                      ),
                      _buildProfileCard(
                        'Room No',
                        _userController.student!.studentRoomNo,
                        Icons.meeting_room,
                      ),
                      _buildProfileCard(
                        'Phone No',
                        _userController.student!.studentPhoneNumber,
                        Icons.phone,
                        (newValue) async {
                          await _userController.updateUserPhoneNumber(newValue);
                          _fetchData();
                        },
                      ),
                      _buildProfileCard(
                        'Date of Birth',
                        DateFormat('dd-MM-yyyy')
                            .format(_userController.student!.studentDoB),
                        Icons.calendar_today,
                      ),
                      _buildProfileCard(
                        'MyKad/Passport',
                        _userController.student!.studentmyKadPassportNumber,
                        Icons.document_scanner,
                      ),
                      _buildProfileCard(
                        'Student ID',
                        _userController.student!.studentId!,
                        Icons.badge,
                      ),
                      ElevatedButton(
                        onPressed: _showChangePasswordDialog,
                        child: const Text('Change Password'),
                      ),
                    ] else if (_userController.staff != null) ...[
                      // Display staff data
                      _buildProfileCard(
                        'Name',
                        '${_userController.staff!.staffFirstName} ${_userController.staff!.staffLastName}',
                        Icons.person,
                      ),
                      _buildProfileCard(
                        'Email',
                        _userController.staff!.staffEmail,
                        Icons.email,
                        (newValue) async {
                          await _userController.updateUserEmail(newValue);
                          _fetchData();
                        },
                      ),
                      _buildProfileCard(
                        'Phone No',
                        _userController.staff!.staffPhoneNumber,
                        Icons.phone,
                        (newValue) async {
                          await _userController.updateUserPhoneNumber(newValue);
                          _fetchData();
                        },
                      ),
                      _buildProfileCard(
                        'Role',
                        _userController.staff!.userType
                            .toString()
                            .split('.')
                            .last,
                        Icons.work,
                      ),
                      _buildProfileCard(
                        'Staff ID',
                        _userController.staff!.staffId,
                        Icons.badge,
                      ),
                      ElevatedButton(
                        onPressed: _showChangePasswordDialog,
                        child: const Text('Change Password'),
                      ),
                      // ... other staff-specific details
                    ] else ...[
                      const Text('No user data available'),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController oldPasswordController = TextEditingController();
        TextEditingController newPasswordController = TextEditingController();
        bool obscureOldPassword = true;
        bool obscureNewPassword = true;
        bool _hasUppercase = false;
        bool _hasSpecialChar = false;
        bool _hasValidLength = false;

        void _updatePasswordStrength(String password) {
          setState(() {
            _hasUppercase = password.contains(RegExp(r'[A-Z]'));
            _hasSpecialChar =
                password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
            _hasValidLength = password.length >= 8 && password.length <= 16;
          });
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPasswordController,
                    obscureText: obscureOldPassword,
                    decoration: InputDecoration(
                      labelText: 'Old Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureOldPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureOldPassword = !obscureOldPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscureNewPassword,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureNewPassword = !obscureNewPassword;
                          });
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _hasUppercase = value.contains(RegExp(r'[A-Z]'));
                        _hasSpecialChar =
                            value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
                        _hasValidLength =
                            value.length >= 8 && value.length <= 16;
                      });
                    },
                  ),
                  const SizedBox(height: 8.0),
                  _buildPasswordStrengthIndicator(
                    _hasValidLength,
                    _hasUppercase,
                    _hasSpecialChar,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _userController.changePassword(
                        _userController.student?.studentEmail ??
                            _userController.staff!.staffEmail,
                        oldPasswordController.text,
                        newPasswordController.text,
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password changed successfully!'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error changing password!'),
                        ),
                      );
                    }
                  },
                  child: const Text('Change Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPasswordStrengthIndicator(
    bool hasValidLength,
    bool hasUppercase,
    bool hasSpecialChar,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequirementRow(hasValidLength, '8-16 characters'),
        _buildRequirementRow(hasUppercase, 'At least 1 uppercase letter'),
        _buildRequirementRow(hasSpecialChar, 'At least 1 special character'),
      ],
    );
  }

  Widget _buildRequirementRow(bool isMet, String requirement) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.cancel,
          color: isMet ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          requirement,
          style: TextStyle(
            color: isMet ? Colors.green : Colors.red,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(String title, String value,
      [IconData? icon, Function(String)? onEdit]) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        leading: icon != null ? Icon(icon) : null,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
        trailing: onEdit != null
            ? IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditDialog(title, value, onEdit),
              )
            : null,
      ),
    );
  }

  ImageProvider _determineProfileImage() {
    if (_userController.student?.studentPhoto.isNotEmpty == true) {
      return NetworkImage(_userController.student!.studentPhoto);
    } else if (_userController.staff?.staffPhoto?.isNotEmpty == true) {
      return NetworkImage(_userController.staff!.staffPhoto!);
    } else {
      return const AssetImage('assets/images/default_profile_image.png');
    }
  }
}
