import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khms/Model/Staff.dart';
import 'package:khms/Model/Student.dart';

class UserDetailPage extends StatelessWidget {
  final Student? student;
  final Staff? staff;

  const UserDetailPage({super.key, this.student, this.staff});

  ImageProvider _determineProfileImage() {
    if (student?.studentPhoto.isNotEmpty == true) {
      return NetworkImage(student!.studentPhoto);
    } else if (staff?.staffPhoto?.isNotEmpty == true) {
      return NetworkImage(staff!.staffPhoto!);
    } else {
      return const AssetImage('assets/images/default_profile_image.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: student != null ? _buildStudentDetails() : _buildStaffDetails(),
      ),
    );
  }

  Widget _buildStudentDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: CircleAvatar(
              radius: 80, backgroundImage: _determineProfileImage()),
        ),
        const SizedBox(height: 16),
        Text('Name: ${student!.studentFirstName} ${student!.studentLastName}',
            style: const TextStyle(fontSize: 18)),
        Text('Email: ${student!.studentEmail}',
            style: const TextStyle(fontSize: 18)),
        Text('Matric No: ${student!.studentMatricNo}',
            style: const TextStyle(fontSize: 18)),
        Text('IC No: ${student!.studentIcNumber}',
            style: const TextStyle(fontSize: 18)),
        Text('Room No: ${student!.studentRoomNo}',
            style: const TextStyle(fontSize: 18)),
        Text('Phone No: ${student!.studentPhoneNumber}',
            style: const TextStyle(fontSize: 18)),
        Text(
            'Date of Birth: ${DateFormat('dd-MM-yyyy').format(student!.studentDoB)}',
            style: const TextStyle(fontSize: 18)),
        Text('MyKad/Passport: ${student!.studentmyKadPassportNumber}',
            style: const TextStyle(fontSize: 18)),
        // Add more fields as necessary
      ],
    );
  }

  Widget _buildStaffDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: CircleAvatar(
              radius: 80, backgroundImage: _determineProfileImage()),
        ),
        const SizedBox(height: 16),

        Text('Name: ${staff!.staffFirstName} ${staff!.staffLastName}',
            style: const TextStyle(fontSize: 18)),
        Text('Email: ${staff!.staffEmail}',
            style: const TextStyle(fontSize: 18)),
        Text('Phone No: ${staff!.staffPhoneNumber}',
            style: const TextStyle(fontSize: 18)),
        Text('Role: ${staff!.userType.toString().split('.').last}',
            style: const TextStyle(fontSize: 18)),
        Text('Staff ID: ${staff!.staffId}',
            style: const TextStyle(fontSize: 18)),
        // Add more fields as necessary
      ],
    );
  }
}
