import 'package:flutter/material.dart';
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shop_app/custom_widgets/no_internet.dart';
import 'package:shop_app/main.dart';

class NetworkListener {
  late StreamSubscription<List<ConnectivityResult>> subscription;
  bool isOffline = false;

  void checkInternet() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      bool hasInternet = result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile);

      if (!hasInternet) {
        isOffline = true;

        _navigateToNoInternet();
      } else {
        isOffline = false;
        if (navigatorKey.currentContext != null) {
          Navigator.popUntil(navigatorKey.currentContext!,
                  (route) => route.isFirst); // Go back to main screen
        }
      }
    });
  }

  void _navigateToNoInternet() {
    Navigator.of(navigatorKey.currentContext!).push(
      MaterialPageRoute(
        builder: (context) => NoInternetPage(onRetry: () {
          checkInternet();
        }),
      ),
    );
  }

  void dispose() {
    subscription.cancel();
  }
}
