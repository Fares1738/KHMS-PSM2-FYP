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
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "${widget.application.student?.studentFirstName} ${widget.application.student?.studentLastName}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Application Date: ${DateFormat('dd MMM yyyy | hh:mm a').format(widget.application.checkInApplicationDate)}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            Padding(
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
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDetails() {
    final student = widget.application.student;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Student Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDetailRow(
                "Check-In Date",
                DateFormat('dd MMM yyyy | hh:mm a')
                    .format(widget.application.checkInDate)),
            _buildDetailRow("Email", student?.studentEmail ?? ''),
            _buildDetailRow("Phone", student?.studentPhoneNumber ?? ''),
            _buildDetailRow("Nationality", student?.studentNationality ?? ''),
            _buildDetailRow("IC Number", student?.studentIcNumber ?? ''),
            _buildDetailRow(
                "MyKad/Passport", student?.studentmyKadPassportNumber ?? ''),
            _buildDetailRow("Date of Birth",
                DateFormat('dd MMM yyyy').format(student!.studentDoB)),
            const SizedBox(height: 20),
            const Text("Documents",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildDocumentsGrid(student),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDocumentsGrid(student) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildDocumentThumbnail(student.frontMatricPic, "Front Matric Card"),
        _buildDocumentThumbnail(student.backMatricPic, "Back Matric Card"),
        _buildDocumentThumbnail(student.passportMyKadPic, "MyKad/Passport"),
        _buildDocumentThumbnail(student.studentPhoto, "Student Photo"),
      ],
    );
  }

  Widget _buildDocumentThumbnail(String imageUrl, String tag) {
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
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.all(8),
            child: Text(
              tag,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    final application = widget.application;
    Color statusColor = application.checkInStatus == "Approved"
        ? Colors.green
        : application.checkInStatus == "Rejected"
            ? Colors.red
            : Colors.orange;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              application.checkInStatus == "Approved"
                  ? Icons.check_circle
                  : application.checkInStatus == "Rejected"
                      ? Icons.cancel
                      : Icons.hourglass_empty,
              color: statusColor,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Check-In Status",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    application.checkInStatus,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: statusColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectionReasonSection() {
    if (widget.application.checkInStatus == "Rejected") {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Rejection Reason",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(widget.application.rejectionReason ?? "No reason provided"),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
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
                              : (room.roomType == 'Triple' ? 3 : 0);

                          return DropdownMenuItem<Room>(
                            value: room,
                            child: FutureBuilder<int>(
                              future: room.roomType == 'Single'
                                  ? Future.value(0)
                                  : _controller
                                      .getAssignedTenantsCount(room.roomNo),
                              builder: (context, tenantCountSnapshot) {
                                if (tenantCountSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                      '${room.roomNo} (${room.roomType})');
                                } else {
                                  final tenantCount =
                                      tenantCountSnapshot.data ?? 0;
                                  return Text(
                                    '${room.roomNo} (${room.roomType})${room.roomType == 'Single' ? '' : ' - $tenantCount/$capacity'}',
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

  Widget _buildButtons() {
    final application = widget.application;
    if (application.checkInStatus != 'Approved' &&
        application.checkInStatus != 'Rejected' &&
        !showRoomAssignment) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
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
                      ElevatedButton(
                        child: const Text('Reject'),
                        onPressed: () {
                          _controller.updateCheckInApplication(
                            widget.application,
                            'Rejected',
                            '',
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
              icon: const Icon(Icons.close, color: Colors.white),
              label: const Text(
                "Reject",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  showRoomAssignment = true;
                });
              },
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                "Approve",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
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
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: Hero(
            tag: tag,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
