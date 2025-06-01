import 'package:shop_app/custom_widgets/custom_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/authorization/custom_widgets/custom_painter.dart';
import 'package:shop_app/authorization/custom_widgets/custom_text_field.dart';
import 'package:shop_app/authorization/models/register/bank_details.dart';
import 'package:shop_app/authorization/pages/verification_page.dart';
import 'package:shop_app/authorization/provider/authorization_provider.dart';
import 'package:shop_app/custom_widgets/custom_backarrow.dart';

class SignUpStep4 extends StatefulWidget {
  const SignUpStep4({super.key});

  @override
  State<SignUpStep4> createState() => _SignUpStep4State();
}

class _SignUpStep4State extends State<SignUpStep4> {
  final TextEditingController accountHolderController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController branchNameController = TextEditingController();
  late AuthorizationProvider authorizationProvider;
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedBankName;
  void _finishProcess() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        BankDetails bankDetails = BankDetails(
            shopId: authorizationProvider.shopId!,
            accountHolder: accountHolderController.text.trim(),
            accountNumber: accountNumberController.text.trim(),
            bankName: _selectedBankName!,
            branchName: branchNameController.text.trim());
        String? message =
            await authorizationProvider.step4BankDetails(bankDetails);
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          if (message == 'Bank details created successfully') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => VerifyingScreen()),
              (Route<dynamic> route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  message ?? 'Failed to save bank details.',
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
        /*ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An error occurred',
            ),
            backgroundColor: Colors.red,
          ),
        );*/
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => VerifyingScreen()),
          (Route<dynamic> route) => false,
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
              // CustomPaint and BackArrow
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: CustomPaint(
                        size: Size(MediaQuery.of(context).size.width, 200),
                        painter: RPSCustomPainter(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: CustomBackArrow(),
                    ),
                  ],
                ),
              ),

              // Shift content upward
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
                      'Enter your bank details below',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: accountHolderController,
                            hintText: 'Account Holder Name',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: accountNumberController,
                            hintText: 'Account Number',
                            icon: Icons.confirmation_number,
                            keyboardType: TextInputType.number,
                            filteringTextInputFormatter: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                          const SizedBox(height: 12),
                          CustomSelector(
                            titleText: 'Select Bank',
                            selectedCategory: _selectedBankName == null
                                ? ''
                                : _selectedBankName!,
                            categoryList: authorizationProvider.bankNames,
                            onCategoryChanged: (newCategory) {
                              setState(() {
                                _selectedBankName = newCategory;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: branchNameController,
                            hintText: 'Branch Name',
                            icon: Icons.location_on,
                          ),
                          const SizedBox(height: 24),
                          _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.black)
                              : GestureDetector(
                                  onTap: _finishProcess,
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
                                          "Finished",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 17,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Icon(Icons.check_circle,
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
