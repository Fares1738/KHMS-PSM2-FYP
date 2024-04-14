// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:khms/View/Student/RegisterPage.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png'),
              const Text(
                'KLG Campus Hostel Management System',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Builder(builder: (context) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text('Register'),
                    ),
                    const SizedBox(width: 30),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Login'),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
