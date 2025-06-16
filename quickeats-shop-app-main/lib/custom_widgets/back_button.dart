import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shop_app/services/dialog_service.dart';

class CustomBackArrow extends StatelessWidget {
  final bool? isExitNeeded;

  const CustomBackArrow({this.isExitNeeded, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (isExitNeeded == true) {
          await showMessageDialog('Are you sure you want to exit?',
              titleText: 'Exit App', yesFunction: () {
            exit(0);
          }, needOkCanselButton: true);
        } else {
          Navigator.pop(context); // Navigate back
        }
      },
      child: Container(
        width: 40,
        height: 50,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 255, 196, 10), // Yellow circle background
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back,
            color: Colors.white), // Back arrow icon
      ),
    );
  }
}
