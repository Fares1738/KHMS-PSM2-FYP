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
  String selectedSortOrder = 'Newest';

  // --- Helper Functions ---
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green.shade400;
      case 'Pending':
        return Colors.orange.shade400;
      default:
        return Colors.blue.shade400; // In progress
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

  Widget _buildFilterDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey[700])),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<String>(
            value: value,
            items: items.map(_buildDropdownItem).toList(),
            onChanged: onChanged,
            isExpanded: true,
            underline: Container(),
          ),
        ),
      ],
    );
  }

  // --- Main UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check-Out Applications"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    "Status",
                    selectedStatusFilter,
                    ['All', 'Pending', 'In Progress', 'Completed'],
                    (value) => setState(() => selectedStatusFilter = value!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFilterDropdown(
                    "Sort By",
                    selectedSortOrder,
                    ['Oldest', 'Newest'],
                    (value) => setState(() => selectedSortOrder = value!),
                  ),
                ),
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
                        padding: const EdgeInsets.all(16),
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
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CheckOutDetailsPage(application: application),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${application.student?.studentFirstName} ${application.student?.studentLastName}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(application.checkOutStatus),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      application.checkOutStatus,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${DateFormat('dd MMM yyyy').format(application.checkOutDate)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View Details',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
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
