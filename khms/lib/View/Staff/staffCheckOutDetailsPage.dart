// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khms/Controller/CheckOutController.dart';
import 'package:khms/Model/CheckOutApplication.dart';

class CheckOutDetailsPage extends StatefulWidget {
  final CheckOutApplication application;

  const CheckOutDetailsPage({super.key, required this.application});

  @override
  State<CheckOutDetailsPage> createState() => _CheckOutDetailsPageState();
}

class _CheckOutDetailsPageState extends State<CheckOutDetailsPage> {
  final CheckOutController _controller = CheckOutController();
  DateTime? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check-Out Application Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStudentDetails(),
            if (widget.application.checkOutStatus == 'Pending')
              _buildDropdown("Check Out Time:", _selectedTime, _showTimePicker),
            if (widget.application.checkOutStatus != 'Pending')
              _buildTimeDisplay(widget.application.checkOutTime!),
            const SizedBox(height: 20),
            _buildStatusSection(),
            _buildButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDetails() {
    final student = widget.application.student;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Student Details:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(
            "Student Name: ${student?.studentFirstName} ${student?.studentLastName}"),
        Text(
            "Check-Out Date: ${DateFormat('dd MMM yyyy').format(widget.application.checkOutDate)}"),
        //Text("Room: ${widget.application.student?.studentRoomNo}"),
      ],
    );
  }

  Widget _buildTimeDisplay(DateTime time) {
    return Row(
      children: [
        const Text("Check Out Time: "),
        Text(formatDateTime(time)), // Display the time
      ],
    );
  }

  Widget _buildStatusSection() {
    final application = widget.application;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Check-Out Status: ${application.checkOutStatus}",
          style: TextStyle(
            color: application.checkOutStatus == "Completed"
                ? Colors.green
                : Colors.orange,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildButtons() {
    final application = widget.application;
    if (application.checkOutStatus != 'Completed') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 10),
          if (application.checkOutStatus !=
              'In Progress') // Hide if "In Progress" or "Completed"
            FilledButton(
              onPressed: () async {
                await _controller.updateCheckOutnApplicationStatus(
                  widget.application,
                  'In Progress',
                  _selectedTime, 
                );
                Navigator.pop(context);
              },
              child: const Text("Send Check-Out Notification to Student"),
            ),
          if (application.checkOutStatus ==
              'In Progress') // Show only if "In Progress"
            FilledButton(
              onPressed: () async {
                await _controller.updateCheckOutnApplicationStatus(
                  widget.application,
                  'Completed',
                  application.checkOutTime, // Pass the existing checkOutTime
                );
                // Update room availability
                await _controller.updateRoomAvailability(
                    widget.application.student!.studentRoomNo, true);
                Navigator.pop(context);
              },
              child: const Text("Complete Check Out"),
            ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void _showTimePicker() async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, childWidget) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: childWidget!,
        );
      },
    );

    if (newTime != null) {
      final now = DateTime.now();
      final selectedDateTime =
          DateTime(now.year, now.month, now.day, newTime.hour, newTime.minute);

      const startTime = TimeOfDay(hour: 9, minute: 00);
      const endTime = TimeOfDay(hour: 16, minute: 30);

      int selectedMinutes = newTime.hour * 60 + newTime.minute;
      int startMinutes = startTime.hour * 60 + startTime.minute;
      int endMinutes = endTime.hour * 60 + endTime.minute;

      if (selectedMinutes >= startMinutes && selectedMinutes <= endMinutes) {
        setState(() {
          _selectedTime = selectedDateTime;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please select a time between 9AM and 4:30PM"),
        ));
      }
    }
  }

  String formatDateTime(DateTime dateTime) {
    final format = DateFormat(
        'hh:mm a'); // 'yyyy-MM-dd' for date and 'hh:mm a' for 12-hour format with AM/PM
    return format.format(dateTime);
  }

  Widget _buildDropdown(String label, dynamic selectedValue, Function onTap) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () => onTap(),
          child: Text(
              selectedValue == null ? "Select" : formatDateTime(selectedValue)),
        ),
      ],
    );
  }
}
