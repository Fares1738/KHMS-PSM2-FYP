// ignore_for_file: use_build_context_synchronously, file_names

import 'package:flutter/material.dart';
import 'package:khms/Controller/checkOutController.dart';
import 'package:khms/View/Custom_Widgets/appBar.dart';

class CheckOutPage extends StatefulWidget {
  const CheckOutPage({super.key});

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  DateTime? _selectedDate;
  final _controller = CheckOutController();

  void _showDatePicker() async {
    final today = DateTime.now();
    final firstDate = today.add(const Duration(days: 30));
    final lastDate = today.add(const Duration(days: 365));

    bool isSelectableDay(DateTime date) {
      return date.isAfter(firstDate.subtract(const Duration(days: 1))) &&
          date.isBefore(lastDate.add(const Duration(days: 1))) &&
          date.weekday != DateTime.saturday;
    }

    final newDate = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: isSelectableDay,
      builder: (BuildContext context, Widget? child) {
        // Customize the appearance of each day in the calendar
        if (child is Text) {
          DateTime date = DateTime.parse(child.data!);
          bool isDisabled = date.weekday == DateTime.saturday;

          return Container(
            decoration: BoxDecoration(
              color: isDisabled
                  ? Colors.grey.withOpacity(0.4)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            alignment: Alignment.center,
            child: child,
          );
        }
        return child!;
      },
    );

    if (newDate != null) {
      setState(() {
        _selectedDate = newDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GeneralCustomAppBar(),
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
              const SizedBox(height: 20),
              _buildDropdown("Check Out Date:", _selectedDate, _showDatePicker),
              const SizedBox(height: 20),
              const Text(
                'Note: Please ensure the room is clean before checking out. A staff member will inspect the room before you leave.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  await _controller.submitCheckOutApplication(
                      context, _selectedDate);
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
