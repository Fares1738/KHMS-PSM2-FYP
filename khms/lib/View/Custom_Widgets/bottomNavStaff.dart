// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';

class StaffBottomNavigationBar extends StatefulWidget {
  final Function(int) onTap; // Function to handle taps

  const StaffBottomNavigationBar({super.key, required this.onTap});

  @override
  _StaffBottomNavigationBar createState() => _StaffBottomNavigationBar();
}

class _StaffBottomNavigationBar extends State<StaffBottomNavigationBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Manage',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 0, 68, 255),
        unselectedItemColor: Colors.grey.shade800,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          widget.onTap(index);
        } // Notify the parent about taps,
        );
  }
}
