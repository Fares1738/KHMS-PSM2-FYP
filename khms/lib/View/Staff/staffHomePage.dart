import 'package:flutter/material.dart';
import 'package:khms/View/Custom_Widgets/appBar.dart';
import 'package:khms/View/Custom_Widgets/bottomNavStaff.dart';
import 'package:khms/View/Staff/staffDashboardPage.dart';
import 'package:khms/View/Staff/staffManagePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({Key? key}) : super(key: key);

  @override
  _StaffHomePageState createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  int _currentPageIndex = 0;
  late Future<String?> _userTypeFuture;

  @override
  void initState() {
    super.initState();
    _userTypeFuture = _getUserType();
  }

  Future<String?> _getUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userType');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _userTypeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userType = snapshot.data;
        final bottomNavItems = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Manage',
          ),
          if (userType == 'Manager' || userType == 'Staff')
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
        ];

        return Scaffold(
          appBar: const HomeCustomAppBar(),
          drawer: const CustomDrawer(),
          body: IndexedStack(
            index: _currentPageIndex,
            children: [
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
            items: bottomNavItems,
          ),
        );
      },
    );
  }
}
