import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/banking/pages/shop_wallet.dart';
import 'package:shop_app/custom_widgets/back_button.dart';
import 'package:shop_app/dash_board/pages/dash_board.dart';
import 'package:shop_app/orders/pages/view_all_orders.dart';
import 'package:shop_app/products/pages/view_all_products.dart';
import 'package:shop_app/shop profile/provider/shop_provider.dart';
import 'package:shop_app/shop profile/setting/edit_profile.dart';

class ShopProfileScreen extends StatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  ShopProfileScreenState createState() => ShopProfileScreenState();
}

class ShopProfileScreenState extends State<ShopProfileScreen> {
  int _selectedIndex = 4;
  late ShopProvider shopProvider;
  bool _isLoading = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const DashBoard()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => ViewAllProducts()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => ViewAllOrders()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => ShopWalletScreen()));
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _isLoading = true);
      final message = await shopProvider.getShopProfile();
      setState(() => _isLoading = false);
      if (message != 'success') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message ?? 'Shop Profile details are not found'),
          backgroundColor: Colors.red,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    shopProvider = Provider.of<ShopProvider>(context);
    final shop = shopProvider.shop?.shopData?[0];

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CustomBackArrow(isExitNeeded: true),
                          const SizedBox(width: 10),
                          const Text(
                            "Shop Profile",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        onSelected: (String value) {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfile(),
                              ),
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Edit Shop Profile'),
                          ),
                        ],
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        image: (shop != null &&
                                shop.banner != null &&
                                shop.banner!.isNotEmpty)
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(shop.banner!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: shop == null ||
                              shop.banner == null ||
                              shop.banner!.isEmpty
                          ? const Center(
                              child: Text('No Banner Image',
                                  style: TextStyle(color: Colors.black54)))
                          : null,
                    ),
                  ],
                ),
                Transform.translate(
                  offset: const Offset(0, -60),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundImage: (shop != null &&
                                  shop.image != null &&
                                  shop.image!.isNotEmpty)
                              ? CachedNetworkImageProvider(shop.image!)
                              : const AssetImage('assets/images/shop_image.png')
                                  as ImageProvider,
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: Center(
                    child: Text(shop?.shopName ?? 'N/A',
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.0)),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Transform.translate(
                      offset: const Offset(0, -20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabeledIconRow(
                              Icons.category, "Category", shop?.category),
                          SizedBox(
                            height: 5,
                          ),
                          _buildLabeledIconRow(Icons.description, "Description",
                              shop?.description),
                          SizedBox(
                            height: 5,
                          ),
                          _buildLabeledIconRow(
                              Icons.location_on, "Address", shop?.address),
                          SizedBox(
                            height: 5,
                          ),
                          const Divider(thickness: 1, color: Colors.grey),
                          Card(
                            color: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Color.fromARGB(255, 255, 196, 10),
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Shop Owner Details",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildContactDetail(Icons.person, "Name",
                                      shop?.ownerName ?? 'N/A'),
                                  _buildContactDetail(Icons.email, "Email",
                                      shop?.email ?? 'N/A'),
                                  _buildContactDetail(Icons.phone, "Phone",
                                      shop?.mobile ?? 'N/A'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.white),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Products'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: 'Orders'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'Shop Profile'),
          ],
          selectedItemColor: const Color(0xFFFFC40A),
          unselectedItemColor: Colors.black,
        ),
      ),
    );
  }

  Widget _buildLabeledIconRow(IconData icon, String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Text(
            "$title: ",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Flexible(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 17, color: Colors.grey)),
      ]),
    );
  }

  Widget _buildContactDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Text(value,
                style: const TextStyle(fontSize: 17, color: Colors.black54)),
          ]),
        ],
      ),
    );
  }
}
