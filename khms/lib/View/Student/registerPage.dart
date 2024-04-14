// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:khms/Model/Student/studentModel.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool? isChecked = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Registration'),
            backgroundColor: Colors.white,
            elevation: 0.0,
            titleSpacing: 10.0,
            leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.black54,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 10),
            child: Column(
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    icon: Icon(Icons.person_3),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    icon: Icon(Icons.email_rounded),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    icon: Icon(Icons.lock_rounded),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    icon: Icon(Icons.lock_rounded),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16.0),
                CheckboxListTile(
                  title: const Text(
                      'I agree to the terms and conditions of K Hotel Sdn Bhd'),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    StudentModel newStudent = StudentModel(
                      username: _usernameController.text,
                      email: _emailController.text,
                      password: _passwordController.text,
                      confirmPassword: _confirmPasswordController.text,
                      isChecked: isChecked,
                    );

                    // ignore: avoid_print
                    print(newStudent.username);

                    //Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Registration successful!'),
                      ),
                    );

                    _usernameController.clear();
                    _emailController.clear();
                    _passwordController.clear();
                    _confirmPasswordController.clear();
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ));
  }
}
