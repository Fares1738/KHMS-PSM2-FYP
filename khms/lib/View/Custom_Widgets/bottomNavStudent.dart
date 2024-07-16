// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';

class StudentBottomNavigationBar extends StatefulWidget {
  final Function(int) onTap; 

  const StudentBottomNavigationBar({super.key, required this.onTap});

  @override
  _StudentBottomNavigationBar createState() => _StudentBottomNavigationBar();
}

class _StudentBottomNavigationBar extends State<StudentBottomNavigationBar> {
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
            icon: Icon(Icons.comment),
            label: 'Complaints',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gamepad_rounded),
            label: 'Facilities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_document),
            label: 'Accommodation Application',
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
        } 
        );
  }
}
