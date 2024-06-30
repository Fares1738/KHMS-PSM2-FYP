import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khms/Controller/checkInController.dart';
import 'package:khms/Model/CheckInApplication.dart';
import 'package:khms/View/Staff/staffCheckInDetailsPage.dart';

class CheckInApplicationsListPage extends StatefulWidget {
  const CheckInApplicationsListPage({Key? key});

  @override
  State<CheckInApplicationsListPage> createState() =>
      _CheckInApplicationsListPageState();
}

class _CheckInApplicationsListPageState
    extends State<CheckInApplicationsListPage> {
  final CheckInController _controller = CheckInController();
  String _selectedStatusFilter = 'All';
  String _selectedRoomTypeFilter = 'All';
  String _selectedDateFilter = 'Oldest';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In Applications'),
      ),
      body: StreamBuilder<List<CheckInApplication>>(
        stream: _controller.fetchCheckInApplicationsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorWidget();
          } else if (snapshot.hasData) {
            final applications = _filterAndSortApplications(snapshot.data!);
            return _buildApplicationList(applications);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildApplicationList(List<CheckInApplication> applications) {
    return ListView.builder(
      itemCount: applications.length + 1, // +1 for the filter section
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildFilterSection();
        } else {
          final application = applications[index - 1];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(application.checkInStatus),
                child: Text(
                  application.checkInStatus[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                "${application.student!.studentFirstName} ${application.student!.studentLastName}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Applied on: ${DateFormat('dd MMM yyyy | hh:mm a').format(application.checkInApplicationDate)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text('Room Type: ${application.roomType}'),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CheckInDetailsPage(application: application),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildFilterSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterDropdown(
                    'Status',
                    _selectedStatusFilter,
                    ['All', 'Pending', 'Approved', 'Rejected'],
                    (value) => setState(() => _selectedStatusFilter = value!)),
                _buildFilterDropdown(
                    'Room Type',
                    _selectedRoomTypeFilter,
                    ['All', 'Single', 'Double', 'Triple'],
                    (value) =>
                        setState(() => _selectedRoomTypeFilter = value!)),
                _buildFilterDropdown(
                    'Sort By',
                    _selectedDateFilter,
                    ['Oldest', 'Newest'],
                    (value) => setState(() => _selectedDateFilter = value!)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          underline: Container(
            height: 2,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  List<CheckInApplication> _filterAndSortApplications(
      List<CheckInApplication> applications) {
    return applications.where((app) {
      if (_selectedStatusFilter != 'All' &&
          app.checkInStatus != _selectedStatusFilter) return false;
      if (_selectedRoomTypeFilter != 'All' &&
          app.roomType != _selectedRoomTypeFilter) return false;
      return true;
    }).toList()
      ..sort((a, b) => _selectedDateFilter == 'Oldest'
          ? a.checkInApplicationDate.compareTo(b.checkInApplicationDate)
          : b.checkInApplicationDate.compareTo(a.checkInApplicationDate));
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error loading applications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
