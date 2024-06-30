// ignore_for_file: file_names, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:khms/View/Staff/staffManageComplaintsPage.dart';
import 'package:khms/View/Staff/staffManageCheckInPage.dart';
import 'package:khms/View/Staff/staffManageCheckOutPage.dart';
import 'package:khms/View/Staff/staffManageFacilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageApplications extends StatefulWidget {
  const ManageApplications({Key? key}) : super(key: key);

  @override
  _ManageApplicationsState createState() => _ManageApplicationsState();
}

class _ManageApplicationsState extends State<ManageApplications> {
  String? userType;

  @override
  void initState() {
    super.initState();
    _getUserType();
  }

  Future<void> _getUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('userType');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Applications'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildActionCards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.manage_accounts,
                size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            const Text(
              "Manage Applications",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "User Type: ${userType ?? 'Loading...'}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCards() {
    List<Widget> cards = [];

    if (userType == 'Manager' || userType == 'Staff') {
      cards.addAll([
        _buildActionCard(
          icon: Icons.login,
          title: "Check In Applications",
          onTap: () => _navigateTo(const CheckInApplicationsListPage()),
        ),
        _buildActionCard(
          icon: Icons.logout,
          title: "Check Out Applications",
          onTap: () => _navigateTo(const CheckOutApplicationsListPage()),
        ),
        _buildActionCard(
          icon: Icons.business,
          title: "Manage Facilities and Bookings",
          onTap: () => _navigateTo(const FacilityManagementPage()),
        ),
      ]);
    }

    if (userType == 'Maintenance' || userType == 'Manager') {
      cards.add(
        _buildActionCard(
          icon: Icons.build,
          title: "Complaints and Maintenance Requests",
          onTap: () => _navigateTo(const StaffComplaintsPage()),
        ),
      );
    }

    return Column(
      children: cards,
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: Theme.of(context).primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
