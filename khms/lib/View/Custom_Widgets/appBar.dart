// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:khms/Controller/userController.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<UserController>(
        context); // Use the context to get the controller. If you are not using Provider, you will need to pass the controller manually through the tree

    return AppBar(
      title: const Text(
        "KHMS",
        style: TextStyle(fontSize: 28),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            controller.signOutUser(context);
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
