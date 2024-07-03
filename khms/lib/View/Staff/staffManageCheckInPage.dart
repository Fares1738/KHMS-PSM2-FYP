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
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'All';
  String _selectedRoomTypeFilter = 'All';
  String _selectedDateFilter = 'Newest';
  String _selectedPaidFilter = 'All'; // New filter for payment status
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In Applications'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: StreamBuilder<List<CheckInApplication>>(
        stream: _controller.fetchCheckInApplicationsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error); // Pass the error
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            final applications = _filterAndSortApplications(snapshot.data!);
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: applications.length + 1, // +1 for the filter section
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildFilterSection(); // First item is the filter section
                }
                final application =
                    applications[index - 1]; // Adjust for filter section
                return _buildApplicationCard(application);
              },
            );
          } else {
            return const Center(child: Text('No applications found'));
          }
        },
      ),
    );
  }

  Widget _buildApplicationCard(CheckInApplication application) {
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
                  CheckInDetailsPage(application: application),
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
                      "${application.student!.studentFirstName} ${application.student!.studentLastName}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(application.checkInStatus),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      application.checkInStatus,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Applied on: ${DateFormat('dd MMM yyyy | hh:mm a').format(application.checkInApplicationDate)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                'Room Type: ${application.roomType}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Payment Status: ',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: application.isPaid! ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      application.isPaid! ? 'Paid' : 'Not Paid',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
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
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search by Name',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  "Status",
                  _selectedStatusFilter,
                  ['All', 'Pending', 'Approved', 'Rejected'],
                  (value) => setState(() => _selectedStatusFilter = value!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown(
                  "Room Type",
                  _selectedRoomTypeFilter,
                  ['All', 'Single', 'Double', 'Triple'],
                  (value) => setState(() => _selectedRoomTypeFilter = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  "Sort By",
                  _selectedDateFilter,
                  ['Oldest', 'Newest'],
                  (value) => setState(() => _selectedDateFilter = value!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown(
                  "Paid",
                  _selectedPaidFilter,
                  ['All', 'Yes', 'No'],
                  (value) => setState(() => _selectedPaidFilter = value!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey[700])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<String>(
            value: value,
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
            isExpanded: true,
            underline: Container(),
          ),
        ),
      ],
    );
  }

  List<CheckInApplication> _filterAndSortApplications(
      List<CheckInApplication> applications) {
    return applications.where((app) {
      final fullName =
          '${app.student!.studentFirstName} ${app.student!.studentLastName}'
              .toLowerCase();
      if (_searchQuery.isNotEmpty &&
          !fullName.contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_selectedStatusFilter != 'All' &&
          app.checkInStatus != _selectedStatusFilter) return false;
      if (_selectedRoomTypeFilter != 'All' &&
          app.roomType != _selectedRoomTypeFilter) return false;
      if (_selectedPaidFilter != 'All') {
        if (_selectedPaidFilter == 'Yes' && !app.isPaid!) return false;
        if (_selectedPaidFilter == 'No' && app.isPaid!) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => _selectedDateFilter == 'Oldest'
          ? a.checkInApplicationDate.compareTo(b.checkInApplicationDate)
          : b.checkInApplicationDate.compareTo(a.checkInApplicationDate));
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green.shade400;
      case 'Rejected':
        return Colors.red.shade400;
      default:
        return Colors.orange.shade400;
    }
  }

  Widget _buildErrorWidget(Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading applications: $error',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
