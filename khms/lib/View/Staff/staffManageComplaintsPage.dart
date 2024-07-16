import 'package:flutter/material.dart';
import 'package:khms/Controller/complaintsController.dart';
import 'package:khms/Model/Complaint.dart';
import 'package:intl/intl.dart';

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
  String _selectedDateSort = 'Newest';
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
      print('Error fetching complaints: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load complaints: $e')),
      );
    }
  }

  Future<void> _refreshComplaints() async {
    setState(() {
      isLoading = true;
    });
    await _fetchComplaints();
  }

  Future<void> _updateComplaintStatus(
      String complaintId, ComplaintStatus status, String complaintNote) async {
    await _controller.updateComplaintStatus(complaintId, status, complaintNote);
    _fetchComplaints();
  }

  List<Complaint> _getFilteredComplaints() {
    List<Complaint> filtered = complaints.where((c) {
      if (selectedStatusFilter != 'All' &&
          c.complaintStatus.name != selectedStatusFilter) {
        return false;
      }
      if (_selectedTypeFilter != 'All' &&
          c.complaintType != _selectedTypeFilter) {
        return false;
      }
      if (_selectedSubTypeFilter != 'All' &&
          c.complaintSubType != _selectedSubTypeFilter) {
        return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) => _selectedDateSort == 'Oldest'
        ? a.complaintDate.compareTo(b.complaintDate)
        : b.complaintDate.compareTo(a.complaintDate));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredComplaints = _getFilteredComplaints();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshComplaints,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildFilterSection(),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (filteredComplaints.isEmpty) {
                    return Center(
                      child: Text(
                        "No complaints found.",
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    );
                  }
                  return _buildComplaintCard(filteredComplaints[index]);
                },
                childCount: isLoading
                    ? 1
                    : filteredComplaints.isEmpty
                        ? 1
                        : filteredComplaints.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildFilterDropdown(
                      'Status',
                      selectedStatusFilter,
                      ['All', 'Pending', 'Unresolved', 'Resolved'],
                      (value) =>
                          setState(() => selectedStatusFilter = value!))),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildFilterDropdown(
                      'Sort by Date',
                      _selectedDateSort,
                      ['Newest', 'Oldest'],
                      (value) => setState(() => _selectedDateSort = value!))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildFilterDropdown('Type', _selectedTypeFilter, [
                'All',
                ...complaints.map((c) => c.complaintType).toSet()
              ], (value) {
                setState(() {
                  _selectedTypeFilter = value!;
                  _selectedSubTypeFilter = 'All';
                });
              })),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildFilterDropdown(
                      'Sub-Type',
                      _selectedSubTypeFilter,
                      [
                        'All',
                        ...complaints
                            .where(
                                (c) => c.complaintType == _selectedTypeFilter)
                            .map((c) => c.complaintSubType)
                            .toSet()
                      ],
                      (value) =>
                          setState(() => _selectedSubTypeFilter = value!))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(complaint.complaintStatus.name),
          child: Text(
            complaint.complaintStatus.name[0],
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          complaint.complaintDescription,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Room: ${complaint.studentRoomNo ?? "N/A"}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Location', complaint.complaintLocation),
                _buildInfoRow('Type', complaint.complaintType),
                _buildInfoRow('Sub-Type', complaint.complaintSubType),
                _buildInfoRow('Date',
                    DateFormat('MMM d, yyyy').format(complaint.complaintDate)),
                _buildInfoRow('Notes', complaint.complaintNote ?? 'N/A'),
                if (complaint.complaintImageUrl.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildExpandableImage(complaint.complaintImageUrl),
                ],
                if (complaint.complaintStatus != ComplaintStatus.Resolved) ...[
                  const SizedBox(height: 16),
                  _buildActionButtons(complaint),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              items: items
                  .map((item) =>
                      DropdownMenuItem<String>(value: item, child: Text(item)))
                  .toList(),
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildExpandableImage(String imageUrl) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(context, imageUrl),
      child: Hero(
        tag: imageUrl,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) =>
                const Text('Error loading image'),
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        body: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Center(
            child: Hero(
              tag: imageUrl,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildActionButtons(Complaint complaint) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          'Resolved',
          Colors.green,
          () => _updateComplaintStatus(
              complaint.complaintId, ComplaintStatus.Resolved, ''),
        ),
        if (complaint.complaintStatus != ComplaintStatus.Pending)
          _buildActionButton(
            'Pending',
            Colors.orange,
            () => _updateComplaintStatus(
                complaint.complaintId, ComplaintStatus.Pending, ''),
          ),
        if (complaint.complaintStatus != ComplaintStatus.Unresolved)
          _buildActionButton(
            'Unresolved',
            Colors.red,
            () => _showUnresolvedDialog(complaint),
          ),
      ],
    );
  }

  void _showUnresolvedDialog(Complaint complaint) {
    String complaintNote = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Attach Note'),
          content: TextField(
            onChanged: (value) {
              complaintNote = value;
            },
            decoration: const InputDecoration(hintText: "Enter note here"),
            maxLines: 1,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop();
                _updateComplaintStatus(complaint.complaintId,
                    ComplaintStatus.Unresolved, complaintNote);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label),
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
        return Colors.grey;
    }
  }
}
