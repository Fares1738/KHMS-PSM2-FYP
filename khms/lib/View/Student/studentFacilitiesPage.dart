import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khms/Controller/facilitiesController.dart';
import 'package:khms/Controller/userController.dart';
import 'package:khms/Model/Facilities.dart';
import 'package:khms/Model/Student.dart';
import 'package:khms/View/Student/stripePaymentPage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookFacilitiesPage extends StatefulWidget {
  final Student? student;
  const BookFacilitiesPage({super.key, this.student});

  @override
  _BookFacilitiesPageState createState() => _BookFacilitiesPageState();
}

class _BookFacilitiesPageState extends State<BookFacilitiesPage> {
  final FacilitiesController _controller = FacilitiesController();
  final UserController _userController = UserController();

  String studentId = '';
  bool? facilitySubscription;
  bool hasRoomNumber = false;
  Stream<List<String>>? _bookedTimeSlotsStream;
  Stream<List<Facilities>>? _userBookedFacilitiesStream;

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

  List<String> _getAvailableTimeSlots() {
    final now = DateTime.now();
    final currentTime =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);

    return _timeSlots.where((slot) {
      final slotStartTime = DateFormat('hh:mm a').parse(slot.split(' - ')[0]);
      final slotDateTime = DateTime(
        _selectedDate?.year ?? now.year,
        _selectedDate?.month ?? now.month,
        _selectedDate?.day ?? now.day,
        slotStartTime.hour,
        slotStartTime.minute,
      );
      return slotDateTime.isAfter(currentTime);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchStudentData(),
      _fetchFacilityAvailability(),
      _fetchFacilityTypes(),
    ]);
    _initializeUserBookedFacilitiesStream();
  }

  void _initializeUserBookedFacilitiesStream() {
    if (studentId.isNotEmpty) {
      _userBookedFacilitiesStream =
          _controller.streamStudentFacilityApplications(studentId);
    }
  }

  Future<void> _fetchStudentData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString('userId') as String;
      this.studentId = studentId;

      final studentDoc = await FirebaseFirestore.instance
          .collection('Students')
          .doc(studentId)
          .get();

      if (mounted) {
        setState(() {
          hasRoomNumber = studentDoc.exists &&
              studentDoc.data()!.containsKey('studentRoomNo') &&
              studentDoc['studentRoomNo'] != null &&
              studentDoc['studentRoomNo'] != "";
          facilitySubscription = studentDoc['facilitySubscription'] ?? false;
          this.studentId = studentId;
        });
      }
    } catch (e) {
      print('Error fetching student data: $e');
    }
  }

  Future<void> _fetchFacilityAvailability() async {
    final availability = await _controller.fetchFacilityAvailability();
    if (mounted) {
      setState(() {
        _facilityAvailability = availability;
      });
    }
  }

  Future<void> _fetchFacilityTypes() async {
    try {
      final facilitiesSnapshot =
          await FirebaseFirestore.instance.collection('Facilities').get();
      if (mounted) {
        setState(() {
          _facilityTypes =
              facilitiesSnapshot.docs.map((doc) => doc.id).toList();
        });
      }
    } catch (e) {
      print('Error fetching facility types: $e');
      _showErrorSnackBar('Error fetching facility types!');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _selectedDate = null;
      _selectedTimeSlot = null;
      _selectedFacilityType = null;
    });
    await _fetchData();
  }

  void _updateBookedTimeSlotsStream() {
    if (_selectedDate != null && _selectedFacilityType != null) {
      setState(() {
        _bookedTimeSlotsStream = _controller.streamBookedTimeSlots(
            _selectedDate, _selectedFacilityType);
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facility Booking'),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: hasRoomNumber
                ? (facilitySubscription == true
                    ? _buildBookingContent()
                    : _buildSubscriptionPrompt())
                : _buildNotCheckedInContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBookingForm(),
          const SizedBox(height: 24),
          _buildUserBookedFacilitiesList(),
        ],
      ),
    );
  }

  Widget _buildNotCheckedInContent() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Check-In Required',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your check-in application must be approved before you can access this page.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDatePicker(),
        const SizedBox(height: 16),
        _buildFacilityTypeDropdown(),
        const SizedBox(height: 16),
        _buildTimeSlotDropdown(),
        const SizedBox(height: 24),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDate != null
                    ? DateFormat('MMMM d, yyyy').format(_selectedDate!)
                    : 'Select Date',
                style: const TextStyle(fontSize: 16),
              ),
              const Icon(Icons.calendar_today),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacilityTypeDropdown() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonFormField<String>(
          value: _selectedFacilityType,
          items: _facilityTypes.map((type) {
            final isEnabled = _facilityAvailability[type] ?? false;
            return DropdownMenuItem<String>(
              value: type,
              enabled: isEnabled,
              child: Text(
                type,
                style: TextStyle(color: isEnabled ? null : Colors.grey),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null && (_facilityAvailability[value] ?? false)) {
              setState(() {
                _selectedFacilityType = value;
                _selectedTimeSlot = null;
              });
              _updateBookedTimeSlotsStream();
            }
          },
          decoration: const InputDecoration(
            labelText: 'Select Facility Type',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildUserBookedFacilitiesList() {
    return StreamBuilder<List<Facilities>>(
      stream: _userBookedFacilitiesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final facilities = snapshot.data ?? [];

        facilities.sort((a, b) =>
            b.facilityApplicationDate.compareTo(a.facilityApplicationDate));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Booked Facilities',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            facilities.isEmpty
                ? const Text('No facilities booked yet.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: facilities.length,
                    itemBuilder: (context, index) {
                      final facility = facilities[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      facility.facilityType,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(facility
                                              .facilityApplicationStatus)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      facility.facilityApplicationStatus,
                                      style: TextStyle(
                                        color: _getStatusColor(
                                            facility.facilityApplicationStatus),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      DateFormat('MMM d, yyyy').format(
                                          facility.facilityApplicationDate),
                                      style: TextStyle(color: Colors.grey[600]),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      facility.facilitySlot!,
                                      style: TextStyle(color: Colors.grey[600]),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (facility.facilityRejectedReason != null &&
                                  facility
                                      .facilityRejectedReason!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Rejection Reason: ${facility.facilityRejectedReason}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildTimeSlotDropdown() {
    return StreamBuilder<List<String>>(
      stream: _bookedTimeSlotsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final bookedTimeSlots = snapshot.data ?? [];
        final availableTimeSlots = _getAvailableTimeSlots();

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: _selectedTimeSlot,
              items: availableTimeSlots.map((slot) {
                final isBooked = bookedTimeSlots.contains(slot);
                return DropdownMenuItem<String>(
                  value: slot,
                  enabled: !isBooked,
                  child: Text(
                    slot,
                    style: TextStyle(color: isBooked ? Colors.grey : null),
                  ),
                );
              }).toList(),
              onChanged: _selectedDate != null && _selectedFacilityType != null
                  ? (value) => setState(() => _selectedTimeSlot = value)
                  : null,
              decoration: const InputDecoration(
                labelText: 'Select Time Slot',
                border: InputBorder.none,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _canSubmit() ? _submitBooking : null,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('Submit Booking', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  bool _canSubmit() {
    return _selectedDate != null &&
        _selectedTimeSlot != null &&
        _selectedFacilityType != null &&
        (_facilityAvailability[_selectedFacilityType!] ?? false);
  }

  Future<void> _submitBooking() async {
    try {
      await _controller.submitFacilityBooking(
        context,
        Facilities(
          facilityApplicationId: '',
          facilityApplicationDate: _selectedDate!,
          facilitySlot: _selectedTimeSlot!,
          facilityType: _selectedFacilityType!,
          studentId: studentId,
          studentRoomNo: _userController.student?.studentRoomNo ?? '',
          facilityApplicationStatus: 'Pending',
        ),
      );
      _showSuccessDialog();
    } catch (e) {
      print('Error: $e');
      _showErrorSnackBar('Error submitting booking');
    }
  }

  void _showSuccessDialog() {
    if (!mounted) return; // Check if the widget is still mounted

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Booking Successful'),
          content: const Text(
              'Your facility booking has been submitted successfully.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (mounted) {
                  // Check again before calling setState
                  setState(() {
                    _selectedDate = null;
                    _selectedTimeSlot = null;
                    _selectedFacilityType = null;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubscriptionPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_tennis, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Facility Access Required',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'You need to pay 50 RM/month to access facilities.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _navigateToPayment(),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text('Subscribe Now', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPayment() async {
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
  }
}
