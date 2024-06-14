// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:khms/Controller/userController.dart';
import 'package:khms/View/Common/profilePage.dart';
import 'package:khms/View/Staff/staffAddUserPage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralCustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const GeneralCustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<UserController>(context);

    return AppBar(
      title: const Text(
        "KHMS",
        style: TextStyle(fontSize: 28),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            controller.signOutUser(context);
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class HomeCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeCustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<UserController>(context);

    return AppBar(
      title: const Text(
        "KHMS",
        style: TextStyle(fontSize: 28),
      ),
      automaticallyImplyLeading: false, // Disable the default back button
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            controller.signOutUser(context);
          },
        ),
      ],
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
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
    userType = prefs.getString('userType');
    print(userType);
    await _userController.fetchUserData();
    setState(() {}); // Ensure the state is updated after fetching data
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
                  : _userController.staff?.staffEmail ?? '',
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
