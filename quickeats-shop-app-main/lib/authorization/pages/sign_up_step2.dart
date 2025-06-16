import 'package:provider/provider.dart';
import 'package:shop_app/authorization/models/register/shop_details.dart';
import 'package:shop_app/authorization/provider/authorization_provider.dart';
import 'package:shop_app/services/date_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/authorization/custom_widgets/custom_painter.dart';
import 'package:shop_app/authorization/custom_widgets/custom_text_field.dart';
import 'package:shop_app/custom_widgets/custom_backarrow.dart';
import 'package:shop_app/authorization/pages/sign_up_step3.dart';

class SignUpStep2 extends StatefulWidget {
  const SignUpStep2({super.key});

  @override
  State<SignUpStep2> createState() => _SignUpStep2State();
}

class _SignUpStep2State extends State<SignUpStep2> {
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  TimeOfDay? openTime;
  TimeOfDay? closeTime;
  late AuthorizationProvider authorizationProvider;
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  void _validateAndProceed() async {
    if (_formKey.currentState!.validate() &&
        openTime != null &&
        closeTime != null) {
      try {
        setState(() {
          _isLoading = true;
        });
        ShopDetails shopDetails = ShopDetails(
            shopId: authorizationProvider.shopId!,
            name: shopNameController.text.trim(),
            address: addressController.text.trim(),
            selectedCategory: categoryController.text.trim(),
            openTime:
                '${openTime!.hour.toString().padLeft(2, '0')}:${openTime!.minute.toString().padLeft(2, '0')}',
            closeTime:
                '${closeTime!.hour.toString().padLeft(2, '0')}:${closeTime!.minute.toString().padLeft(2, '0')}',
            description: descriptionController.text.trim());
        String? message =
            await authorizationProvider.step2ShopDetails(shopDetails);
        setState(() {
          _isLoading = false;
        });

        if (message == 'Shop details added successfully') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SignUpStep3(),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message ?? 'Details added successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  message ?? 'Failed to save shop details.',
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpStep3(),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please complete all fields',
          ),
          backgroundColor: Colors.red,
        ),
      );
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

              // Content shifted up
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
                      'Enter your shop details',
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
                            controller: shopNameController,
                            hintText: 'Shop Name',
                            icon: Icons.storefront,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: addressController,
                            hintText: 'Address',
                            icon: Icons.location_on,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: descriptionController,
                            hintText: 'Description',
                            icon: Icons.description,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: categoryController,
                            hintText: 'Category',
                            icon: Icons.category,
                          ),
                          const SizedBox(height: 24),
                          _buildTimeBox('Open Time', openTime, true),
                          const SizedBox(height: 12),
                          _buildTimeBox('Close Time', closeTime, false),
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

  Widget _buildTimeBox(String label, TimeOfDay? time, bool isOpeningTime) {
    return GestureDetector(
      onTap: () async {
        await selectTime((date) {
          setState(() {
            if (isOpeningTime) {
              openTime = date;
            } else {
              closeTime = date;
            }
          });
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.grey.shade400,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(time?.format(context) ?? label),
            const Icon(Icons.access_time),
          ],
        ),
      ),
    );
  }
}
