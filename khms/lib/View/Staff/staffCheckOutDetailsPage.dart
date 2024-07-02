import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khms/Controller/CheckOutController.dart';
import 'package:khms/Model/CheckOutApplication.dart';

class CheckOutDetailsPage extends StatefulWidget {
  final CheckOutApplication application;

  const CheckOutDetailsPage({Key? key, required this.application})
      : super(key: key);

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
        title: const Text("Check-Out Details"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${widget.application.student?.studentFirstName} ${widget.application.student?.studentLastName}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Check-Out Date: ${DateFormat('dd MMM yyyy').format(widget.application.checkOutDate)}",
            style: const TextStyle(
                fontSize: 16, color: Color.fromARGB(179, 0, 0, 0)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 20),
          _buildTimeSection(),
          const SizedBox(height: 20),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final application = widget.application;
    Color statusColor = application.checkOutStatus == "Completed"
        ? Colors.green
        : application.checkOutStatus == "In Progress"
            ? Colors.blue
            : Colors.orange;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              application.checkOutStatus == "Completed"
                  ? Icons.check_circle
                  : Icons.pending_actions,
              color: statusColor,
              size: 40,
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Status",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  application.checkOutStatus,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Check-Out Time",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (widget.application.checkOutStatus == 'Pending')
              _buildTimePicker()
            else
              _buildTimeDisplay(widget.application.checkOutTime!),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return ElevatedButton.icon(
      onPressed: _showTimePicker,
      icon: const Icon(Icons.access_time),
      label: Text(_selectedTime == null
          ? "Select Time"
          : formatDateTime(_selectedTime!)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildTimeDisplay(DateTime time) {
    return Text(
      formatDateTime(time),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildButtons() {
    final application = widget.application;
    if (application.checkOutStatus != 'Completed') {
      return Column(
        children: [
          if (application.checkOutStatus != 'In Progress')
            ElevatedButton(
              onPressed: () async {
                await _controller.updateCheckOutnApplicationStatus(
                  widget.application,
                  'In Progress',
                  _selectedTime,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Send Check-Out Notification"),
            ),
          if (application.checkOutStatus == 'In Progress')
            ElevatedButton(
              onPressed: () async {
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Check Out'),
                      content: const Text(
                          'Are you sure the student has completed check out? Completing check out will remove all student\'s data from the app.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context)
                                .pop(false); // User cancelled the dialog
                          },
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pop(true); // User confirmed the dialog
                          },
                          child: const Text('Confirm'),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  await _controller.updateCheckOutnApplicationStatus(
                    widget.application,
                    'Completed',
                    application.checkOutTime,
                  );
                  await _controller.updateRoomAvailability(
                      widget.application.student!.studentRoomNo, true);
                  await _controller.deleteUserDocuments(
                      widget.application.student!.studentId!);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                foregroundColor: Colors.red,
              ),
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
    final format = DateFormat('hh:mm a');
    return format.format(dateTime);
  }
}
