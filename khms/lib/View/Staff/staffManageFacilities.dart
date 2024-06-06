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
  List<Facilities> _facilityApplications = [];
  Map<String, bool> _facilityAvailability = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final facilities = await _controller.fetchFacilityApplications();
    final availability = await _controller.fetchFacilityAvailability();
    setState(() {
      _facilityApplications = facilities;
      _facilityAvailability = availability;
    });
  }

  void _approveApplication(String applicationId, String facilityType) {
    _controller.updateFacilityApplicationStatus(
        applicationId, 'approved', facilityType);
    _fetchData();
  }

  void _rejectApplication(String applicationId, String facilityType) {
    _controller.updateFacilityApplicationStatus(
        applicationId, 'rejected', facilityType);
    _fetchData();
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
      ),
      body: ListView(
        children: [
          ..._facilityAvailability.entries.map((entry) {
            return SwitchListTile(
              title: Text('${entry.key} (Enable/Disable)'),
              value: entry.value,
              onChanged: (bool value) {
                _toggleFacility(entry.key, value);
              },
            );
          }),
          ..._facilityApplications.map((facility) {
            return Card(
              child: ExpansionTile(
                title:
                    Text('${facility.facilityType} - ${facility.facilitySlot}'),
                children: [
                  ListTile(
                    title: Text('Student ID: ${facility.studentId}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Facility Type: ${facility.facilityType}'),
                        Text('Slot: ${facility.facilitySlot}'),
                        Text('Date: ${facility.facilityApplicationDate}'),
                      ],
                    ),
                  ),
                  ButtonBar(
                    children: [
                      ElevatedButton(
                        onPressed: () => _approveApplication(
                            facility.facilityApplicationId,
                            facility.facilityType),
                        child: const Text('Approve'),
                      ),
                      ElevatedButton(
                        onPressed: () => _rejectApplication(
                            facility.facilityApplicationId,
                            facility.facilityType),
                        child: const Text('Reject'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
