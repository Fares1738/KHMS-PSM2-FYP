// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:khms/Controller/userController.dart';
import 'package:khms/Model/Staff.dart';
import 'package:khms/View/Custom_Widgets/textFormFieldDesign.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final UserController _userController = UserController();

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  UserType? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Staff User')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextFormField(
                  controller: _firstNameController,
                  labelText: 'First Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a first name';
                    }
                    return null;
                  },
                  prefixIcon: Icons.person,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _lastNameController,
                  labelText: 'Last Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a last name';
                    }
                    return null;
                  },
                  prefixIcon: Icons.person,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _phoneNumberController,
                  labelText: 'Phone Number',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                  prefixIcon: Icons.phone,
                  isPhoneNumber: true,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _emailController,
                  labelText: 'Email',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                  prefixIcon: Icons.email,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserType>(
                  value: _selectedRole,
                  onChanged: (UserType? value) {
                    // Change to UserType?
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Role',
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ), // Add this line
                  items: UserType.values.map((UserType role) {
                    return DropdownMenuItem<UserType>(
                      // Change to UserType
                      value: role,
                      child: Text(
                          role.toString().split('.').last), // Display enum name
                    );
                  }).toList(),
                  // ... (rest of the DropdownButtonFormField code)
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _userController.addStaff(
                        _firstNameController.text,
                        _lastNameController.text,
                        _emailController.text,
                        _phoneNumberController.text,
                        _selectedRole!,
                      );
                      Navigator.of(context).pop(); // Go back after adding
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User added successfully!'),
                      ),
                    );
                  },
                  child: const Text('Submit'),
                ),
                const SizedBox(height: 16),
                const Text("The new user will be provided with the default password 'temporaryPassword123'. Please advise them to change their password upon first login."),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
