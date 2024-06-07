// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:khms/Controller/facilitiesController.dart';
import 'package:khms/Model/Facilities.dart';

class FacilityManagementPage extends StatefulWidget {
  const FacilityManagementPage({super.key});

  @override
  _FacilityManagementPageState createState() => _FacilityManagementPageState();
}

class _FacilityManagementPageState extends State<FacilityManagementPage> {
  final FacilitiesController _controller = FacilitiesController();
  Map<String, bool> _facilityAvailability = {};
  String sortByDate = 'Oldest';
  String sortByStatus = 'All';

  @override
  void initState() {
    super.initState();
    _fetchAvailability();
  }

  Widget _buildStatusIndicator(String status) {
    final color = _controller.getStatusColor(status);
    final iconData = _controller.getStatusIcon(status);

    return CircleAvatar(
      backgroundColor: color,
      radius: 12,
      child: Icon(
        iconData,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Future<void> _fetchAvailability() async {
    final availability = await _controller.fetchFacilityAvailability();
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

  Widget _buildExpansionTile(Facilities facility) {
    return Card(
      child: ExpansionTile(
        leading: _buildStatusIndicator(facility.facilityApplicationStatus),
        title: Text('${facility.facilityType} - ${facility.facilitySlot}'),
        children: [
          ListTile(
            title: Text(
                'Student Name: ${facility.student?.studentFirstName} ${facility.student?.studentLastName}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Slot: ${facility.facilitySlot}'),
                Text('Date: ${facility.facilityApplicationDate.day}/'
                    '${facility.facilityApplicationDate.month}/'
                    '${facility.facilityApplicationDate.year}'),
                Text('Room No: ${facility.student?.studentRoomNo}'),
              ],
            ),
          ),
          ButtonBar(
            children: [
              ElevatedButton(
                onPressed: () => _approveApplication(
                    facility.facilityApplicationId, facility.facilityType),
                child: const Text('Approve'),
              ),
              ElevatedButton(
                onPressed: () => _rejectApplication(
                    facility.facilityApplicationId, facility.facilityType),
                child: const Text('Reject'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facility Management'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Date: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                DropdownButton<String>(
                  value: sortByDate,
                  onChanged: (String? newValue) {
                    setState(() {
                      sortByDate = newValue!;
                    });
                  },
                  items: <String>['Newest', 'Oldest']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Status: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButton<String>(
                      value: sortByStatus,
                      onChanged: (String? newValue) {
                        setState(() {
                          sortByStatus = newValue!;
                        });
                      },
                      items: <String>['All', 'Pending', 'Approved', 'Rejected']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ..._facilityAvailability.entries.map((entry) {
                  return SwitchListTile(
                    title: Text('${entry.key} (Disable/Enable)'),
                    value: entry.value,
                    onChanged: (bool value) {
                      _toggleFacility(entry.key, value);
                    },
                  );
                }),
                StreamBuilder<List<Facilities>>(
                  stream: _controller.fetchFacilityApplicationsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No facilities available'));
                    } else {
                      // Sort data in the build method to update dynamically
                      List<Facilities> sortedFacilities =
                          _controller.sortFacilityApplicationsByDate(
                        _controller.sortFacilityApplicationsByStatus(
                            snapshot.data!, sortByStatus),
                        sortByDate,
                      );

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: sortedFacilities.length,
                        itemBuilder: (context, index) {
                          return _buildExpansionTile(sortedFacilities[index]);
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
