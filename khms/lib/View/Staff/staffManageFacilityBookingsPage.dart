// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khms/Controller/facilitiesController.dart';
import 'package:khms/Model/Facilities.dart';
import 'package:khms/View/Staff/staffManageFacilityPage.dart';

class FacilityBookingsPage extends StatefulWidget {
  final String? userType;
  const FacilityBookingsPage({super.key, this.userType});

  @override
  _FacilityBookingsPageState createState() => _FacilityBookingsPageState();
}

class _FacilityBookingsPageState extends State<FacilityBookingsPage> {
  final FacilitiesController _controller = FacilitiesController();
  String sortByDate = 'Newest';
  String sortByStatus = 'All';
  String selectedFacilityType = 'All'; // Track selected facility type
  List<Facilities> facilitiesList = [];

  Widget _buildStatusIndicator(String status) {
    Color color;
    switch (status) {
      case 'Approved':
        color = Colors.green.shade400;
        break;
      case 'Rejected':
        color = Colors.red.shade400;
        break;
      default:
        color = Colors.orange.shade400;
    }

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  void _approveApplication(String applicationId, String facilityType) {
    _controller.updateFacilityApplicationStatus(
        applicationId, 'Approved', facilityType, '');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking Approved')),
    );
  }

  void _rejectApplication(String applicationId, String facilityType,
      String facilityRejectedReason) {
    _controller.updateFacilityApplicationStatus(
        applicationId, 'Rejected', facilityType, facilityRejectedReason);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking Rejected')),
    );
  }

  void _showRejectDialog(String applicationId, String facilityType) {
    String facilityRejectedReason = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reject Booking'),
          content: TextField(
            onChanged: (value) {
              facilityRejectedReason = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter reason for rejection',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Reject'),
              onPressed: () {
                if (facilityRejectedReason.isNotEmpty) {
                  _rejectApplication(
                      applicationId, facilityType, facilityRejectedReason);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a reason for rejection')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String userType = widget.userType!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Facility Management'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: ListView(
        children: [
          _buildFilterSection(),
          if (userType == 'Manager') _buildManageFacilityButton(),
          _buildFacilityList(),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  "Status",
                  sortByStatus,
                  ['All', 'Pending', 'Approved', 'Rejected'],
                  (value) {
                    setState(() {
                      sortByStatus = value!;
                      // Reset selected facility type when status changes to 'All'
                      if (sortByStatus == 'All') {
                        selectedFacilityType = 'All';
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown(
                  "Sort By Date",
                  sortByDate,
                  ['Newest', 'Oldest'],
                  (value) => setState(() => sortByDate = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: _controller.fetchFacilitiesList(),
                  builder: (context, snapshot) {
                    final facilitiesList = snapshot.data ?? [];

                    // Extract unique facility types from facilitiesList
                    Set<String> facilityTypesSet = facilitiesList.toSet();
                    List<String> facilityTypes = facilityTypesSet.toList();
                    facilityTypes.insert(
                        0, 'All'); // Add 'All' option at the beginning

                    return _buildFilterDropdown(
                      "Facility Type",
                      selectedFacilityType,
                      facilityTypes,
                      (value) {
                        setState(() {
                          selectedFacilityType = value!;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          )
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
        const SizedBox(height: 4),
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

  Widget _buildManageFacilityButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageFacilitiesPage(),
              ),
            );
          },
          child: const Text('Manage Facilities'),
        ),
      ),
    );
  }

  Widget _buildFacilityList() {
    return StreamBuilder<List<Facilities>>(
      stream: _controller.fetchFacilityApplicationsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No facilities available'));
        } else {
          // Filter facilities based on selected status and facility type
          List<Facilities> filteredFacilities =
              snapshot.data!.where((facility) {
            if (sortByStatus != 'All' &&
                facility.facilityApplicationStatus != sortByStatus) {
              return false;
            }
            if (selectedFacilityType != 'All' &&
                facility.facilityType != selectedFacilityType) {
              return false;
            }
            return true;
          }).toList();

          // Sort filtered facilities by date
          filteredFacilities.sort((a, b) => sortByDate == 'Newest'
              ? b.facilityApplicationDate.compareTo(a.facilityApplicationDate)
              : a.facilityApplicationDate.compareTo(b.facilityApplicationDate));

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: filteredFacilities.length,
            itemBuilder: (context, index) {
              return _buildFacilityCard(filteredFacilities[index]);
            },
          );
        }
      },
    );
  }

  Widget _buildFacilityCard(Facilities facility) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: _buildStatusIndicator(facility.facilityApplicationStatus),
        title: Text(
          '${facility.facilityType} - ${facility.facilitySlot}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Name: ${facility.student?.studentFirstName} ${facility.student?.studentLastName}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Slot: ${facility.facilitySlot}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Date: ${DateFormat('dd MMM yyyy').format(facility.facilityApplicationDate)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Room No: ${facility.student?.studentRoomNo}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (facility.facilityRejectedReason != null &&
                    facility.facilityRejectedReason!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Rejection Reason: ${facility.facilityRejectedReason}',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showRejectDialog(
                          facility.facilityApplicationId,
                          facility.facilityType),
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _approveApplication(
                          facility.facilityApplicationId,
                          facility.facilityType),
                      child: const Text('Approve'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
