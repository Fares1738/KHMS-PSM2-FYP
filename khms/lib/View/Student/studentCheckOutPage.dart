// ignore_for_file: use_build_context_synchronously, file_names

import 'package:flutter/material.dart';
import 'package:khms/Controller/checkOutController.dart';
import 'package:khms/View/Custom_Widgets/appBar.dart';
import 'package:khms/View/Student/studentHomePage.dart';

class CheckOutPage extends StatefulWidget {
  const CheckOutPage({super.key});

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _controller = CheckOutController();

  void _showDatePicker() async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (newDate != null) {
      setState(() {
        _selectedDate = newDate;
      });
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
      const startTime = TimeOfDay(hour: 9, minute: 00);
      const endTime = TimeOfDay(hour: 16, minute: 30);

      if ((newTime.hour >= startTime.hour &&
              newTime.minute >= startTime.minute) &&
          (newTime.hour <= endTime.hour && newTime.minute <= endTime.minute)) {
        setState(() {
          _selectedTime = newTime;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please select a time between 9AM and 4:30PM"),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Check Out",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              _buildDropdown("Check Out Date:", _selectedDate, _showDatePicker),
              const SizedBox(height: 10),
              _buildDropdown("Check Out Time:", _selectedTime, _showTimePicker),
              const SizedBox(height: 20),
              const Text(
                'Note: Please ensure the room is clean before checking out',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final isSubmitted =
                      await _controller.submitCheckOutApplication(
                          context, _selectedDate, _selectedTime);

                  if (isSubmitted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Check-Out Application Submitted!")));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StudentHomePage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Please fill in all fields!")));
                  }
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, dynamic selectedValue, Function onTap) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () => onTap(),
          child: Text(selectedValue == null
              ? "Select"
              : (selectedValue is DateTime
                  ? "${selectedValue.day}/${selectedValue.month}/${selectedValue.year}"
                  : "${selectedValue.hour}:${selectedValue.minute}")),
        ),
      ],
    );
  }
}
