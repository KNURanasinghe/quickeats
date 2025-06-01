import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/shop profile/provider/shop_provider.dart';
import 'package:shop_app/custom_widgets/custom_backarrow.dart';
import 'package:shop_app/custom_widgets/custom_textfield.dart';
import 'package:shop_app/custom_widgets/custom_button.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController _shopNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _ownerController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  File? _pickedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final shopData =
        Provider.of<ShopProvider>(context, listen: false).shop?.shopData?[0];
    _shopNameController =
        TextEditingController(text: shopData?.shopName ?? 'N/A');
    _descriptionController =
        TextEditingController(text: shopData?.description ?? 'N/A');
    _addressController = TextEditingController(text: shopData?.address ?? '');
    _ownerController = TextEditingController(text: shopData?.ownerName ?? '');
    _emailController = TextEditingController(text: shopData?.email ?? '');
    _phoneController = TextEditingController(text: shopData?.mobile ?? '');
  }

  Future<void> _pickImage(bool isBanner) async {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? pickedFile =
                    await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  _uploadImage(File(pickedFile.path), isBanner);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  _uploadImage(File(pickedFile.path), isBanner);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadImage(File file, bool isBanner) async {
    setState(() => _isLoading = true);
    final result = await Provider.of<ShopProvider>(context, listen: false)
        .updateShopImage(file: file, isBanner: isBanner);
    setState(() {
      _isLoading = false;
      if (!isBanner) _pickedImage = file;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result
          ? '${isBanner ? 'Banner' : 'Profile'} image updated'
          : 'Failed to update image'),
      backgroundColor: result ? Colors.green : Colors.red,
    ));
  }

  void _saveProfile() async {
    setState(() => _isLoading = true);

    final success = await Provider.of<ShopProvider>(context, listen: false)
        .updateShopDetails(
      shopName: _shopNameController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      ownerName: _ownerController.text.trim(),
      email: _emailController.text.trim(),
      mobile: _phoneController.text.trim(),
    );

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Profile updated successfully!'
            : 'Failed to update profile'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) Navigator.pop(context);
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _ownerController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Widget _editIcon(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.black.withOpacity(0.7),
        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context);
    final shopData = shopProvider.shop?.shopData?[0];
    final existingImage = shopData?.image ?? '';
    final bannerImage = shopData?.banner ?? '';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        CustomBackArrow(),
                        const SizedBox(width: 10),
                        const Text("Edit Profile",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraints.maxHeight),
                          child: IntrinsicHeight(
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 180,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        image: (bannerImage.isNotEmpty)
                                            ? DecorationImage(
                                                image:
                                                    NetworkImage(bannerImage),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: bannerImage.isEmpty
                                          ? const Center(
                                              child: Text('No Banner Image',
                                                  style: TextStyle(
                                                      color: Colors.black54)))
                                          : null,
                                    ),
                                    Positioned(
                                      right: 10,
                                      top: 10,
                                      child: _editIcon(() => _pickImage(true)),
                                    ),
                                  ],
                                ),
                                Transform.translate(
                                  offset: const Offset(0, -60),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          CircleAvatar(
                                            radius: 60,
                                            backgroundColor: Colors.white,
                                            child: CircleAvatar(
                                              radius: 55,
                                              backgroundImage: _pickedImage !=
                                                      null
                                                  ? FileImage(_pickedImage!)
                                                  : (existingImage.isNotEmpty
                                                      ? NetworkImage(
                                                          existingImage)
                                                      : const AssetImage(
                                                              'assets/images/shop_image.png')
                                                          as ImageProvider),
                                              backgroundColor: Colors.grey[300],
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 4,
                                            right: 4,
                                            child: _editIcon(
                                                () => _pickImage(false)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Column(
                                    children: [
                                      CustomTextField(
                                        controller: _shopNameController,
                                        hintText: "Shop Name",
                                        icon: Icons.storefront_outlined,
                                      ),
                                      const SizedBox(height: 10),
                                      CustomTextField(
                                        controller: _descriptionController,
                                        hintText: "Description",
                                        icon: Icons.description_outlined,
                                      ),
                                      const SizedBox(height: 10),
                                      CustomTextField(
                                        controller: _addressController,
                                        hintText: "Address",
                                        icon: Icons.location_on_outlined,
                                      ),
                                      const SizedBox(height: 10),
                                      CustomTextField(
                                        controller: _ownerController,
                                        hintText: "Owner Name",
                                        icon: Icons.person_outline,
                                      ),
                                      const SizedBox(height: 10),
                                      CustomTextField(
                                        controller: _emailController,
                                        hintText: "Email",
                                        icon: Icons.email_outlined,
                                      ),
                                      const SizedBox(height: 10),
                                      CustomTextField(
                                        controller: _phoneController,
                                        hintText: "Phone no",
                                        icon: Icons.phone_outlined,
                                        keyboardType: TextInputType.phone,
                                      ),
                                      const SizedBox(height: 30),
                                      CustomGradientButton(
                                        text: "Save",
                                        onPressed: _saveProfile,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
