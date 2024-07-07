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
    if (!mounted) return;

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

      if (!mounted) return;

      setState(() {
        _complaints = complaints;
        checkedIn = studentDoc.exists &&
            studentDoc.data()!.containsKey('studentRoomNo') &&
            studentDoc['studentRoomNo'] != null &&
            studentDoc['studentRoomNo'] != "";
        studentRoomNo = checkedIn ? studentDoc['studentRoomNo'] : null;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching complaints: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshData() async {
    await _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : checkedIn
                ? _buildComplaintsContent()
                : _buildNotCheckedInContent(),
      ),
    );
  }

  Widget _buildComplaintsContent() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _buildAddComplaintButton(),
        const SizedBox(height: 24),
        _complaints.isEmpty
            ? _buildEmptyState()
            : Column(
                children: _complaints
                    .map((complaint) => _buildComplaintItem(complaint))
                    .toList(),
              ),
        const SizedBox(height: 24),
        const Text(
          "Pull down to refresh your complaints.",
          style: TextStyle(color: Colors.grey, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
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
        ).then((_) => _refreshData());
      },
      icon: const Icon(Icons.add, size: 20),
      label: const Text("Add New Complaint", style: TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        elevation: 2,
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 200,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_satisfied, size: 80, color: Colors.grey),
            SizedBox(height: 24),
            Text(
              'No complaints yet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Great! Looks like everything is going well.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotCheckedInContent() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height - 100,
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, size: 80, color: Colors.orange),
                  SizedBox(height: 24),
                  Text(
                    'Check-In Required',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your check-in application must be approved before you can access this page.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('d MMM yyyy | hh:mm a')
                      .format(complaint.complaintDate),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                _buildStatusIndicator(complaint.complaintStatus),
              ],
            ),
            Text(
              complaint.complaintType,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              complaint.complaintDescription,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  complaint.complaintLocation,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            if (complaint.complaintNote != null &&
                complaint.complaintNote!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Note from Maintenance: ${complaint.complaintNote}',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic),
              ),
            ],
            if (complaint.complaintImageUrl.isNotEmpty) ...[
              const SizedBox(height: 16),
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
                    borderRadius: BorderRadius.circular(12),
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
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(
                  color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
