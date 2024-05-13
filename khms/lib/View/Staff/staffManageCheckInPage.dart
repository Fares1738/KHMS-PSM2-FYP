// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khms/Controller/checkInController.dart';
import 'package:khms/Model/CheckInApplication.dart';
import 'package:khms/View/Staff/staffCheckInDetailsPage.dart';

class CheckInApplicationsListPage extends StatefulWidget {
  const CheckInApplicationsListPage({super.key});

  @override
  State<CheckInApplicationsListPage> createState() =>
      _CheckInApplicationsListPageState();
}

class _CheckInApplicationsListPageState
    extends State<CheckInApplicationsListPage> {
  final CheckInController _controller = CheckInController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-In Applications')),
      body: FutureBuilder<List<CheckInApplication>>(
        future: _controller.fetchCheckInApplicationsWithStudents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading applications'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final application = snapshot.data![index];
                return ListTile(
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(application.checkInStatus.toString(),
                          style: TextStyle(
                            color: application.checkInStatus == "Approved"
                                ? Colors.green
                                : application.checkInStatus == "Rejected"
                                    ? Colors.red
                                    : Colors.orange,
                          )),
                      const SizedBox(width: 20),
                      const Icon(Icons.arrow_forward_ios_rounded),
                    ],
                  ),
                  title: Text(
                    "${application.student!.studentFirstName} ${application.student!.studentLastName}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: ${DateFormat('dd MMM yyyy | hh:mm a').format(application.checkInApplicationDate)}',
                      ),
                      if (application.student != null) ...[
                        // Check if student is available

                        // Add other student details as needed
                      ],
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CheckInDetailsPage(application: application),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
