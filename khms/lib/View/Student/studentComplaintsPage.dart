// ignore_for_file: file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:khms/View/Student/studentAddComplaint.dart';
import 'package:khms/Model/Complaint.dart';
import 'package:khms/Controller/complaintsController.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'package:intl/intl.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  final _controller = ComplaintsController();
  List<Complaint> _complaints = [];
  bool checkedIn = false;
  bool _isLoading = false;
  String? studentId; // To store the current student's ID

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString('userId') as String;
      this.studentId = studentId; // Store studentId in the class variable

      final complaints = await _controller.fetchComplaints(studentId);

      // Fetch the student data to check the room number
      final studentDoc = await FirebaseFirestore.instance
          .collection('Students')
          .doc(studentId)
          .get();

      if (studentDoc.exists &&
          studentDoc.data()!.containsKey('studentRoomNo') &&
          studentDoc['studentRoomNo'] != null &&
          studentDoc['studentRoomNo'] != "") {
        checkedIn = true;
      }

      setState(() {
        _complaints = complaints;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching complaints: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: checkedIn == true
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    const Text(
                      "Complaints",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      _buildComplaintsList(),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddComplaintPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add New"),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                        "Your Complaints are listed here. You can add new complaints by clicking the 'Add New' button.",
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'You must check in first before accessing this page.',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildComplaintItem(Complaint complaint) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('d MMM yyyy | hh:mm a')
                    .format(complaint.complaintDate)),
                _buildStatusIndicator(complaint.complaintStatus),
              ],
            ),
            Text(complaint.complaintType,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(
              complaint.complaintDescription,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(complaint.complaintLocation),
            const SizedBox(height: 12),
            if (complaint.complaintImageUrl.isNotEmpty)
              Image.network(complaint.complaintImageUrl,
                  height: 150, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.Pending:
        return const Row(
          children: [
            Icon(Icons.pending, color: Color.fromARGB(255, 255, 230, 0)),
            SizedBox(width: 5),
            Text('Pending',
                style: TextStyle(color: Color.fromARGB(255, 255, 230, 0))),
          ],
        );
      case ComplaintStatus.Resolved:
        return const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 5),
            Text('Fixed', style: TextStyle(color: Colors.green)),
          ],
        );
      // Add cases for other statuses (InProgress, Resolved) as needed
      default:
        return const SizedBox.shrink(); // Default (e.g., if status is unknown)
    }
  }

  Widget _buildComplaintsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _complaints.length,
      itemBuilder: (context, index) {
        final complaint = _complaints[index];

        return _buildComplaintItem(complaint);
      },
    );
  }
}
