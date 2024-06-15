// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khms/Controller/facilitiesController.dart';
import 'package:khms/Controller/userController.dart';
import 'package:khms/Model/Facilities.dart';
import 'package:khms/Model/Student.dart';

class FacilitiesPage extends StatefulWidget {
  final Student? student;
  const FacilitiesPage({super.key, this.student});

  @override
  _FacilitiesPageState createState() => _FacilitiesPageState();
}

class _FacilitiesPageState extends State<FacilitiesPage> {
  final FacilitiesController _controller = FacilitiesController();
  final UserController _userController = UserController();
  bool? facilitySubscription;
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

  List<String> _facilityTypes = [];

  Future<void> _fetchFacilityTypes() async {
    try {
      final facilitiesSnapshot =
          await FirebaseFirestore.instance.collection('Facilities').get();
      setState(() {
        _facilityTypes = facilitiesSnapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      print('Error fetching facility types: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFacilityAvailability();
    _fetchFacilityTypes();
    _fetchData();
    setState(() {
      facilitySubscription = widget.student?.facilitySubscription;
    });
  }

  Future<void> _fetchData() async {
    try {
      await _userController.fetchUserData();
      setState(() {
        facilitySubscription = _userController.student?.facilitySubscription;
      });
      print(
          'Facility Subscription: ${_userController.student?.facilitySubscription}');
    } catch (e) {
      print('Error fetching student data: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching student data!')),
      );
    }
  }

  Future<void> _fetchFacilityAvailability() async {
    final availability = await _controller.fetchFacilityAvailability();
    setState(() {
      _facilityAvailability = availability;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: facilitySubscription == true
            ? SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    const Text("Facility Booking Form",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
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
                      child: Text(_selectedDate?.toString().split(' ')[0] ??
                          'Select Date'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedFacilityType,
                      items: _facilityTypes.map((type) {
                        final isEnabled = _facilityAvailability[type] ?? false;
                        return DropdownMenuItem<String>(
                          value: type,
                          enabled: isEnabled,
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isEnabled ? null : Colors.grey,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        if (value != null &&
                            (_facilityAvailability[value] ?? false)) {
                          setState(() => _selectedFacilityType = value);
                          if (_selectedDate != null) {
                            bookedTimeSlots =
                                await _controller.fetchBookedTimeSlots(
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
                          enabled: !isBooked,
                          child: Text(
                            slot,
                            style: TextStyle(
                              color: isBooked ? Colors.grey : null,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: _selectedDate != null &&
                              _selectedFacilityType != null
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
                              (_facilityAvailability[_selectedFacilityType!] ??
                                  false)
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
                                      content:
                                          Text('Error submitting booking')),
                                );
                              }
                            }
                          : null,
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'You must pay for facilities to access this page',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to your payment screen
                        // ... Your navigation logic here ...
                      },
                      child: const Text('Go to Payment'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
