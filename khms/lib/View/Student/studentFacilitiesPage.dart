// ignore_for_file: library_private_types_in_public_api, unused_local_variable

import 'package:flutter/material.dart';
import 'package:khms/Controller/facilitiesController.dart';
import 'package:khms/Model/Facilities.dart';

class FacilitiesPage extends StatefulWidget {
  const FacilitiesPage({super.key});

  @override
  _FacilitiesPageState createState() => _FacilitiesPageState();
}

class _FacilitiesPageState extends State<FacilitiesPage> {
  final FacilitiesController _controller = FacilitiesController();

  DateTime? _selectedDate;
  String? _selectedTimeSlot;

  final List<String> _timeSlots = [
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '12:00 PM - 01:00 PM',
    '01:00 PM - 02:00 PM',
    '02:00 PM - 03:00 PM',
    '03:00 PM - 04:00 PM',
    '04:00 PM - 05:00 PM',
    '05:00 PM - 06:00 PM',
    '06:00 PM - 07:00 PM',
    '07:00 PM - 08:00 PM',
    '08:00 PM - 09:00 PM',
    '09:00 PM - 10:00 PM',
  ];

  String? _selectedFacilityType;

  final List<String> _facilityTypes = [
    'Futsal Court',
    'BBQ',
    'Pool Table',
    'Ping-pong Table'
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Facility Booking Form",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Date',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            OutlinedButton(
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3)),
                );
                if (selectedDate != null) {
                  setState(() {
                    _selectedDate = selectedDate;
                  });
                }
              },
              child: Text(
                _selectedDate != null
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'Select Date',
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Select Time Slot',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              value: _selectedTimeSlot,
              onChanged: (value) {
                setState(() {
                  _selectedTimeSlot = value;
                });
              },
              items: _timeSlots.map((slot) {
                return DropdownMenuItem<String>(
                  value: slot,
                  child: Text(slot),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Select Facility Type',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              value: _selectedFacilityType,
              onChanged: (value) {
                setState(() {
                  _selectedFacilityType = value;
                });
              },
              items: _facilityTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
// Inside your _FacilitiesPageState class...

            ElevatedButton(
              onPressed: () async {
                if (_selectedDate != null &&
                    _selectedTimeSlot != null &&
                    _selectedFacilityType != null) {
                  try {
                    final facilityData = Facilities(
                        facilityApplicationId: '', // Firebase will generate
                      facilityApplicationDate: _selectedDate!,
                      facilitySlot:
                          _selectedTimeSlot!, // Pass the selected time slot
                      facilityType: _selectedFacilityType!,
                      facilityAvailability: true,
                      studentId: '',
                      studentRoomNo: '',
                    );

                    final updatedFacilityData =
                        await _controller.submitFacilityBooking(facilityData);

                    // Success! Handle accordingly.
                  } catch (error) {
                    // ... Error Handling ...
                  }
                } else {
                  // ... Show error SnackBar ...
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
