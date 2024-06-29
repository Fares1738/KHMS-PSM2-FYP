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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              student != null ? _buildStudentDetails() : _buildStaffDetails(),
        ),
      ),
    );
  }

  Widget _buildStudentDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: CircleAvatar(
            radius: 80,
            backgroundImage: _determineProfileImage(),
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(Icons.person, 'Name',
            '${student!.studentFirstName} ${student!.studentLastName}'),
        _buildCard(Icons.email, 'Email', student!.studentEmail),
        _buildCard(Icons.school, 'Matric No', student!.studentMatricNo),
        _buildCard(Icons.credit_card, 'IC No', student!.studentIcNumber),
        _buildCard(Icons.meeting_room, 'Room No', student!.studentRoomNo),
        _buildCard(Icons.phone, 'Phone No', student!.studentPhoneNumber),
        _buildCard(Icons.calendar_today, 'Date of Birth',
            DateFormat('dd-MM-yyyy').format(student!.studentDoB)),
        _buildCard(Icons.document_scanner, 'MyKad/Passport',
            student!.studentmyKadPassportNumber),
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
            radius: 80,
            backgroundImage: _determineProfileImage(),
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(Icons.person, 'Name',
            '${staff!.staffFirstName} ${staff!.staffLastName}'),
        _buildCard(Icons.email, 'Email', staff!.staffEmail),
        _buildCard(Icons.phone, 'Phone No', staff!.staffPhoneNumber),
        _buildCard(
            Icons.work, 'Role', staff!.userType.toString().split('.').last),
        _buildCard(Icons.badge, 'Staff ID', staff!.staffId),
        // Add more fields as necessary
      ],
    );
  }

  Widget _buildCard(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
