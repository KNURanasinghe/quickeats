import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/custom_widgets/image_viewer.dart';
import 'package:shop_app/custom_widgets/custom_selector.dart';
import 'package:shop_app/products/models/product.dart';
import 'package:shop_app/products/pages/add_variance.dart';
import 'package:shop_app/products/provider/product_provider.dart';
import 'package:shop_app/custom_widgets/back_button.dart';
import 'dart:io';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  AddProductState createState() => AddProductState();
}

class AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  File? _selectedImage;
  String _selectedCategory = '';
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                CustomBackArrow(),
                const SizedBox(width: 10),
                const Text(
                  "Add Product",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                        _nameController, 'Product Name', Icons.category),
                    const SizedBox(height: 12),
                    _buildTextField(_descriptionController, 'Description',
                        Icons.description,
                        isMultiline: true),
                    const SizedBox(height: 12),
                    _buildTextField(
                        _priceController, 'Price', Icons.attach_money,
                        isNumber: true,
                        textInputFormatter: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d*$'))
                        ]),
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
                          label: 'Product Image',
                          image: _selectedImage,
                          setImage: (file) {
                            setState(() {
                              _selectedImage = file;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                        _quantityController, 'Quantity', Icons.numbers,
                        isNumber: true,
                        textInputFormatter: [
                          FilteringTextInputFormatter.digitsOnly
                        ]),
                    const SizedBox(height: 12),
                    Container(
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
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: DropdownButtonHideUnderline(
                        child: CustomSelector(
                          titleText: 'Category',
                          selectedCategory: _selectedCategory,
                          categoryList: productProvider.categories,
                          onCategoryChanged: (newCategory) {
                            setState(() {
                              _selectedCategory = newCategory;
                            });
                          },
                        ),
                      ),
                    ),
/*
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text(
                        "In Stock",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      value: _inStock,
                      onChanged: (value) {
                        setState(() {
                          _inStock = value;
                        });
                      },
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFFFFC40A), // Orange color
                    ),
*/
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddVariance(
                                productId: productProvider.products.length + 1),
                          ),
                        );
                      },
                      child: const Text(
                        'Add Variance (optional)',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFFFC40A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.black)
                        : GestureDetector(
                            onTap: () async {
                              if (_formKey.currentState!.validate() &&
                                  _selectedImage != null &&
                                  _selectedCategory.isNotEmpty) {
                                // Add category validation
                                try {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  // Get category ID from the selected category name
                                  int? categoryId = productProvider
                                      .getCategoryIdByName(_selectedCategory);

                                  final product = Product(
                                    name: _nameController.text.trim(),
                                    description:
                                        _descriptionController.text.trim(),
                                    price: double.parse(
                                        _priceController.text.trim()),
                                    quantity: int.parse(
                                        _quantityController.text.trim()),
                                    categoryId: categoryId, // Add category ID
                                  );

                                  String? message = await productProvider
                                      .addProduct(product, _selectedImage!);
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  if (message ==
                                      'Product created successfully') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          backgroundColor: Colors.white,
                                          content: Text(
                                              'Product Added Successfully!',
                                              style: TextStyle(
                                                  color: Colors.black))),
                                    );
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(message ??
                                              'Failed to save product')),
                                    );
                                  }
                                } catch (e) {
                                  if (_isLoading) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('An error occurred'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                String errorMessage =
                                    "Please complete all fields";
                                if (_selectedCategory.isEmpty) {
                                  errorMessage = "Please select a category";
                                } else if (_selectedImage == null) {
                                  errorMessage =
                                      "Please select a product image";
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                            },
                            child: _buildGradientButton("Add Product"),
                          ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, IconData icon,
      {bool isNumber = false,
      bool isMultiline = false,
      List<TextInputFormatter>? textInputFormatter}) {
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
      constraints: const BoxConstraints(
        minHeight: 50,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber
            ? TextInputType.number
            : isMultiline
                ? TextInputType.multiline
                : TextInputType.text,
        maxLines: isMultiline ? 3 : 1,
        validator: (value) => value!.isEmpty ? 'This field is required' : null,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          prefixIcon: Icon(icon),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        inputFormatters: textInputFormatter,
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
          colors: [Color(0xFFFFC40A), Color(0xFFFFC40A)], // Orange gradient
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
