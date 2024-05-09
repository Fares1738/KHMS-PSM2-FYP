// ignore_for_file: unused_local_variable, library_private_types_in_public_api, file_names

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
  List<String> bookedTimeSlots = [];

  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  String? _selectedFacilityType;

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

  final List<String> _facilityTypes = [
    'Futsal Court',
    'BBQ',
    'Pool Table',
    'Ping-pong Table'
  ];

  Widget _buildDropdownSection(
      String title, DropdownButtonFormField<String> dropdown) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8.0),
        GestureDetector(
          onTap: _selectedDate == null
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a date first.'),
                    ),
                  );
                }
              : null,
          child: Opacity(
            opacity: _selectedDate != null ? 1.0 : 0.5,
            child: AbsorbPointer(
              absorbing: _selectedDate == null,
              child: dropdown,
            ),
          ),
        ),
        if (_selectedDate == null)
          const SizedBox(
            height: 15,
            child: Text(
              'Please select a date first',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

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
                    _selectedTimeSlot = null;
                    _selectedFacilityType = null;
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
            _buildDropdownSection(
                'Select Facility Type',
                DropdownButtonFormField<String>(
                  value: _selectedFacilityType,
                  onChanged: (value) async {
                    setState(() {
                      _selectedFacilityType = value;
                      _selectedTimeSlot = null;
                    });

                    if (_selectedDate != null &&
                        _selectedFacilityType != null) {
                      bookedTimeSlots = await _controller.fetchBookedTimeSlots(
                          _selectedDate!, _selectedFacilityType!);
                      setState(() {});
                    }
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
                )),
            const SizedBox(height: 16.0),
            _buildDropdownSection(
                'Select Time Slot',
                DropdownButtonFormField<String>(
                  value: _selectedTimeSlot,
                  onChanged: (_selectedDate != null &&
                          _selectedFacilityType != null)
                      ? (value) async {
                          if (_selectedDate != null &&
                              _selectedFacilityType != null) {
                            bookedTimeSlots =
                                await _controller.fetchBookedTimeSlots(
                                    _selectedDate!, _selectedFacilityType!);
                            setState(() {});
                          } else {
                            setState(() {
                              value = null;
                            });
                          }
                        }
                      : null, // Disable 'onChanged' if date or facility type is not selected
                  items: _timeSlots.map((slot) {
                    return DropdownMenuItem<String>(
                      value: slot,
                      child: Opacity(
                        opacity: bookedTimeSlots.contains(slot) ? 0.5 : 1.0,
                        child: Text(slot),
                      ),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                )),
            const SizedBox(height: 16.0),
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

                    final updatedFacilityData = await _controller
                        .submitFacilityBooking(context, facilityData);

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
