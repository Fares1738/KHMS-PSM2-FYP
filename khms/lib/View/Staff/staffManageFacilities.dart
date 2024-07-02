import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khms/Controller/facilitiesController.dart';
import 'package:khms/Model/Facilities.dart';
import 'package:khms/View/Staff/staffAddFacilityPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FacilityManagementPage extends StatefulWidget {
  const FacilityManagementPage({super.key});

  @override
  _FacilityManagementPageState createState() => _FacilityManagementPageState();
}

class _FacilityManagementPageState extends State<FacilityManagementPage> {
  final FacilitiesController _controller = FacilitiesController();
  Map<String, bool> _facilityAvailability = {};
  String sortByDate = 'Newest';
  String sortByStatus = 'All';
  String? userType;

  @override
  void initState() {
    super.initState();
    _fetchAvailability();
  }

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
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Future<void> _fetchAvailability() async {
    final availability = await _controller.fetchFacilityAvailability();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userType = prefs.getString('userType');
    setState(() {
      _facilityAvailability = availability;
    });
  }

  void _approveApplication(String applicationId, String facilityType) {
    _controller.updateFacilityApplicationStatus(
        applicationId, 'Approved', facilityType);
    _fetchAvailability();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking Approved')),
    );
  }

  void _rejectApplication(String applicationId, String facilityType) {
    _controller.updateFacilityApplicationStatus(
        applicationId, 'Rejected', facilityType);
    _fetchAvailability();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Application Rejected')),
    );
  }

  void _toggleFacility(String facilityType, bool isEnabled) {
    _controller.toggleFacilityAvailability(facilityType, isEnabled);
    setState(() {
      _facilityAvailability[facilityType] = isEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facility Management'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: ListView(
        children: [
          _buildFilterSection(),
          if (userType == 'Manager') _buildAddFacilityButton(),
          _buildFacilityToggleList(),
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
      child: Row(
        children: [
          Expanded(
            child: _buildFilterDropdown(
              "Sort By Date",
              sortByDate,
              ['Newest', 'Oldest'],
              (value) => setState(() => sortByDate = value!),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildFilterDropdown(
              "Status",
              sortByStatus,
              ['All', 'Pending', 'Approved', 'Rejected'],
              (value) => setState(() => sortByStatus = value!),
            ),
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

  Widget _buildAddFacilityButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddFacilityPage(),
              ),
            );
          },
          child: const Text('Add Facility'),
        ),
      ),
    );
  }

  Widget _buildFacilityToggleList() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: _facilityAvailability.entries.map((entry) {
          return SwitchListTile(
            title: Text('${entry.key} (Disable/Enable)'),
            value: entry.value,
            onChanged: (bool value) {
              _toggleFacility(entry.key, value);
            },
          );
        }).toList(),
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
          List<Facilities> sortedFacilities =
              _controller.sortFacilityApplicationsByDate(
            _controller.sortFacilityApplicationsByStatus(
                snapshot.data!, sortByStatus),
            sortByDate,
          );

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: sortedFacilities.length,
            itemBuilder: (context, index) {
              return _buildFacilityCard(sortedFacilities[index]);
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => _approveApplication(
                          facility.facilityApplicationId,
                          facility.facilityType),
                      child: const Text('Approve'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _rejectApplication(
                          facility.facilityApplicationId,
                          facility.facilityType),
                      child: const Text('Reject'),
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
