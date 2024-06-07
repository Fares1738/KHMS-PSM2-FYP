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
  Map<String, bool> _facilityAvailability = {};
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
    'Futsal',
    'BBQ',
    'Pool Table',
    'Ping Pong Table',
    'Gym'
  ];

  @override
  void initState() {
    super.initState();
    _fetchFacilityAvailability();
  }

  Future<void> _fetchFacilityAvailability() async {
    final availability = await _controller.fetchFacilityAvailability();
    setState(() {
      _facilityAvailability = availability;
    });
  }

  Future<void> _refreshData() async {
    await _fetchFacilityAvailability(); // Fetch updated availability
    if (_selectedDate != null && _selectedFacilityType != null) {
      bookedTimeSlots = await _controller.fetchBookedTimeSlots(
          _selectedDate!, _selectedFacilityType!); // Refresh booked slots
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text("Facility Booking Form",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
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
                    _selectedDate?.toString().split(' ')[0] ?? 'Select Date'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedFacilityType,
                items: _facilityTypes.map((type) {
                  final isEnabled = _facilityAvailability[type] ?? false;
                  return DropdownMenuItem<String>(
                    value: type,
                    enabled:
                        isEnabled, // Disable the item if the facility is not available
                    child: Text(
                      type,
                      style: TextStyle(
                        color: isEnabled
                            ? null
                            : Colors.grey, // Show disabled items in grey
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) async {
                  if (value != null &&
                      (_facilityAvailability[value] ?? false)) {
                    setState(() => _selectedFacilityType = value);
                    if (_selectedDate != null) {
                      bookedTimeSlots = await _controller.fetchBookedTimeSlots(
                          _selectedDate!, _selectedFacilityType!);
                    }
                  }
                },
                decoration: const InputDecoration(
                    labelText: 'Select Facility Type',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTimeSlot,
                items: _timeSlots.map((slot) {
                  final isBooked = bookedTimeSlots.contains(slot);
                  return DropdownMenuItem<String>(
                    value: slot,
                    enabled:
                        !isBooked, // Disable the item if the slot is already booked
                    child: Text(
                      slot,
                      style: TextStyle(
                        color: isBooked
                            ? Colors.grey
                            : null, // Show booked slots in grey
                      ),
                    ),
                  );
                }).toList(),
                onChanged:
                    _selectedDate != null && _selectedFacilityType != null
                        ? (value) => setState(() => _selectedTimeSlot = value)
                        : null,
                decoration: const InputDecoration(
                    labelText: 'Select Time Slot',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selectedDate != null &&
                        _selectedTimeSlot != null &&
                        _selectedFacilityType != null &&
                        (_facilityAvailability[_selectedFacilityType!] ?? false)
                    ? () async {
                        try {
                          await _controller.submitFacilityBooking(
                            context,
                            Facilities(
                              facilityApplicationId: '',
                              facilityApplicationDate: _selectedDate!,
                              facilitySlot: _selectedTimeSlot!,
                              facilityType: _selectedFacilityType!,
                              studentId: '',
                              studentRoomNo: '',
                              facilityApplicationStatus: 'Pending',
                            ),
                          );
                        } catch (e) {
                          print('Error: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Error submitting booking')),
                          );
                        }
                      }
                    : null,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
