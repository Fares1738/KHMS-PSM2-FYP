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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
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
    var filtered = applications.where((app) {
      final matchesStatus = selectedStatusFilter == 'All' ||
          app.checkOutStatus == selectedStatusFilter;
      final matchesSearch =
          "${app.student?.studentFirstName} ${app.student?.studentLastName}"
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();

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
      body: StreamBuilder<List<CheckOutApplication>>(
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredApplications.length +
                2, // +2 for search bar and filter section
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                );
              } else if (index == 1) {
                return _buildFilterSection();
              }
              final application = filteredApplications[
                  index - 2]; // Adjust for search bar and filter section
              return _buildCheckOutItem(application);
            },
          );
        },
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

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 6.0),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterDropdown(
              'Status',
              selectedStatusFilter,
              ['All', 'Completed', 'Pending', 'In Progress'],
              (value) {
                setState(() {
                  selectedStatusFilter = value!;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildFilterDropdown(
              'Sort Order',
              selectedSortOrder,
              ['Newest', 'Oldest'],
              (value) {
                setState(() {
                  selectedSortOrder = value!;
                  isSortDateAsc = value == 'Newest';
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
