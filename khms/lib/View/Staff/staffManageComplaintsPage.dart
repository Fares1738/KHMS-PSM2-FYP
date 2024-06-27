// ignore_for_file: library_private_types_in_public_api, file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:khms/Controller/complaintsController.dart';
import 'package:khms/Model/Complaint.dart';

class StaffComplaintsPage extends StatefulWidget {
  const StaffComplaintsPage({super.key});

  @override
  _StaffComplaintsPageState createState() => _StaffComplaintsPageState();
}

class _StaffComplaintsPageState extends State<StaffComplaintsPage> {
  final ComplaintsController _controller = ComplaintsController();
  List<Complaint> complaints = [];
  String selectedStatusFilter = 'All';
  bool isLoading = true;
  String _selectedDateSort = 'Newest'; // Added for date sorting
  String _selectedTypeFilter = 'All';
  String _selectedSubTypeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    try {
      final fetchedComplaints = await _controller.fetchAllComplaints();
      setState(() {
        complaints = fetchedComplaints;
        isLoading = false;
      });
    } catch (e) {
      // Handle errors appropriately (e.g., display a snackbar)
      print('Error fetching complaints: $e');
    }
  }

  Future<void> _updateComplaintStatus(
      String complaintId, ComplaintStatus status) async {
    await _controller.updateComplaintStatus(complaintId, status);
    _fetchComplaints();
  }

  List<Complaint> _getFilteredComplaints() {
    List<Complaint> filtered = complaints.where((c) {
      // Filter by status
      if (selectedStatusFilter != 'All' &&
          c.complaintStatus.name != selectedStatusFilter) {
        return false;
      }
      // Filter by type
      if (_selectedTypeFilter != 'All' &&
          c.complaintType != _selectedTypeFilter) {
        return false;
      }
      // Filter by sub-type
      if (_selectedSubTypeFilter != 'All' &&
          c.complaintSubType != _selectedSubTypeFilter) {
        return false;
      }
      return true;
    }).toList();

    // Sort by date
    if (_selectedDateSort == 'Oldest') {
      filtered.sort((a, b) => a.complaintDate.compareTo(b.complaintDate));
    } else {
      filtered.sort((a, b) => b.complaintDate.compareTo(a.complaintDate));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredComplaints = _getFilteredComplaints();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
      ),
      body: Column(
        children: [
          _buildFilterRow(), // Row for filters (status and date)
          Expanded(
            child: _buildComplaintList(filteredComplaints),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text('Status: '),
              _buildStatusFilterDropdown(),
              const Text("Sort by: "),
              _buildDateSortDropdown(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 0.0),
            child: Row(
              children: [
                const Text("Type: "),
                _buildTypeFilterDropdown(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 0.0),
            child: Row(
              children: [
                const Text("Sub-Type: "),
                _buildSubTypeFilterDropdown(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTypeFilterDropdown() {
    final types = [
      'All',
      ...complaints.map((c) => c.complaintType).toSet()
    ]; // Get unique types
    return DropdownButton<String>(
      value: _selectedTypeFilter,
      onChanged: (String? newValue) {
        setState(() {
          _selectedTypeFilter = newValue!;
          _selectedSubTypeFilter =
              'All'; // Reset subtype filter when type changes
        });
      },
      items: types.map((type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
    );
  }

//Dropdown for Complaint Subtype
  Widget _buildSubTypeFilterDropdown() {
    final subTypesForSelectedType = complaints
        .where((c) => c.complaintType == _selectedTypeFilter)
        .map((c) => c.complaintSubType)
        .toSet()
        .toList();
    subTypesForSelectedType.insert(0, 'All'); // Add 'All' option

    return DropdownButton<String>(
      value: _selectedSubTypeFilter,
      onChanged: (String? newValue) {
        setState(() {
          _selectedSubTypeFilter = newValue!;
        });
      },
      items: subTypesForSelectedType.map((subType) {
        return DropdownMenuItem<String>(
          value: subType,
          child: Text(subType),
        );
      }).toList(),
    );
  }

  // Dropdown for date sorting
  Widget _buildDateSortDropdown() {
    return DropdownButton<String>(
      value: _selectedDateSort,
      onChanged: (String? newValue) {
        setState(() {
          _selectedDateSort = newValue!;
        });
      },
      items: <String>['Oldest', 'Newest']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildStatusFilterDropdown() {
    return DropdownButton<String>(
      value: selectedStatusFilter,
      onChanged: (value) {
        setState(() {
          selectedStatusFilter = value!;
        });
      },
      items: ['All', 'Pending', 'Unresolved', 'Resolved'].map((status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Row(
            children: [
              Text(status),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildComplaintList(List<Complaint> complaints) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (complaints.isEmpty) {
      return const Center(child: Text("No complaints found."));
    }
    return ListView.builder(
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        final complaint = complaints[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          elevation: 3.0,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(complaint.complaintStatus.name),
              child: Text(
                complaint.complaintStatus.name[0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              complaint.complaintDescription,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Room: ${complaint.studentRoomNo ?? "N/A"}'),
            children: [
              ListTile(
                title: Text('Location: ${complaint.complaintLocation}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Type: ${complaint.complaintType}'),
                    Text('Sub-Type: ${complaint.complaintSubType}'),
                    Text('Date: ${complaint.complaintDate}'),
                    if (complaint.complaintImageUrl.isNotEmpty)
                      FutureBuilder(
                        future: _loadImage(complaint.complaintImageUrl),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Text('Error loading image');
                          } else {
                            return Image.network(complaint.complaintImageUrl);
                          }
                        },
                      ),
                    if (complaint.complaintStatus != ComplaintStatus.Resolved)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () => _updateComplaintStatus(
                              complaint.complaintId,
                              ComplaintStatus.Resolved,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Resolved',
                                style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            onPressed: () => _updateComplaintStatus(
                              complaint.complaintId,
                              ComplaintStatus.Pending,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            child: const Text('Pending',
                                style: TextStyle(color: Colors.white)),
                          ),
                          if (complaint.complaintStatus !=
                              ComplaintStatus.Unresolved)
                            ElevatedButton(
                              onPressed: () => _updateComplaintStatus(
                                complaint.complaintId,
                                ComplaintStatus.Unresolved,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Unresolved',
                                  style: TextStyle(color: Colors.white)),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Resolved':
        return Colors.green;
      case 'Unresolved':
        return Colors.red;
      default:
        return Colors.black; // Default color for 'All'
    }
  }

  Future<Image> _loadImage(String imageUrl) async {
    final image = Image.network(imageUrl);
    await precacheImage(image.image, context);
    return image;
  }
}
