import 'package:flutter/material.dart';
import 'package:shop_app/authorization/pages/login.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/authorization/provider/authorization_provider.dart';

class VerifyingScreen extends StatefulWidget {
  const VerifyingScreen({super.key});

  @override
  VerifyingScreenState createState() => VerifyingScreenState();
}

class VerifyingScreenState extends State<VerifyingScreen> {
  bool isVerificationComplete = false;
  late AuthorizationProvider authorizationProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      verify();
    });
  }

  void verify() async {
    try {
      await authorizationProvider.verificationStatus();
      if (authorizationProvider.statusOfRegistration == true) {
        if (mounted) {
          setState(() {
            isVerificationComplete = true;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    authorizationProvider = Provider.of<AuthorizationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: isVerificationComplete
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'All Details Submitted!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(50, 50, 50, 1.0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Icon(
                      Icons.check_circle,
                      size: 150,
                      color: Color.fromARGB(255, 255, 196, 10),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'You have  submitted and verified all documents    successfully.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(80, 80, 80, 1.0),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen(message: null)),
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 196, 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        'Login To Continue',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(255, 255, 255, 1.0),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Verifying your documents...',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(50, 50, 50, 1.0),
                      ),
                      textAlign: TextAlign.center,
                    ),
/*
                    const SizedBox(height: 10),
                    CircularProgressIndicator(color: Colors.blue),
*/
                    const SizedBox(height: 20),
                    Text(
                      'This may take a few moments',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(80, 80, 80, 1.0),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
