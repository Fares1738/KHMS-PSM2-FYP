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
  String _selectedStatusFilter = 'All'; // Default to 'All'
  String _selectedRoomTypeFilter = 'All';
  String _selectedDateFilter = 'Oldest';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In Applications'),
      ),
      body: Column(
        children: [
          _buildFilterRow(), // Row for filters
          Expanded(
            child: StreamBuilder<List<CheckInApplication>>(
              stream: _controller.fetchCheckInApplicationsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error loading applications'));
                } else if (snapshot.hasData) {
                  final applications = snapshot.data!.where((app) {
                    // Filter based on selected status
                    if (_selectedStatusFilter != 'All' &&
                        app.checkInStatus != _selectedStatusFilter) {
                      return false;
                    }
                    if (_selectedRoomTypeFilter != 'All' &&
                        app.roomType != _selectedRoomTypeFilter) {
                      return false;
                    }
                    return true;
                  }).toList();

                  if (_selectedDateFilter == 'Oldest') {
                    applications.sort((a, b) => a.checkInApplicationDate
                        .compareTo(b.checkInApplicationDate));
                  } else {
                    applications.sort((a, b) => b.checkInApplicationDate
                        .compareTo(a.checkInApplicationDate));
                  }

                  return ListView.builder(
                    itemCount: applications.length,
                    itemBuilder: (context, index) {
                      final application = applications[index];
                      return Card(
                        child: ListTile(
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(application.checkInStatus.toString(),
                                  style: TextStyle(
                                    color:
                                        application.checkInStatus == "Approved"
                                            ? Colors.green
                                            : application.checkInStatus ==
                                                    "Rejected"
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
                                builder: (context) => CheckInDetailsPage(
                                    application: application),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text("Status: "),
          _buildStatusFilterDropdown(),
          const Text("Room Type: "),
          _buildRoomTypeFilterDropdown(),
          const Text("Sort By: "),
          _buildDateFilterDropdown(),
        ],
      ),
    );
  }

  Widget _buildStatusFilterDropdown() {
    return DropdownButton<String>(
      value: _selectedStatusFilter,
      onChanged: (String? newValue) {
        setState(() {
          _selectedStatusFilter = newValue!;
        });
      },
      items: <String>['All', 'Pending', 'Approved', 'Rejected']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildRoomTypeFilterDropdown() {
    return DropdownButton<String>(
      value: _selectedRoomTypeFilter,
      onChanged: (String? newValue) {
        setState(() {
          _selectedRoomTypeFilter = newValue!;
        });
      },
      items: <String>['All', 'Single', 'Double', 'Triple']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

//Dropdown for Date filter
  Widget _buildDateFilterDropdown() {
    return DropdownButton<String>(
      value: _selectedDateFilter,
      onChanged: (String? newValue) {
        setState(() {
          _selectedDateFilter = newValue!;
        });
      },
      items: <String>['Oldest', 'Newest']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
