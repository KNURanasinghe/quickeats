import 'package:flutter/foundation.dart';
import 'package:shop_app/products/pages/view_all_products.dart';
import 'package:shop_app/shop profile/pages/shop_profile.dart';
import 'package:shop_app/banking/pages/shop_wallet.dart';
import 'package:shop_app/dash_board/pages/dash_board.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/custom_widgets/search_bar.dart';
import 'package:shop_app/custom_widgets/back_button.dart';
import 'package:shop_app/orders/pages/selected_order.dart';
import 'package:shop_app/orders/provider/order_provider.dart';
import 'package:shop_app/services/color_service.dart';

class ViewAllOrders extends StatefulWidget {
  const ViewAllOrders({super.key});

  @override
  State<ViewAllOrders> createState() => _ViewAllOrdersState();
}

class _ViewAllOrdersState extends State<ViewAllOrders> {
  int _selectedIndex = 2;
  bool _isLoading = false;
  late OrderProvider orderProvider;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashBoard()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ViewAllProducts()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ShopWalletScreen()),
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
        String? message =
            await Provider.of<OrderProvider>(context, listen: false)
                .getAllOrders();
        setState(() {
          _isLoading = false;
        });
        if (message != 'Orders retrieved successfully') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message ?? 'No orders available',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
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
    final screenWidth = MediaQuery.of(context).size.width;
    orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth > 600 ? 24 : 16,
              vertical: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CustomBackArrow(isExitNeeded: true),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Order List",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Row(
                  children: [
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'PLACED') {
                          orderProvider.sortOrder('PLACED');
                        } else if (value == 'RETURNED_ACCEPTED') {
                          orderProvider.sortOrder('RETURNED_ACCEPTED');
                        } else if (value == 'SHOP_ACCEPT') {
                          orderProvider.sortOrder('SHOP_ACCEPT');
                        } else if (value == 'REJECTED') {
                          orderProvider.sortOrder('REJECTED');
                        } else {
                          orderProvider.sortOrder('ALL');
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'ALL',
                          child: Text('ALL'),
                        ),
                        const PopupMenuItem(
                          value: 'PLACED',
                          child: Text('PLACED'),
                        ),
                        const PopupMenuItem(
                          value: 'SHOP_ACCEPT',
                          child: Text('SHOP_ACCEPT'),
                        ),
                        const PopupMenuItem(
                          value: 'RETURNED_ACCEPTED',
                          child: Text('RETURNED_ACCEPTED'),
                        ),
                        const PopupMenuItem(
                          value: 'REJECTED',
                          child: Text('REJECTED'),
                        ),
                      ],
                      icon: const Icon(Icons.more_vert, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.black,
            thickness: 2,
            indent: 16,
            endIndent: 16,
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth > 600 ? 24 : 16,
              vertical: 8,
            ),
            child: SearchBox(
              height: 50,
              hiddenText: 'Search',
              search: (value) async {
                try {
                  setState(() {
                    _isLoading = true;
                  });
                  String? message = await orderProvider.searchOrders(value);
                  setState(() {
                    _isLoading = false;
                  });
                  if (message != 'Orders search results') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Order not found',
                        ),
                        backgroundColor: Colors.red,
                      ),
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
              },
              onChange: (value) {
                if (value.isEmpty) {
                  orderProvider.clearData();
                }
              },
            ),
          ),

          // Order list
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                final orders = orderProvider.orderList;

                return SizedBox(
                  height: 150,
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: Colors.black))
                      : orders.isEmpty
                          ? Center(
                              child: Text(
                                'No items available',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth > 600 ? 24 : 16,
                              ),
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                final order = orders.elementAt(index);

                                return Column(
                                  children: [
                                    Card(
                                      color: Colors.white,
                                      elevation: 3,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: const Color.fromARGB(
                                              255, 255, 196, 10),
                                          child: const Icon(
                                            Icons.receipt_long,
                                            color: Colors.white,
                                          ),
                                        ),
                                        title: Text('Order: ${order.orderId}'),
                                        subtitle: Text(
                                            'Customer: ${order.customerOfOrder.name}'),
                                        trailing: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'LKR ${order.total.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              order.status,
                                              style: TextStyle(
                                                color: getOrderStatusColor(
                                                    order.status),
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SelectedOrder(
                                                orders: order,
                                                orderIndex: orderProvider
                                                    .orderList
                                                    .indexOf(order),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                );
                              },
                            ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        selectedItemColor: const Color(0xFFFFC40A),
        unselectedItemColor: Colors.black,
      ),
    );
  }
}
