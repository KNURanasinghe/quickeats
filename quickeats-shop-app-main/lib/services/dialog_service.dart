import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shop_app/main.dart';

Future<bool> showMessageDialog(String message,
    {String? titleText,
    bool? needOkCanselButton,
    Function()? yesFunction,
    bool? modifyingCloseButtonText}) async {
  return await showDialog<bool>(
        context: navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize:
                  MainAxisSize.min, // Ensures the dialog.dart fits content properly
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Aligns text to the left
              children: [
                Text(titleText ?? 'OOPS!',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(
                    height: 8), // Adds spacing between title and message
                Text(message),
              ],
            ),
            actions: [
              if (needOkCanselButton == true) ...[
                TextButton(
                  onPressed: yesFunction,
                  child: const Text('Yes'),
                ),
              ],
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(needOkCanselButton == true
                    ? 'No'
                    : modifyingCloseButtonText == true
                        ? 'Receive returned order'
                        : 'Close'),
              ),
            ],
          );
        },
      ) ??
      false;
}

void showImage({required File image}) {
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (context) => Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Center(
          child: Image.file(
            image,
            fit: BoxFit.contain,
          ),
        ),
      ),
    ),
  );
}

Future<bool?> showOrderDialog(BuildContext context, String title,
    String content, VoidCallback acceptFunction) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          children: [
            Text(content),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child:
                    const Text('Decline', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: acceptFunction,
                child: Text('Accept'),
              ),
            ],
          ),
        ],
      );
    },
  );
}
