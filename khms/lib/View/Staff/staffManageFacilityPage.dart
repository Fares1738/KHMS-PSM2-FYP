import 'package:flutter/material.dart';
import 'package:khms/Controller/facilitiesController.dart';
import 'package:khms/View/Custom_Widgets/textFormFieldDesign.dart';

class ManageFacilitiesPage extends StatefulWidget {
  const ManageFacilitiesPage({super.key});

  @override
  _ManageFacilitiesPageState createState() => _ManageFacilitiesPageState();
}

class _ManageFacilitiesPageState extends State<ManageFacilitiesPage> {
  final FacilitiesController _controller = FacilitiesController();
  final TextEditingController _facilityTypeController = TextEditingController();
  Map<String, bool> _facilityAvailability = {};

  @override
  void initState() {
    super.initState();
    _fetchAvailability();
  }

  Future<void> _fetchAvailability() async {
    final availability = await _controller.fetchFacilityAvailability();
    setState(() {
      _facilityAvailability = availability;
    });
  }

  void _toggleFacility(String facilityType, bool isEnabled) {
    _controller.toggleFacilityAvailability(facilityType, isEnabled);
    setState(() {
      _facilityAvailability[facilityType] = isEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Facilities'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Facilities List',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: _controller.fetchFacilitiesList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  } else {
                    final facilitiesList = snapshot.data!;
                    return ListView.builder(
                      itemCount: facilitiesList.length,
                      itemBuilder: (context, index) {
                        final facilityType = facilitiesList[index];
                        return _buildFacilityCard(facilityType);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFacilityDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No facilities available',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityCard(String facilityType) {
    final isEnabled = _facilityAvailability[facilityType] ?? false;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    facilityType,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEnabled ? 'Enabled' : 'Disabled',
                    style: TextStyle(
                      color: isEnabled ? Colors.green : Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isEnabled,
              onChanged: (value) => _toggleFacility(facilityType, value),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteConfirmationDialog(facilityType),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddFacilityDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Facility'),
          content: CustomTextFormField(
            controller: _facilityTypeController,
            labelText: 'Facility Name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a facility name';
              }
              return null;
            },
            prefixIcon: Icons.category_outlined,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () async {
                if (_facilityTypeController.text.isNotEmpty) {
                  await _controller.addFacility(_facilityTypeController.text);
                  _facilityTypeController.clear();
                  Navigator.of(context).pop();
                  _fetchAvailability(); // Refresh the availability data
                  setState(() {});
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(String facilityType) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete $facilityType?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
              onPressed: () async {
                await _deleteFacility(facilityType);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteFacility(String facilityType) async {
    await _controller.deleteFacility(facilityType);
    _fetchAvailability(); // Refresh the availability data
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$facilityType deleted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
