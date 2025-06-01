import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:shop_app/orders/models/order.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/authorization/models/sign-in/login/login_request.dart';
import 'package:shop_app/authorization/models/sign-in/otp/request_otp.dart';
import 'package:shop_app/authorization/pages/verification_page.dart';
import 'package:shop_app/authorization/provider/authorization_provider.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shop_app/authorization/custom_widgets/custom_painter.dart';
import 'package:shop_app/authorization/pages/sign_up_step1.dart';
import 'package:shop_app/dash_board/pages/dash_board.dart';
import 'package:shop_app/orders/pages/returned_order.dart';
import 'package:shop_app/orders/pages/selected_order.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({this.message, super.key});
  final RemoteMessage? message;
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  late AuthorizationProvider authorizationProvider;
  bool _showOtpField = false;
  bool _showResendOtp = false;
  int _timerSeconds = 60;
  Timer? _timer;
  bool _isLoading = false;
  void _startOtpTimer() {
    setState(() {
      _showOtpField = true;
      _showResendOtp = false;
      _timerSeconds = 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        setState(() {
          _showResendOtp = true;
        });
        _timer?.cancel();
      }
    });
  }

  void _sendOtp() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid phone number."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    } else {
      try {
        setState(() {
          _isLoading = true;
        });
        RequestOtp requestOtp =
            RequestOtp(mobile: _phoneController.text.trim());
        String? message = await authorizationProvider.requestOtp(requestOtp);

        if (message == 'OTP sent successfully') {
          _isLoading = false;
          _startOtpTimer();
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  message ?? 'Failed to send otp, please try again',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (_isLoading) {
          setState(() {
            _isLoading = false;
          });
        }
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
  }

  void _verifyOtpAndLogin() async {
    String enteredOtp =
        _otpControllers.map((controller) => controller.text).join();
    if (enteredOtp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 6-digit OTP."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    } else {
      try {
        setState(() {
          _isLoading = true;
        });
        LoginRequest loginRequest = LoginRequest(
            mobileNumber: _phoneController.text.trim(), otp: enteredOtp);
        String? message = await authorizationProvider.login(loginRequest);
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          if (message == 'Login successful') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashBoard()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  message ?? 'Failed to Login',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (_isLoading) {
          setState(() {
            _isLoading = false;
          });
        }
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
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (widget.message != null) {
          widget.message!.data['type'] == 'new_order'
              ? Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectedOrder(
                        orders: OrderData(
                            orderId: 0,
                            shopId: 0,
                            customerId: 0,
                            status: '',
                            total: 0,
                            items: [],
                            customerOfOrder: CustomerOfOrder(
                                id: 0, name: '', mobileNumber: '', email: '')),
                        orderIndex: 0,
                        orderId: int.parse(widget.message!.data['orderId'])),
                  ),
                  (Route<dynamic> route) => false,
                )
              : Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReturnedOrder(
                        orders: OrderData(
                            orderId: 0,
                            shopId: 0,
                            customerId: 0,
                            status: '',
                            total: 0,
                            items: [],
                            customerOfOrder: CustomerOfOrder(
                                id: 0, name: '', mobileNumber: '', email: '')),
                        orderIndex: 0,
                        orderId: int.parse(widget.message!.data['orderId'])),
                  ),
                  (Route<dynamic> route) => false,
                );
        } else {
          await authorizationProvider.getShopIdAndVerificationStatus();
          if (authorizationProvider.shopId != null &&
              authorizationProvider.statusOfRegistration != true) {
            setState(() {
              _isLoading = true;
            });
            await authorizationProvider.verificationStatus();
            setState(() {
              _isLoading = false;
            });
            if (authorizationProvider.statusOfRegistration != true) {
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => VerifyingScreen()),
                );
              }
            }
          }
        }
      } catch (e) {
        if (_isLoading) {
          setState(() {
            _isLoading = false;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    authorizationProvider = Provider.of<AuthorizationProvider>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 200),
                painter: RPSCustomPainter(),
              ),
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login As Shop Owner',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 33,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Please sign in to continue',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
//                  const SizedBox(height: 00),

                    // Show either the Mobile Number field OR the OTP Input field
                    _showOtpField
                        ? _buildOtpInputField()
                        : _buildMobileNumberField(),

                    const SizedBox(height: 12),

                    // Send OTP / Login Button
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.black)
                        : GestureDetector(
                            onTap:
                                _showOtpField ? _verifyOtpAndLogin : _sendOtp,
                            child: Container(
                              height: 50,
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 255, 196, 10),
                                    Color.fromARGB(255, 255, 196, 10),
                                  ],
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _showOtpField ? "Login" : "Send OTP",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.arrow_forward,
                                      color: Colors.white),
                                ],
                              ),
                            ),
                          ),

                    if (_showOtpField) ...[
                      const SizedBox(height: 24),
                      if (!_showResendOtp)
                        Text(
                          'Resend OTP in $_timerSeconds seconds',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      if (_showResendOtp)
                        TextButton(
                          onPressed: _sendOtp,
                          child: const Text(
                            'Resend OTP',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                    ],
                    const SizedBox(height: 150),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpStep1()),
                            );
                          },
                          child: const Text(
                            " Sign up",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 255, 196, 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNumberField() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(3, 3),
            blurRadius: 6,
            color: Colors.grey.shade400,
          ),
        ],
      ),
      child: TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 14),
          prefixIcon: Icon(Icons.phone_outlined),
          hintText: 'Enter your mobile number',
        ),
      ),
    );
  }

  Widget _buildOtpInputField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        6,
        (index) => Flexible(
          child: Container(
            // width: 40,
            // height: 45,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey, width: 1.25),
            ),
            child: TextFormField(
              controller: _otpControllers[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 1,
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                if (value.isNotEmpty && index < 5) {
                  FocusScope.of(context).nextFocus();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
