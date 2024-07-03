import 'package:flutter/material.dart';
import 'package:khms/View/Student/studentAddComplaint.dart';
import 'package:khms/Model/Complaint.dart';
import 'package:khms/Controller/complaintsController.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

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
  String? studentRoomNo;
  String? studentId;

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
      this.studentId = studentId;

      final complaints = await _controller.fetchComplaints(studentId);

      final studentDoc = await FirebaseFirestore.instance
          .collection('Students')
          .doc(studentId)
          .get();

      if (studentDoc.exists &&
          studentDoc.data()!.containsKey('studentRoomNo') &&
          studentDoc['studentRoomNo'] != null &&
          studentDoc['studentRoomNo'] != "") {
        if (mounted) {
          setState(() {
            _complaints = complaints;
            _isLoading = false;
            checkedIn = true;
            studentRoomNo = studentDoc['studentRoomNo'];
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            checkedIn = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching complaints: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : checkedIn
              ? _buildComplaintsContent()
              : _buildNotCheckedInContent(),
    );
  }

  Widget _buildComplaintsContent() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAddComplaintButton(),
          const SizedBox(height: 16),
          _complaints.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: _complaints
                      .map((complaint) => _buildComplaintItem(complaint))
                      .toList(),
                ),
          const SizedBox(height: 16),
          const Text(
            "Your complaints are listed here. Pull down to refresh.",
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAddComplaintButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AddComplaintPage(studentRoomNo: studentRoomNo),
          ),
        ).then((_) =>
            _fetchData()); // Refresh the list when returning from AddComplaintPage
      },
      icon: const Icon(Icons.add),
      label: const Text("Add New Complaint"),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_satisfied, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No complaints yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Great! Looks like everything is going well.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Container(
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
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

  Widget _buildComplaintItem(Complaint complaint) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('d MMM yyyy | hh:mm a')
                      .format(complaint.complaintDate),
                  style: const TextStyle(color: Colors.grey),
                ),
                _buildStatusIndicator(complaint.complaintStatus),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              complaint.complaintType,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              complaint.complaintDescription,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              complaint.complaintLocation,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            if (complaint.complaintImageUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _showFullScreenImage(complaint.complaintImageUrl),
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(complaint.complaintImageUrl),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(ComplaintStatus status) {
    IconData icon;
    String text;
    Color color;

    switch (status) {
      case ComplaintStatus.Pending:
        icon = Icons.pending;
        text = 'Pending';
        color = Colors.orange;
        break;
      case ComplaintStatus.Resolved:
        icon = Icons.check_circle;
        text = 'Fixed';
        color = Colors.green;
        break;
      case ComplaintStatus.Unresolved:
        icon = Icons.dangerous;
        text = 'Not Fixed';
        color = Colors.red;
        break;
      default:
        icon = Icons.info;
        text = 'Visit Office';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildNotCheckedInContent() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Check-In Required',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your check-in application must be approved before you can access this page.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
