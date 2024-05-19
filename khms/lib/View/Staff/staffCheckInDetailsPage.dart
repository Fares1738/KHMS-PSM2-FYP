// ignore_for_file: file_names, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:khms/Model/CheckInApplication.dart';
import 'package:intl/intl.dart';
import 'package:khms/Controller/checkInController.dart';
import 'package:khms/Model/Room.dart';

class CheckInDetailsPage extends StatefulWidget {
  final CheckInApplication application;

  const CheckInDetailsPage({super.key, required this.application});

  @override
  State<CheckInDetailsPage> createState() => _CheckInDetailsPageState();
}

class _CheckInDetailsPageState extends State<CheckInDetailsPage> {
  final CheckInController _controller = CheckInController();
  final TextEditingController _rejectionReasonController =
      TextEditingController();
  bool showRoomAssignment = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check-In Application Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStudentDetails(),
            const SizedBox(height: 30),
            _buildStatusSection(),
            _buildRejectionReasonSection(),
            if (showRoomAssignment) _buildRoomAssignmentSection(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomAssignmentSection() {
    String? selectedBlock;
    int? selectedFloor;
    Room? selectedRoom;

    return StatefulBuilder(builder: (context, StateSetter setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Assign Room:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // Block selection dropdown
          DropdownButtonFormField<String>(
            value: selectedBlock,
            hint: const Text('Select Block'),
            items: ['A', 'B']
                .map((block) =>
                    DropdownMenuItem(value: block, child: Text('Block $block')))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedBlock = value;
                selectedFloor = null; // Reset floor when block changes
                selectedRoom = null; // Reset room when block changes
              });
            },
            decoration: const InputDecoration(
                labelText: 'Block', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),

          // Floor selection dropdown (enabled only after block is selected)
          if (selectedBlock != null)
            DropdownButtonFormField<int>(
              value: selectedFloor,
              hint: const Text('Select Floor'),
              items: List.generate(8, (index) => index + 1)
                  .map((floor) => DropdownMenuItem(
                      value: floor, child: Text('Floor $floor')))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedFloor = value;
                  selectedRoom = null; // Reset room when floor changes
                });
              },
              decoration: const InputDecoration(
                  labelText: 'Floor', border: OutlineInputBorder()),
            ),
          const SizedBox(height: 10),

          // StreamBuilder to fetch and display rooms (enabled only after block and floor are selected)
          if (selectedBlock != null && selectedFloor != null)
            StreamBuilder<List<Room>>(
              stream: _controller.getAvailableRoomsStream(
                  widget.application.roomType!, selectedBlock!, selectedFloor!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final availableRooms = snapshot.data ?? [];

                  if (selectedRoom != null &&
                      !availableRooms.contains(selectedRoom)) {
                    selectedRoom = null;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<Room>(
                        value: selectedRoom,
                        onChanged: (room) {
                          setState(() {
                            selectedRoom = room;
                          });
                        },
                        items:
                            availableRooms.map<DropdownMenuItem<Room>>((room) {
                          final capacity = room.roomType == 'Double'
                              ? 2
                              : (room.roomType == 'Triple'
                                  ? 3
                                  : 0); // Determine capacity

                          return DropdownMenuItem<Room>(
                            value: room,
                            child: FutureBuilder<int>(
                              // Get tenant count only for double/triple rooms
                              future: room.roomType == 'Single'
                                  ? Future.value(0)
                                  : _controller
                                      .getAssignedTenantsCount(room.roomNo),
                              builder: (context, tenantCountSnapshot) {
                                if (tenantCountSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                      '${room.roomNo} (${room.roomType})'); // Loading
                                } else {
                                  final tenantCount =
                                      tenantCountSnapshot.data ?? 0;
                                  return Text(
                                    '${room.roomNo} (${room.roomType})${room.roomType == 'Single' ? '' : ' - $tenantCount/$capacity'}', // Conditionally add tenant count
                                  );
                                }
                              },
                            ),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Available Rooms',
                          border: const OutlineInputBorder(),
                          errorText: availableRooms.isEmpty
                              ? 'No rooms available on this floor'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Submit Button (only enabled when a room is selected)
                      if (selectedRoom != null)
                        FilledButton(
                          onPressed: () async {
                            try {
                              await _controller.updateCheckInApplication(
                                widget.application,
                                'Approved',
                                selectedRoom!.roomNo,
                                null,
                              );
                              // Optionally, navigate back or show a success message
                              Navigator.pop(context); // For example
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error assigning room: $e'),
                                ),
                              );
                            }
                          },
                          child: const Center(child: Text('Assign Room')),
                        ),
                    ],
                  );
                }
              },
            ),
        ],
      );
    });
  }

  Widget _buildStudentDetails() {
    final student = widget.application.student;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Student Details:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Text(
            "Student Name: ${student?.studentFirstName} ${student?.studentLastName}"),
        Text(
            "Application Date: ${DateFormat('dd MMM yyyy | hh:mm a').format(widget.application.checkInApplicationDate)}"),
        Text(
            "Check-In Date: ${DateFormat('dd MMM yyyy | hh:mm a').format(widget.application.checkInDate)}"),
        Text("Email: ${student?.studentEmail}"),
        Text("Phone: ${student?.studentPhoneNumber}"),
        Text("Nationality: ${student?.studentNationality}"),
        Text("IC Number: ${student?.studentIcNumber}"),
        Text("MyKad/Passport Number: ${student?.studentmyKadPassportNumber}"),
        Text(
            "Date of Birth: ${DateFormat('dd MMM yyyy').format(student!.studentDoB)}"),
        const SizedBox(height: 20),
        const Text("Documents Uploaded:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHeroImage(student.frontMatricPic, "Front Matric Card"),
            const SizedBox(width: 20),
            _buildHeroImage(student.backMatricPic, "Back Matric Card"),
            const SizedBox(width: 20),
            _buildHeroImage(student.passportMyKadPic, "MyKad/Passport"),
          ],
        )
      ],
    );
  }

  Widget _buildHeroImage(String imageUrl, String tag) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HeroDetailScreen(imageUrl: imageUrl, tag: tag),
          ),
        );
      },
      child: Hero(
        tag: tag,
        child: Image.network(
          imageUrl,
          width: 100,
          height: 150,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    final application = widget.application;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Check-In Status: ${application.checkInStatus}",
          style: TextStyle(
            color: application.checkInStatus == "Approved"
                ? Colors.green
                : application.checkInStatus == "Rejected"
                    ? Colors.red
                    : Colors.orange,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRejectionReasonSection() {
    if (widget.application.checkInStatus == "Rejected") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Rejection Reason: ",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(widget.application.rejectionReason ?? "No reason provided"),
            ],
          ),
          const SizedBox(height: 20),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildButtons() {
    final application = widget.application;
    if (application.checkInStatus != 'Approved' &&
        application.checkInStatus != 'Rejected' &&
        !showRoomAssignment) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reject Application'),
                  content: TextField(
                    controller: _rejectionReasonController,
                    decoration: const InputDecoration(
                        hintText: "Enter rejection reason"),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      child: const Text('Reject'),
                      onPressed: () {
                        _controller.updateCheckInApplication(
                          widget.application,
                          'Rejected',
                          '', // Empty room number for rejected applications
                          _rejectionReasonController.text,
                        );
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
            child: const Text("Reject"),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showRoomAssignment = true; // Show room assignment section
              });
            },
            child: const Text("Approve"),
          ),
        ], // Removed the Approve button
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

class HeroDetailScreen extends StatelessWidget {
  final String imageUrl;
  final String tag;

  const HeroDetailScreen(
      {super.key, required this.imageUrl, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tag),
      ),
      body: Center(
        child: Hero(
          tag: tag,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
