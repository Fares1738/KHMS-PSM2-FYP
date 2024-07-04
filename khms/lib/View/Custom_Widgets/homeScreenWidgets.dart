import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khms/Controller/CheckInController.dart';
import 'package:khms/Model/CheckInApplication.dart';
import 'package:khms/Model/Student.dart';
import 'package:khms/View/Custom_Widgets/annoucementWidget.dart';
import 'package:khms/View/Student/stripePaymentPage.dart';
import 'package:khms/View/Student/studentCheckInPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreenWidgets extends StatefulWidget {
  final String studentId;

  const HomeScreenWidgets({super.key, required this.studentId});

  @override
  _HomeScreenWidgetsState createState() => _HomeScreenWidgetsState();
}

class _HomeScreenWidgetsState extends State<HomeScreenWidgets> {
  final CheckInController _controller = CheckInController();
  CheckInApplication? _application;
  bool _isLoading = true;
  DateTime? _lastFacilitySubscriptionPaidDate;
  DateTime? _lastRentPaidDate;
  bool? _facilitySubscription;

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  Future<void> _loadApplication() async {
    CheckInApplication? application =
        await _controller.getCheckInApplication(widget.studentId);

    DocumentSnapshot studentDoc = await FirebaseFirestore.instance
        .collection('Students')
        .doc(widget.studentId)
        .get();

    if (studentDoc.exists) {
      final student = Student.fromFirestore(studentDoc);
      _lastRentPaidDate = student.lastRentPaidDate;
      _lastFacilitySubscriptionPaidDate =
          student.lastFacilitySubscriptionPaidDate;
      _facilitySubscription = student.facilitySubscription;
    }

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
              applicationData: query.docs.first.data() as Map<String, dynamic>,
            ),
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

  int? _calculateDaysLeft(DateTime? lastPaidDate) {
    if (lastPaidDate == null) {
      return null;
    }
    final dueDate = lastPaidDate
        .add(const Duration(days: 31)); // 30 days from last payment date
    final currentDate = DateTime.now();
    final difference = dueDate.difference(currentDate).inDays;
    return difference;
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Check In Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _getStatusIcon(_application!.checkInStatus),
                  color: _getStatusTextColor(_application!.checkInStatus),
                ),
                const SizedBox(width: 8),
                Text(
                  _application!.checkInStatus,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _getStatusTextColor(_application!.checkInStatus),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(
      String title, int? daysLeft, VoidCallback onPressed) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Days left: ${daysLeft ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: daysLeft != null && daysLeft <= 3
                        ? Colors.red
                        : Colors.black,
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      daysLeft != null && daysLeft <= 3 ? onPressed : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Renew'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Application Rejected',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              'Reason: ${_application!.rejectionReason!}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _resubmitApplication,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Resubmit Application'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Rejected':
        return Icons.cancel;
      case 'Pending':
        return Icons.hourglass_empty;
      case 'Approved':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_application == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Please Check In First',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    final rentDaysLeft = _calculateDaysLeft(_lastRentPaidDate);
    final facilityDaysLeft =
        _calculateDaysLeft(_lastFacilitySubscriptionPaidDate);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            if (_application!.checkInStatus == 'Approved') ...[
              _buildPaymentCard(
                'Rent Payment',
                rentDaysLeft,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StripePaymentPage(
                      checkInApplicationId: _application!.checkInApplicationId,
                      priceToDisplay: _application!.price!,
                      studentId: widget.studentId,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_facilitySubscription!)
                _buildPaymentCard(
                  'Facility Subscription',
                  facilityDaysLeft,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StripePaymentPage(
                        priceToDisplay: 50,
                        studentId: widget.studentId,
                      ),
                    ),
                  ),
                ),
            ],
            if (_application!.checkInStatus == 'Rejected') ...[
              const SizedBox(height: 16),
              _buildRejectionCard(),
            ],
            const SizedBox(height: 24),
            const Text(
              'Announcements',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 300, // Set a fixed height for announcements
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AnnouncementWidget(studentId: widget.studentId),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
