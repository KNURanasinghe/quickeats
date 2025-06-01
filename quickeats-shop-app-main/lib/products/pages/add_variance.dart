import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/products/models/variance.dart';
import 'package:shop_app/products/provider/product_provider.dart';
import 'package:shop_app/custom_widgets/image_viewer.dart';
import 'package:shop_app/custom_widgets/back_button.dart';
import 'dart:io';

class AddVariance extends StatefulWidget {
  final int productId;
  const AddVariance({required this.productId, super.key});

  @override
  AddVarianceState createState() => AddVarianceState();
}

class AddVarianceState extends State<AddVariance> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _image;

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Row(
              children: [
                CustomBackArrow(),
                const SizedBox(width: 10),
                const Text(
                  "Add Variance",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_nameController, 'Variance Name', Icons.category),
                  const SizedBox(height: 12),
                  _buildTextField(_descriptionController, 'Description', Icons.description, isMultiline: true),
                  const SizedBox(height: 12),
                  _buildTextField(_priceController, 'Price', Icons.attach_money, isNumber: true),
                  const SizedBox(height: 12),
                  
                  
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(3, 3),
                          blurRadius: 6,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ImageViewer(
                        label: 'Variance Image',
                        image: _image,
                        setImage: (file) {
                          setState(() {
                            _image = file;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        Variance variance = Variance(
                          productId: widget.productId,
                          varianceName: _nameController.text.trim(),
                          description: _descriptionController.text.trim(),
                          price: int.parse(_priceController.text.trim()),
                          imageUrl: 'x',
                        );
                        productProvider.addVariance(variance);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Variance Added Successfully!')),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: _buildGradientButton("Add Variance"),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText,
    IconData icon, {
    bool isNumber = false,
    bool isMultiline = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(3, 3),
            blurRadius: 6,
            color: Colors.grey.shade400,
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : isMultiline ? TextInputType.multiline : TextInputType.text,
        maxLines: isMultiline ? 3 : 1,
        validator: (value) => value!.isEmpty ? 'This field is required' : null,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
          prefixIcon: Icon(icon),
          hintText: hintText,
        ),
      ),
    );
  }

  Widget _buildGradientButton(String text) {
    return Container(
      height: 50,
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC40A), Color(0xFFFFC40A)], 
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 17,
          color: Colors.white,
        ),
      ),
    );
  }
}
