import 'package:flutter/material.dart';
import 'package:khms/Controller/userController.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final UserController _controller = UserController();
  bool _obscurePassword = true;
  bool isChecked = false;
  bool _hasUppercase = false;
  bool _hasSpecialChar = false;
  bool _hasValidLength = false;

  @override
  void dispose() {
    _controller.emailController.dispose();
    _controller.passwordController.dispose();
    _controller.confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return _controller.getErrorMessage('invalid-email');
    }
    if (!value.contains('@') || !value.contains('.')) {
      return _controller.getErrorMessage('invalid-email');
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8 || value.length > 16) {
      return 'Password must be 8-16 characters long';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  void _updatePasswordStrength(String password) {
    setState(() {
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _hasValidLength = password.length >= 8 && password.length <= 16;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
        backgroundColor: Colors.white,
        elevation: 0.0,
        titleSpacing: 10.0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black54,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        child: Form(
          key: _controller.formKey,
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _controller.emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _controller.passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                validator: _validatePassword,
                onChanged: (value) {
                  _updatePasswordStrength(value);
                },
              ),
              const SizedBox(height: 8.0),
              _buildPasswordStrengthIndicator(),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _controller.confirmPasswordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != _controller.passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            isChecked = value!;
                          });
                        },
                      ),
                      const Text(
                        'I agree to the terms and conditions of K Hotel',
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(52.0, 0, 0, 0),
                    child: Row(
                      children: [
                        Text(
                          "Sdn Bhd",
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () {
                  if (_controller.formKey.currentState!.validate()) {
                    if (isChecked == true) {
                      _controller.registerUser(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Please agree to the terms and conditions.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequirementRow(_hasValidLength, '8-16 characters'),
        _buildRequirementRow(_hasUppercase, 'At least 1 uppercase letter'),
        _buildRequirementRow(_hasSpecialChar, 'At least 1 special character'),
      ],
    );
  }

  Widget _buildRequirementRow(bool isMet, String requirement) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.cancel,
          color: isMet ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          requirement,
          style: TextStyle(
            color: isMet ? Colors.green : Colors.red,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
