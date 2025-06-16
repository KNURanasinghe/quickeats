import 'package:flutter/material.dart';

class NoInternetPage extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetPage({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 80, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                "No Internet Connection",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                child: Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
