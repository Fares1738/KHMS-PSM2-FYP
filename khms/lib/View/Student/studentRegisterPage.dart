// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:khms/Controller/studentController.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final StudentController _controller = StudentController();
  bool isChecked = false;

  @override
  void dispose() {
    _controller.usernameController.dispose();
    _controller.emailController.dispose();
    _controller.passwordController.dispose();
    _controller.confirmPasswordController.dispose();
    super.dispose();
  }

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
          child: Form(
            key: _controller.formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _controller.usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    icon: Icon(Icons.person_3),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _controller.emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    icon: Icon(Icons.email_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                    // Add more robust email validation if needed
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _controller.passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    icon: Icon(Icons.lock_rounded),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _controller.confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    icon: Icon(Icons.lock_rounded),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    return null;
                  },
                ),
                CheckboxListTile(
                  title: const Text(
                      'I agree to the terms and conditions of K Hotel Sdn Bhd'),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value!;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    _controller.registerUser(context);
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
