// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:khms/Controller/checkOutController.dart';
import 'package:khms/Model/CheckOutApplication.dart';
import 'package:intl/intl.dart';
import 'package:khms/View/Staff/staffCheckOutDetailsPage.dart';

class CheckOutApplicationsListPage extends StatefulWidget {
  const CheckOutApplicationsListPage({super.key});

  @override
  _CheckOutApplicationsListPageState createState() =>
      _CheckOutApplicationsListPageState();
}

class _CheckOutApplicationsListPageState
    extends State<CheckOutApplicationsListPage> {
  final CheckOutController _controller = CheckOutController();
  bool isSortDateAsc = true;
  String selectedStatusFilter = 'All';
  String selectedSortOrder = 'Oldest';

  // --- Helper Functions ---
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      default:
        return const Color.fromARGB(
            255, 255, 181, 69); // In progress (assuming)
    }
  }

  List<CheckOutApplication> _filterApplications(
      List<CheckOutApplication> applications) {
    var filtered = selectedStatusFilter == 'All'
        ? applications
        : applications
            .where((app) => app.checkOutStatus == selectedStatusFilter)
            .toList();

    filtered.sort((a, b) => isSortDateAsc
        ? a.checkOutDate.compareTo(b.checkOutDate)
        : b.checkOutDate.compareTo(a.checkOutDate));

    return filtered;
  }

  // --- Dropdown Menu Builders ---
  DropdownMenuItem<String> _buildDropdownItem(String value) =>
      DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );

  Widget _buildStatusFilterDropdown() => DropdownButton<String>(
        value: selectedStatusFilter,
        items: ['All', 'Pending', 'In progress', 'Completed']
            .map(_buildDropdownItem)
            .toList(),
        onChanged: (value) => setState(() => selectedStatusFilter = value!),
        isExpanded: true,
      );

  Widget _buildSortOrderDropdown() => DropdownButton<String>(
        value: selectedSortOrder,
        items: ['Oldest', 'Newest'].map(_buildDropdownItem).toList(),
        onChanged: (value) => setState(() => selectedSortOrder = value!),
        isExpanded: true,
      );

  // --- Main UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Check-Out Applications")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("Status:  ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: _buildStatusFilterDropdown()),
                const Text("Sort By:  ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: _buildSortOrderDropdown()),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<CheckOutApplication>>(
              stream: _controller.fetchCheckOutApplicationsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final applications = snapshot.data ?? [];
                final filteredApplications = _filterApplications(applications);

                return filteredApplications.isEmpty
                    ? const Center(child: Text("No data found."))
                    : ListView.builder(
                        itemCount: filteredApplications.length,
                        itemBuilder: (context, index) =>
                            _buildCheckOutItem(filteredApplications[index]),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckOutItem(CheckOutApplication application) {
    return Card(
      child: ListTile(
        title: Text(
          "${application.student?.studentFirstName} ${application.student?.studentLastName}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Date: ${DateFormat('dd MMM yyyy').format(application.checkOutDate)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              application.checkOutStatus,
              style:
                  TextStyle(color: _getStatusColor(application.checkOutStatus)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CheckOutDetailsPage(application: application),
            ),
          );
        },
      ),
    );
  }
}
