import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khms/Controller/facilitiesController.dart';
import 'package:khms/Controller/userController.dart';
import 'package:khms/Model/Facilities.dart';
import 'package:khms/Model/Student.dart';
import 'package:khms/View/Student/stripePaymentPage.dart';

class FacilitiesPage extends StatefulWidget {
  final Student? student;
  const FacilitiesPage({Key? key, this.student}) : super(key: key);

  @override
  _FacilitiesPageState createState() => _FacilitiesPageState();
}

class _FacilitiesPageState extends State<FacilitiesPage> {
  final FacilitiesController _controller = FacilitiesController();
  final UserController _userController = UserController();
  String studentId = '';
  bool? facilitySubscription;
  Stream<List<String>>? _bookedTimeSlotsStream;
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

  @override
  void initState() {
    super.initState();
    _fetchFacilityAvailability();
    _fetchFacilityTypes();
    _fetchData();
    setState(() {
      facilitySubscription = widget.student?.facilitySubscription;
      studentId = _userController.student?.studentId ?? '';
    });
  }

  Future<void> _fetchData() async {
    try {
      await _userController.fetchUserData();
      setState(() {
        facilitySubscription = _userController.student?.facilitySubscription;
        studentId = _userController.student?.studentId ?? '';
      });
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

  void _updateBookedTimeSlotsStream() {
    if (_selectedDate != null && _selectedFacilityType != null) {
      setState(() {
        _bookedTimeSlotsStream = _controller.streamBookedTimeSlots(
            _selectedDate, _selectedFacilityType);
      });
    }
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
                            _selectedTimeSlot = null;
                          });
                          _updateBookedTimeSlotsStream();
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
                      onChanged: (value) {
                        if (value != null &&
                            (_facilityAvailability[value] ?? false)) {
                          setState(() {
                            _selectedFacilityType = value;
                            _selectedTimeSlot = null;
                          });
                          _updateBookedTimeSlotsStream();
                        }
                      },
                      decoration: const InputDecoration(
                          labelText: 'Select Facility Type',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<List<String>>(
                      stream: _bookedTimeSlotsStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        final bookedTimeSlots = snapshot.data ?? [];
                        return DropdownButtonFormField<String>(
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
                              ? (value) =>
                                  setState(() => _selectedTimeSlot = value)
                              : null,
                          decoration: const InputDecoration(
                              labelText: 'Select Time Slot',
                              border: OutlineInputBorder()),
                        );
                      },
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
                                    studentRoomNo: _userController
                                            .student?.studentRoomNo ??
                                        '',
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
                      'You must pay 50 RM/month to access facilities.',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StripePaymentPage(
                              priceToDisplay: 50,
                              studentId: studentId,
                            ),
                          ),
                        );

                        if (result == true) {
                          _fetchData();
                        }
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
