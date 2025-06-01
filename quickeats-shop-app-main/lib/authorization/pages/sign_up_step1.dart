import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shop_app/authorization/custom_widgets/custom_painter.dart';
import 'package:shop_app/authorization/custom_widgets/custom_text_field.dart';
import 'package:shop_app/authorization/models/register/shop_owner.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/authorization/provider/authorization_provider.dart';
import 'package:shop_app/authorization/pages/sign_up_step2.dart';
import 'package:shop_app/custom_widgets/custom_backarrow.dart';

class SignUpStep1 extends StatefulWidget {
  const SignUpStep1({super.key});

  @override
  State<SignUpStep1> createState() => _SignUpStep1State();
}

class _SignUpStep1State extends State<SignUpStep1> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController nicController = TextEditingController();
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AuthorizationProvider authorizationProvider;
  void _validateAndProceed() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        ShopOwner shopOwner = ShopOwner(
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            mobileNumber: mobileNumberController.text.trim(),
            nic: nicController.text.trim());

        String? message = await authorizationProvider.step1ShopOwner(shopOwner);
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          if (message == 'Owner registered successfully') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SignUpStep2(), // Navigate to SignUpStep2
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message ?? 'Failed to save shop owner details.'),
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

        /*ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An error occurred',
            ),
            backgroundColor: Colors.red,
          ),
        );*/
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpStep2(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    authorizationProvider = Provider.of<AuthorizationProvider>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: CustomPaint(
                      size: Size(MediaQuery.of(context).size.width, 200),
                      painter: RPSCustomPainter(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 0),
                    child: CustomBackArrow(),
                  ),
                ],
              ),
              Transform.translate(
                offset: const Offset(0, -75),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sign Up As Shop Owner',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Enter Your Personal Information',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: nameController,
                            hintText: 'Enter your Full Name',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: emailController,
                            hintText: 'Enter your Email',
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: mobileNumberController,
                            hintText: 'Enter your Mobile Number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: nicController,
                            hintText: 'Enter your NIC Number',
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                            filteringTextInputFormatter: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          const SizedBox(height: 24),
                          _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.black)
                              : GestureDetector(
                                  onTap: _validateAndProceed,
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
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Next",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 17,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Icon(Icons.arrow_forward,
                                            color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 20),
                        ],
                      ),
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
}
