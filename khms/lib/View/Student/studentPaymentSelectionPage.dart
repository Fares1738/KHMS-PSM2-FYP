// import 'package:flutter/material.dart';
// import 'package:khms/View/Student/bankTransferPage.dart';
// import 'package:khms/View/Student/stripePaymentPage.dart';

// class PaymentSelectionPage extends StatelessWidget {
//   const PaymentSelectionPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Select Payment Method'),
//       ),
//       body: ListView(
//         // Use ListView for better scrolling behavior
//         children: [
//           ListTile(
//             // ListTile for Stripe

//             title: const Text('Pay with Card'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => const StripePaymentPage()),
//               );
//             },
//           ),
//           const Divider(), // Add a divider for separation
//           ListTile(
//             // ListTile for Bank Transfer

//             title: const Text('Pay with Bank Transfer'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => const BankTransferPage()),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
