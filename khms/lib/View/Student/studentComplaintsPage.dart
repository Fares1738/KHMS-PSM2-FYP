// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:khms/View/Student/studentAddComplaint.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  final List<ComplaintItem> _complaints = [
    ComplaintItem(
        title: "Complaint #1",
        description: "Short description of complaint 1."),
    ComplaintItem(
        title: "Complaint #2",
        description: "Short description of complaint 2."),
    ComplaintItem(
        title: "Complaint #3",
        description: "Short description of complaint 3."),
    ComplaintItem(
        title: "Complaint #4",
        description: "Short description of complaint 4."),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "Complaints",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            // Complaint List
            ListView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Prevents scrolling if there are only a few complaints
              itemCount: _complaints.length,
              itemBuilder: (context, index) {
                return _buildComplaintItem(_complaints[index]);
              },
            ),
            const SizedBox(height: 20),
            const Text("These are the ones which are already been registered",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            // Bottom Navigation (Replace with your navigation logic)
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintItem(ComplaintItem complaint) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              complaint.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(complaint.description),
          ]),
        ),
      ),
    );
  }
}

// Data structure for Complaint item
class ComplaintItem {
  final String title;
  final String description;
  ComplaintItem({required this.title, required this.description});
}
