// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:khms/Controller/CheckInController.dart';
import 'package:khms/Model/CheckInApplication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khms/View/Student/studentCheckInPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckInStatusWidget extends StatefulWidget {
  final String studentId;

  const CheckInStatusWidget({super.key, required this.studentId});

  @override
  _CheckInStatusWidgetState createState() => _CheckInStatusWidgetState();
}

class _CheckInStatusWidgetState extends State<CheckInStatusWidget> {
  final CheckInController _controller = CheckInController();
  CheckInApplication? _application;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  Future<void> _loadApplication() async {
    CheckInApplication? application =
        await _controller.getCheckInApplication(widget.studentId);
    setState(() {
      _application = application;
      _isLoading = false;
    });
  }

  Future<void> _resubmitApplication() async {
    final firestore = FirebaseFirestore.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String studentId = prefs.getString('userId')!;

    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('Students')
          .doc(widget.studentId)
          .get();
      QuerySnapshot query = await firestore
          .collection('CheckInApplications')
          .where('studentId', isEqualTo: studentId)
          .get();

      if (studentDoc.exists && query.docs.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckInPage(
                studentId: widget.studentId,
                studentData: studentDoc.data() as Map<String, dynamic>,
                applicationData:
                    query.docs.first.data() as Map<String, dynamic>),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to load data for resubmission.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Rejected':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  int? _calculateDaysLeft(DateTime? checkInApprovalDate) {
    if (checkInApprovalDate == null) {
      return null;
    }
    final rentDueDate = checkInApprovalDate.add(const Duration(days: 31));
    final currentDate = DateTime.now();
    final difference = rentDueDate.difference(currentDate).inDays;
    return difference;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_application == null) {
      return const Center(child: Text('Please Check In First'));
    }

    final daysLeft = _calculateDaysLeft(_application!.checkInApprovalDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        margin: const EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Check In Status: ',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    _application!.checkInStatus,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            _getStatusTextColor(_application!.checkInStatus)),
                  ),
                ],
              ),
              if (_application!.checkInStatus == 'Approved')
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Days left till rent payment: ',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      daysLeft != null ? '$daysLeft' : 'N/A',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              if (_application!.checkInStatus == 'Rejected')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    const Text('Rejection Reason:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(_application!.rejectionReason!,
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _resubmitApplication,
                      child: const Text('Resubmit Application'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
