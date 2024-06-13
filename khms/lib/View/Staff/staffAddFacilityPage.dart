// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:khms/Controller/facilitiesController.dart';
import 'package:khms/View/Staff/staffManageFacilities.dart';

class AddFacilityPage extends StatefulWidget {
  const AddFacilityPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AddFacilityPageState();
  }
}

class _AddFacilityPageState extends State<AddFacilityPage> {
  final FacilitiesController _controller = FacilitiesController();
  final TextEditingController _facilityTypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Facility'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              // New text field for facility name
              controller: _facilityTypeController,
              decoration: const InputDecoration(labelText: 'Facility Name'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _controller.addFacility(
                  _facilityTypeController.text, // Pass the type
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FacilityManagementPage()),
                ); //
              },
              child: const Text('Add Facility'),
            ),
          ],
        ),
      ),
    );
  }
}
