import 'package:flutter/material.dart';
import 'package:khms/Controller/userController.dart';
import 'package:khms/View/Common/profilePage.dart';
import 'package:khms/View/Staff/staffAddUserPage.dart';
import 'package:khms/View/Staff/staffManageAnnoucementsPage.dart';
import 'package:khms/View/Staff/staffViewAllUsers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralCustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const GeneralCustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    //Provider.of<UserController>(context);

    return AppBar(
      title: const Text(
        "KHMS",
        style: TextStyle(fontSize: 28),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class HomeCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeCustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    //Provider.of<UserController>(context);

    return AppBar(
      title: const Text(
        "KHMS",
        style: TextStyle(fontSize: 28),
      ),
      automaticallyImplyLeading: false, // Disable the default back button
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final UserController _userController = UserController();
  String? userType;

  @override
  void initState() {
    super.initState();
    _userController.addListener(() {
      setState(() {});
    });
    _fetchData();
  }

  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('userType');
    });
    print(userType);
    await _userController.fetchUserData();
  }

  ImageProvider _determineProfileImage() {
    if (_userController.student?.studentPhoto.isNotEmpty == true) {
      return NetworkImage(_userController.student!.studentPhoto);
    } else if (_userController.staff?.staffPhoto?.isNotEmpty == true) {
      return NetworkImage(_userController.staff!.staffPhoto!);
    } else {
      return const AssetImage('assets/images/default_profile_image.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              userType == 'Students'
                  ? '${_userController.student?.studentFirstName ?? ''} ${_userController.student?.studentLastName ?? ''}'
                  : '${_userController.staff?.staffFirstName ?? ''} ${_userController.staff?.staffLastName ?? ''}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              userType == 'Students'
                  ? _userController.student?.studentEmail ?? ''
                  : _userController.staff?.userType
                          .toString()
                          .split('.')
                          .last ??
                      '',
            ),
            currentAccountPicture: CircleAvatar(
              radius: 80,
              backgroundImage: _determineProfileImage(),
              backgroundColor: Colors.grey[200],
            ),
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentProfilePage(),
                ),
              );
            },
          ),
          if (userType == 'Manager') // Only show for Manager
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add New User'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddUserPage(),
                  ),
                );
              },
            ),
          if (userType == 'Manager') // Only show for Manager
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('View All Users'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewAllUsers(),
                  ),
                );
              },
            ),
          if (userType == 'Manager')
            ListTile(
              leading: const Icon(Icons.announcement),
              title: const Text('Manage Announcements'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageAnnouncementsPage(),
                  ),
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              _userController.signOutUser(context);
            },
          ),
        ],
      ),
    );
  }
}
