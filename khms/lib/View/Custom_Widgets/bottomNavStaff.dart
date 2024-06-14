// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';

class StaffBottomNavigationBar extends StatefulWidget {
  final Function(int) onTap; // Function to handle taps
  final List<BottomNavigationBarItem>
      items; // List of items for the navigation bar

  const StaffBottomNavigationBar({
    super.key,
    required this.onTap,
    required this.items,
  });

  @override
  _StaffBottomNavigationBar createState() => _StaffBottomNavigationBar();
}

class _StaffBottomNavigationBar extends State<StaffBottomNavigationBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: widget.items,
      currentIndex: _selectedIndex,
      selectedItemColor: const Color.fromARGB(255, 0, 68, 255),
      unselectedItemColor: Colors.grey.shade800,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        widget.onTap(index);
      }, // Notify the parent about taps
    );
  }
}
