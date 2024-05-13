// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:khms/Model/CheckInApplication.dart';
import 'package:intl/intl.dart';
import 'package:khms/Controller/checkInController.dart';

class CheckInDetailsPage extends StatefulWidget {
  final CheckInApplication application;

  const CheckInDetailsPage({super.key, required this.application});

  @override
  State<CheckInDetailsPage> createState() => _CheckInDetailsPageState();
}

class _CheckInDetailsPageState extends State<CheckInDetailsPage> {
  final CheckInController _controller = CheckInController();
  final TextEditingController _rejectionReasonController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check-In Application Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStudentDetails(),
            const SizedBox(height: 30),
            _buildStatusSection(),
            _buildRejectionReasonSection(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDetails() {
    final student = widget.application.student;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Student Details:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Text(
            "Student Name: ${student?.studentFirstName} ${student?.studentLastName}"),
        Text(
            "Application Date: ${DateFormat('dd MMM yyyy | hh:mm a').format(widget.application.checkInApplicationDate)}"),
        Text(
            "Check-In Date: ${DateFormat('dd MMM yyyy | hh:mm a').format(widget.application.checkInDate)}"),
        Text("Email: ${student?.studentEmail}"),
        Text("Phone: ${student?.studentPhoneNumber}"),
        Text("Nationality: ${student?.studentNationality}"),
        Text("IC Number: ${student?.studentIcNumber}"),
        Text("MyKad/Passport Number: ${student?.studentmyKadPassportNumber}"),
        Text(
            "Date of Birth: ${DateFormat('dd MMM yyyy').format(student!.studentDoB)}"),
        const SizedBox(height: 20),
        const Text("Documents Uploaded:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHeroImage(student.frontMatricPic, "Front Matric Card"),
            const SizedBox(width: 20),
            _buildHeroImage(student.backMatricPic, "Back Matric Card"),
            const SizedBox(width: 20),
            _buildHeroImage(student.passportMyKadPic, "MyKad/Passport"),
          ],
        )
      ],
    );
  }

  Widget _buildHeroImage(String imageUrl, String tag) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HeroDetailScreen(imageUrl: imageUrl, tag: tag),
          ),
        );
      },
      child: Hero(
        tag: tag,
        child: Image.network(
          imageUrl,
          width: 100,
          height: 150,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    final application = widget.application;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Check-In Status: ${application.checkInStatus}",
          style: TextStyle(
            color: application.checkInStatus == "Approved"
                ? Colors.green
                : application.checkInStatus == "Rejected"
                    ? Colors.red
                    : Colors.orange,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRejectionReasonSection() {
    if (widget.application.checkInStatus == "Rejected") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Rejection Reason: ",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(widget.application.rejectionReason ?? "No reason provided"),
            ],
          ),
          const SizedBox(height: 20),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildButtons() {
    final application = widget.application;
    if (application.checkInStatus != 'Approved' &&
        application.checkInStatus != 'Rejected') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reject Application'),
                  content: TextField(
                    controller: _rejectionReasonController,
                    decoration: const InputDecoration(
                        hintText: "Enter rejection reason"),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text('Reject'),
                      onPressed: () {
                        _controller.updateCheckInApplicationStatus(
                          widget.application,
                          'Rejected',
                          _rejectionReasonController.text,
                        );
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
            child: const Text("Reject"),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              _controller.updateCheckInApplicationStatus(
                widget.application,
                'Approved',
                null,
              );
              Navigator.pop(context);
            },
            child: const Text("Approve"),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

class HeroDetailScreen extends StatelessWidget {
  final String imageUrl;
  final String tag;

  const HeroDetailScreen(
      {super.key, required this.imageUrl, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tag),
      ),
      body: Center(
        child: Hero(
          tag: tag,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
