// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:khms/Controller/paymentController.dart';

class BankTransferPage extends StatefulWidget {
  const BankTransferPage({super.key});

  @override
  _BankTransferPageState createState() => _BankTransferPageState();
}

class _BankTransferPageState extends State<BankTransferPage> {
  //final PaymentController _paymentController = PaymentController();
  File? _receiptFile;

  Future<void> _pickReceipt() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _receiptFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay with Bank Transfer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _receiptFile != null
                ? Image.file(_receiptFile!)
                : const Text('No receipt selected'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickReceipt,
              child: const Text('Attach Receipt'),
            ),
            const SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: _receiptFile != null
            //       ? () async {
            //           bool success = await _paymentController.processBankTransfer(_receiptFile!, 'studentId');
            //           if (success) {
            //             // Submit check-in application
            //             // Navigate to success page
            //           } else {
            //             // Show error message
            //           }
            //         }
            //       : null,
            //   child: const Text('Submit Payment'),
            // ),
          ],
        ),
      ),
    );
  }
}
