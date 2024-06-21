import 'package:flutter/material.dart';
import 'package:khms/Controller/userController.dart';
import 'package:khms/Model/Staff.dart';
import 'package:khms/Model/Student.dart';
import 'userDetailPage.dart'; // Import the new user detail page

class ViewAllUsers extends StatefulWidget {
  const ViewAllUsers({super.key});

  @override
  _ViewAllUsersState createState() => _ViewAllUsersState();
}

class _ViewAllUsersState extends State<ViewAllUsers> {
  final UserController _userController = UserController();
  final TextEditingController _searchController = TextEditingController();
  List<Student> _students = [];
  List<Staff> _staff = [];
  List<Student> _filteredStudents = [];
  List<Staff> _filteredStaff = [];
  bool _isLoading = true;
  String _selectedUserType = 'All';
  String _selectedBlock = 'All';
  String _selectedFloor = 'All';
  final List<String> _blocks = ['All', 'Block A', 'Block B'];
  final List<String> _floors = ['All', '1', '2', '3', '4', '5', '6', '7', '8'];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_filterResults);
  }

  Future<void> _fetchData() async {
    try {
      _students = await _userController.fetchAllStudents();
      _staff = await _userController.fetchAllStaff();
      // Filter students to only include those with room numbers
      _students = _students
          .where((student) => student.studentRoomNo.isNotEmpty)
          .toList();
      _filteredStudents = _students;
      _filteredStaff = _staff;
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching user data!')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterResults() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _students.where((student) {
        return (student.studentFirstName.toLowerCase().contains(query) ||
                student.studentLastName.toLowerCase().contains(query) ||
                student.studentEmail.toLowerCase().contains(query)) &&
            (_selectedBlock == 'All' ||
                student.studentRoomNo
                    .startsWith(_selectedBlock.split(' ').last)) &&
            (_selectedFloor == 'All' ||
                student.studentRoomNo[1] == _selectedFloor);
      }).toList();
      _filteredStaff = _staff.where((staff) {
        return (_selectedUserType == 'All' ||
                staff.userType.toString().split('.').last ==
                    _selectedUserType) &&
            (staff.staffFirstName.toLowerCase().contains(query) ||
                staff.staffLastName.toLowerCase().contains(query) ||
                staff.staffEmail.toLowerCase().contains(query) ||
                staff.userType
                    .toString()
                    .split('.')
                    .last
                    .toLowerCase()
                    .contains(query));
      }).toList();
    });
  }

  void _filterStudentsByBlock(String block) {
    setState(() {
      _selectedBlock = block;
      _selectedFloor = 'All'; // Reset floor when block is changed
      _filterResults();
    });
  }

  void _filterStudentsByFloor(String floor) {
    setState(() {
      _selectedFloor = floor;
      _filterResults();
    });
  }

  void _filterStaffByUserType(String userType) {
    setState(() {
      _selectedUserType = userType;
      _filterResults();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Users'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Students'),
                Tab(text: 'Staff'),
              ],
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: TabBarView(
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        decoration: const InputDecoration(
                                          labelText: 'Search',
                                          prefixIcon: Icon(Icons.search),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: Column(
                                          children: [
                                            const Text('Block'),
                                            DropdownButton<String>(
                                              value: _selectedBlock,
                                              onChanged: (String? newValue) {
                                                _filterStudentsByBlock(
                                                    newValue!);
                                              },
                                              items: _blocks.map<
                                                      DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: Column(
                                          children: [
                                            const Text('Floor'),
                                            DropdownButton<String>(
                                              value: _selectedFloor,
                                              onChanged: _selectedBlock == 'All'
                                                  ? null
                                                  : (String? newValue) {
                                                      _filterStudentsByFloor(
                                                          newValue!);
                                                    },
                                              items: _floors.map<
                                                      DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(child: _buildStudentList()),
                            ],
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        decoration: const InputDecoration(
                                          labelText: 'Search',
                                          prefixIcon: Icon(Icons.search),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedUserType,
                                          onChanged: (String? newValue) {
                                            _filterStaffByUserType(newValue!);
                                          },
                                          items: <String>[
                                            'All',
                                            'Manager',
                                            'Maintenance',
                                            'Staff'
                                          ].map<DropdownMenuItem<String>>(
                                              (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(child: _buildStaffList()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    return ListView.builder(
      itemCount: _filteredStudents.length,
      itemBuilder: (context, index) {
        Student student = _filteredStudents[index];
        return ListTile(
          title: Text('${student.studentFirstName} ${student.studentLastName}'),
          subtitle: Text(student.studentRoomNo),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserDetailPage(student: student),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStaffList() {
    return ListView.builder(
      itemCount: _filteredStaff.length,
      itemBuilder: (context, index) {
        Staff staff = _filteredStaff[index];
        return ListTile(
          title: Text('${staff.staffFirstName} ${staff.staffLastName}'),
          subtitle: Text(staff.userType.toString().split('.').last),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserDetailPage(staff: staff),
              ),
            );
          },
        );
      },
    );
  }
}
