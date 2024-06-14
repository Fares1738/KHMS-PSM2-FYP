// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:khms/Controller/userController.dart';
import 'package:khms/View/Custom_Widgets/appBar.dart';
import 'package:khms/View/Custom_Widgets/bottomNavStaff.dart';
import 'package:khms/View/Staff/staffDashboardPage.dart';
import 'package:khms/View/Staff/staffManagePage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  _StaffHomePageState createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  int _currentPageIndex = 0;
  String? userType; // To store userType from SharedPreferences

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
    final userController = Provider.of<UserController>(context);
    return Scaffold(
      appBar: const HomeCustomAppBar(),
      drawer: const CustomDrawer(),
      body: IndexedStack(
        index: _currentPageIndex,
        children: [
          Center(
            child: Text(
              userController.staff?.staffFirstName != null
                  ? "Welcome ${userController.staff?.staffFirstName ?? ''}"
                  : "Staff Home Page",
            ),
          ),
          const ManageApplications(),
          if (userType == 'Manager' || userType == 'Staff')
            const DashboardPage(),
        ],
      ),
      bottomNavigationBar: StaffBottomNavigationBar(
        onTap: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Manage',
          ),
          if (userType == 'Manager' || userType == 'Staff')
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
        ],
      ),
    );
  }
}
