import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/custom_widgets/back_button.dart';
import 'package:shop_app/orders/pages/view_all_orders.dart';
import 'package:shop_app/products/pages/view_all_products.dart';
import 'package:shop_app/dash_board/pages/dash_board.dart';
import 'package:shop_app/shop profile/pages/shop_profile.dart';
import 'package:shop_app/banking/provider/shop_wallet_provider.dart';

class ShopWalletScreen extends StatefulWidget {
  const ShopWalletScreen({super.key});

  @override
  State<ShopWalletScreen> createState() => _ShopWalletScreenState();
}

class _ShopWalletScreenState extends State<ShopWalletScreen> {
  int _selectedIndex = 3;
  late ShopWalletProvider shopWalletProvider;
  bool _isLoading = false;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashBoard()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ViewAllProducts()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ViewAllOrders()),
      );
    } else if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ShopProfileScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        setState(() {
          _isLoading = true;
        });
        await shopWalletProvider.getShopWallet();

        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        if (_isLoading) {
          setState(() {
            _isLoading = false;
          });
        }
        if (kDebugMode) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    shopWalletProvider = Provider.of<ShopWalletProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.black))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10),
                    child: Row(
                      children: [
                        CustomBackArrow(isExitNeeded: true),
                        const SizedBox(width: 10),
                        const Text(
                          "Shop Wallet",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Earnings Overview
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildInfoTile(
                                  "Total Earnings",
                                  "Rs${shopWalletProvider.shopWallet?.totalEarnings ?? '0'}",
                                  Icons.attach_money),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildInfoTile(
                                  "Returned Value",
                                  "Rs${shopWalletProvider.shopWallet?.returnedCanceledValue ?? '0'}",
                                  Icons.refresh),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildInfoTile(
                                  "Withdrawn",
                                  "Rs${shopWalletProvider.shopWallet?.receivedAmount ?? '0'}",
                                  Icons.account_balance),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildInfoTile(
                                  "Pending Balance",
                                  "Rs${shopWalletProvider.shopWallet?.pendingAmount ?? '0'}",
                                  Icons.lock),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Latest Transactions",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  shopWalletProvider.shopWallet?.latestOrders == null ||
                          shopWalletProvider.shopWallet!.latestOrders!.isEmpty
                      ? Center(
                          child: Text('No items available',
                              style:
                                  TextStyle(color: Colors.red, fontSize: 16)))
                      : Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListView.builder(
                              itemCount: shopWalletProvider
                                  .shopWallet?.latestOrders?.length,
                              itemBuilder: (context, index) {
                                return _buildTransactionItem(
                                  'Order #${shopWalletProvider.shopWallet?.latestOrders?[index].id}',
                                  shopWalletProvider.shopWallet
                                          ?.latestOrders?[index].totalPrice
                                          .toString() ??
                                      '0',
                                );
                              },
                            ),
                          ),
                        ),
                ],
              ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shop),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Shop Profile',
            ),
          ],
          selectedItemColor: const Color.fromARGB(255, 255, 196, 10),
          unselectedItemColor: Colors.black,
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.black, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 196, 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String title, String amount,
      {bool isRefund = false}) {
    Color textColor = isRefund ? Colors.red : Colors.black;

    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      trailing: Text(
        amount,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
