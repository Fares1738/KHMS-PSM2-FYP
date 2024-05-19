// ignore_for_file: library_private_types_in_public_api, file_names, use_build_context_synchronously, avoid_print

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
  String? _selectedTimeSlot, _selectedFacilityType;

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
  final _facilityTypes = [
    'Futsal Court',
    'BBQ',
    'Pool Table',
    'Ping-pong Table'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text("Facility Booking Form",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () async =>
                setState(() async => _selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3)),
                    )),
            child:
                Text(_selectedDate?.toString().split(' ')[0] ?? 'Select Date'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField(
            value: _selectedFacilityType,
            items: _facilityTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) async {
              setState(() => _selectedFacilityType = value);
              if (_selectedDate != null) {
                bookedTimeSlots = await _controller.fetchBookedTimeSlots(
                    _selectedDate!, _selectedFacilityType!);
              }
            },
            decoration: const InputDecoration(
                labelText: 'Select Facility Type',
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField(
            value: _selectedTimeSlot,
            items: _timeSlots
                .map((slot) => DropdownMenuItem(
                    value: slot,
                    child: Text(slot,
                        style: TextStyle(
                            color: bookedTimeSlots.contains(slot)
                                ? Colors.grey
                                : null))))
                .toList(),
            onChanged: _selectedDate != null && _selectedFacilityType != null
                ? (value) =>
                    setState(() => _selectedTimeSlot = value as String?)
                : null,
            decoration: const InputDecoration(
                labelText: 'Select Time Slot', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              try {
                await _controller.submitFacilityBooking(
                    context,
                    Facilities(
                      facilityApplicationId: '',
                      facilityApplicationDate: _selectedDate!,
                      facilitySlot: _selectedTimeSlot!,
                      facilityType: _selectedFacilityType!,
                      facilityAvailability: true,
                      studentId: '',
                      studentRoomNo: '',
                    ));
              } catch (e) {
                print(
                    'Error: $e'); // Consider handling errors better in a production app
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error submitting booking')));
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
