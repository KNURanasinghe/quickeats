import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/products/models/product.dart';
import 'package:shop_app/products/provider/product_provider.dart';
import 'package:shop_app/services/dialog_service.dart';
import 'package:shop_app/custom_widgets/back_button.dart';

class EditProduct extends StatefulWidget {
  final ProductDataOfProductResponse product;
  final int index;

  const EditProduct({super.key, required this.index, required this.product});

  @override
  EditProductState createState() => EditProductState();
}

class EditProductState extends State<EditProduct> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late TextEditingController _quantityController;
  String? _selectedCategory;
  final bool _inStock = true;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _imageUrlController = TextEditingController(text: widget.product.imageUrl);
    _quantityController =
        TextEditingController(text: widget.product.quantity.toString());
    _selectedCategory = 'n/a';
  }

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
                  "Edit Product",
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
                    _buildTextField(_nameController, 'Product Name',
                        Icons.production_quantity_limits),
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
                    _buildTextField(
                        _imageUrlController, 'Image URL', Icons.image),
                    const SizedBox(height: 12),
                    _buildTextField(
                        _quantityController, 'Quantity', Icons.numbers,
                        isNumber: true,
                        textInputFormatter: [
                          FilteringTextInputFormatter.digitsOnly
                        ]),
/*
                    const SizedBox(height: 12),
                    _buildCategorySelector(productProvider),
*/
                    /*

                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text(
                        "In Stock",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFFFFC40A), // Orange color
                      value: _inStock,
                      onChanged: (value) {
                        setState(() {
                          _inStock = value;
                        });
                      },
                    ),
*/
                    const SizedBox(height: 20),
                    if (!_isLoading) ...[
                      GestureDetector(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              setState(() {
                                _isLoading = true;
                              });
                              Product updatedProduct = Product(
                                name: _nameController.text,
                                description: _descriptionController.text,
                                price: double.parse(_priceController.text),
                                imageUrl: _imageUrlController.text,
                                quantity: int.parse(_quantityController.text),
                              );

                              String? message = await productProvider
                                  .editProduct(updatedProduct, widget.index);
                              setState(() {
                                _isLoading = false;
                              });
                              if (message == 'Product updated successfully') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      backgroundColor: Colors.white,
                                      content: Text(
                                          "Product updated successfully!",
                                          style:
                                              TextStyle(color: Colors.black))),
                                );
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(message ??
                                          'Failed to update product')),
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
                                  content: Text(
                                    'An error occurred',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child:
                            _buildGradientButton("Submit", Icons.check_circle),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          await showMessageDialog(
                            'Are you sure to delete the product?',
                            titleText: 'Warning',
                            needOkCanselButton: true,
                            yesFunction: () async {
                              try {
                                Navigator.pop(context);
                                setState(() {
                                  _isLoading = true;
                                });
                                String? message = await productProvider
                                    .deleteProduct(widget.index);
                                setState(() {
                                  _isLoading = false;
                                });
                                if (message == 'Product deleted successfully') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        backgroundColor: Colors.white,
                                        content: Text(
                                            'Product deleted successfully!',
                                            style: TextStyle(
                                                color: Colors.black))),
                                  );

                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            message ?? 'An error occurred')),
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
                                    content: Text(
                                      e.toString(),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          );
                        },
                        child:
                            _buildDeleteButton("Delete Product", Icons.delete),
                      ),
                      const SizedBox(height: 20),
                    ] else ...[
                      CircularProgressIndicator(color: Colors.black),
                    ],
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
      child: TextFormField(
        inputFormatters: textInputFormatter,
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
          contentPadding: const EdgeInsets.all(14),
          prefixIcon: Icon(icon),
          hintText: hintText,
        ),
      ),
    );
  }

  Widget _buildCategorySelector(ProductProvider productProvider) {
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
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonFormField(
        validator: (value) =>
            _selectedCategory == null ? "Please select a category" : null,
        value: _selectedCategory,
        items: productProvider.categories.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value.toString();
          });
        },
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  Widget _buildGradientButton(String text, IconData icon) {
    return Container(
      height: 50,
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC40A), Color(0xFFFFC40A)], // Orange gradient
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 17, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(String text, IconData icon) {
    return Container(
      height: 50,
      width: 180,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 17, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: Colors.white),
        ],
      ),
    );
  }
}
