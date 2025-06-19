// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shop_app/dash_board/pages/dash_board.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shop_app/services/network_listener.dart';
// import 'package:shop_app/services/notification_service.dart';
// import 'package:shop_app/services/location_services.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:shop_app/authorization/provider/authorization_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shop_app/authorization/pages/login.dart';
// import 'package:shop_app/banking/provider/shop_wallet_provider.dart';
// import 'package:shop_app/orders/provider/order_provider.dart';
// import 'package:shop_app/products/provider/product_provider.dart';
// import 'package:shop_app/shop%20profile/provider/shop_provider.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//   RemoteMessage? message;

//   String? token;
//   message = await FirebaseMessaging.instance.getInitialMessage();
//   await NotificationService().initializeNotifications();
//   if (await Permission.notification.isDenied) {
//     await Permission.notification.request();
//   }
//   await LocationServices().requestPermission();
//   if (message == null) {
//     token = sharedPreferences.getString('token');
//   }
//   runApp(MyApp(token: token, message: message));
//   NetworkListener().checkInternet();
// }

// class MyApp extends StatelessWidget {
//   final RemoteMessage? message;
//   final String? token;
//   const MyApp({super.key, this.token, this.message});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => ProductProvider()),
//         ChangeNotifierProvider(create: (_) => OrderProvider()),
//         ChangeNotifierProvider(create: (_) => ShopWalletProvider()),
//         ChangeNotifierProvider(create: (_) => AuthorizationProvider()),
//         ChangeNotifierProvider(create: (_) => ShopProvider()),
//       ],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         navigatorKey: navigatorKey,
//         title: 'QE Shop',
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//           useMaterial3: true,
//           fontFamily: 'urbanist',
//         ),
//         home: token == null ? LoginScreen(message: message) : DashBoard(),
//       ),
//     );
//   }
// }

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/authorization/pages/verification_page.dart';
import 'package:shop_app/dash_board/pages/dash_board.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shop_app/services/network_listener.dart';
import 'package:shop_app/services/notification_service.dart';
import 'package:shop_app/services/location_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shop_app/authorization/provider/authorization_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/authorization/pages/login.dart';
import 'package:shop_app/banking/provider/shop_wallet_provider.dart';
import 'package:shop_app/orders/provider/order_provider.dart';
import 'package:shop_app/products/provider/product_provider.dart';
import 'package:shop_app/shop%20profile/provider/shop_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  RemoteMessage? message;
  String? token;
  AuthorizationProvider authorizationProvider = AuthorizationProvider();
  message = await FirebaseMessaging.instance.getInitialMessage();
  print('Initial message: $message');
  await NotificationService().initializeNotifications();
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
  await LocationServices().requestPermission();
  if (message == null) {
    token = sharedPreferences.getString('token');
    print('Token from SharedPreferences: $token');
  }
  token = sharedPreferences.getString('token');

  // Get verification status
  bool? isVerified = sharedPreferences.getBool('verification status');
  print('Verification status: $isVerified');

  runApp(MyApp(token: token, message: message, isVerified: isVerified));
}

class MyApp extends StatelessWidget {
  final RemoteMessage? message;
  final String? token;
  final bool? isVerified; // Add isVerified to check verification status
  const MyApp({super.key, this.token, this.message, this.isVerified});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ShopWalletProvider()),
        ChangeNotifierProvider(create: (_) => AuthorizationProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        title: 'QE Shop',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          fontFamily: 'urbanist',
        ),
        home: _getHomeScreen(), // Determine the home screen
      ),
    );
  }

  Widget _getHomeScreen() {
    // If not verified, go to VerifyingScreen
    if (isVerified == false) {
      return VerifyingScreen();
    }
    // If verified or verification status not set, check token
    return token == null ? LoginScreen(message: message) : DashBoard();
  }
}
