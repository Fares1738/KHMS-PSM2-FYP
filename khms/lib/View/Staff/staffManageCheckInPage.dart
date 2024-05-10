import 'package:flutter/material.dart';
import 'package:khms/Controller/checkInController.dart';
import 'package:khms/Model/CheckInApplication.dart';

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
                  title: Text(application.checkInDate),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${application.checkInApplicationDate}'),
                      Text('ID: ${application.checkInApplicationId}'),
                      if (application.student != null) ...[
                        // Check if student is available
                        Text(
                            'Name: ${application.student!.studentFirstName} ${application.student!.studentLastName}'),
                        // Add other student details as needed
                      ],
                    ],
                  ),
                  onTap: () {
                    // Navigate to application details page (likely passing 'application')
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
