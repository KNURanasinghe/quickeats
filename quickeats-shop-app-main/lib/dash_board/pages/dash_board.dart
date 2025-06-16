import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shop_app/custom_widgets/search_bar.dart';
import 'package:shop_app/dash_board/pages/drawer_menu.dart';
import 'package:shop_app/orders/pages/view_all_orders.dart';
import 'package:shop_app/products/provider/product_provider.dart';
import 'package:shop_app/services/firebase_message_service.dart';
import 'package:shop_app/orders/pages/selected_order.dart';
import 'package:shop_app/orders/models/order.dart';
import 'package:shop_app/orders/provider/order_provider.dart';
import 'package:shop_app/banking/pages/shop_wallet.dart';
import 'package:shop_app/products/pages/view_all_products.dart';
import 'package:shop_app/shop profile/pages/shop_profile.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  int _selectedOrderTab = 0; // 0=Pending, 1=In Progress, 2=Completed
  int _selectedIndex = 0;
  late OrderProvider orderProvider;
  final FirebaseMessageService _firebaseMessageService =
      FirebaseMessageService();
  late ProductProvider productProvider;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (mounted) {
          setState(() {
            _isLoading = true;
          });

          await _firebaseMessageService.getFCMToken();
          _firebaseMessageService.initializeFCM();
          await productProvider.getAllProducts();
          await orderProvider.getAllOrders();
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          if (_isLoading) {
            setState(() {
              _isLoading = false;
            });
          }
          if (kDebugMode) {
            print('Error in initState: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('An error occurred: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    productProvider = Provider.of<ProductProvider>(context);
    orderProvider = Provider.of<OrderProvider>(context);

    // Filter orders based on search query
    Iterable<OrderData> filteredOrders = _searchController.text.isEmpty
        ? orderProvider.orderList
        : orderProvider.orderList.where((order) {
            try {
              final searchText = _searchController.text.toLowerCase();
              return order.orderId.toString().contains(searchText) ||
                  (order.customerOfOrder.name
                      .toLowerCase()
                      .contains(searchText)) ||
                  (order.customerOfOrder.mobileNumber.contains(searchText)) ||
                  (order.customerOfOrder.email
                      .toLowerCase()
                      .contains(searchText));
            } catch (e) {
              return false;
            }
          }).toList();
    List<OrderData> newOrders =
        filteredOrders.where((order) => order.status == 'PLACED').toList();
    List<OrderData> completedOrders =
        filteredOrders.where((order) => order.status == 'DELIVERED').toList();
    List<OrderData> inProgressOrders = filteredOrders
        .where((order) =>
            order.status == 'ACCEPTED' ||
            order.status == 'PREPARING' ||
            order.status == 'ON_THE_WAY')
        .toList();

    int productCount = productProvider.products.length;
    int completedCount = completedOrders.length;
    int inProgressCount = inProgressOrders.length;

    // Calculate total earnings
    double totalEarnings =
        completedOrders.fold(0, (sum, order) => sum + (order.total));

    return Scaffold(
      drawer: const DrawerMenu(),
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Shop Name',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: newOrders.isNotEmpty,
              label: Text(newOrders.length.toString()),
              child: const Icon(Icons.notifications, color: Colors.black),
            ),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchBox(
                height: 100,
                hiddenText: 'Search orders by ID, customer name',
                search: (p0) {
                  setState(() {
                    _searchController.text = p0;
                  });
                },
              ),
            ),

            // Summary Cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildSummaryCard(
                    icon: Icons.shopping_bag,
                    title: 'Products',
                    value: '$productCount',
                    subtitle: 'Available',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryCard(
                    icon: Icons.pending_actions,
                    title: 'Pending',
                    value: '${newOrders.length}',
                    subtitle: 'Orders',
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryCard(
                    icon: Icons.timer,
                    title: 'In Progress',
                    value: '$inProgressCount',
                    subtitle: 'Orders',
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryCard(
                    icon: Icons.check_circle,
                    title: 'Completed',
                    value: '$completedCount',
                    subtitle: 'Orders',
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryCard(
                    icon: Icons.attach_money,
                    title: 'Earnings',
                    value: '\$${NumberFormat.compact().format(totalEarnings)}',
                    subtitle: 'Total',
                    color: Colors.teal,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
// Order Status Tabs// Order Status Buttons
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.06,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: const Color.fromARGB(255, 0, 0, 0)
                              .withOpacity(0.2),
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Pending Button
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.048,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: _selectedOrderTab == 0
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF0D47A1), // Dark blue
                                          Color(0xFF2196F3), // Bright blue
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Color(0xFFE0E0E0), // Light gray
                                          Color(0xFFBDBDBD), // Medium gray
                                        ],
                                      ),
                                boxShadow: _selectedOrderTab == 0
                                    ? [
                                        BoxShadow(
                                          // ignore: deprecated_member_use
                                          color: Colors.blue.withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : null,
                              ),
                              child: ElevatedButton(
                                onPressed: () =>
                                    setState(() => _selectedOrderTab = 0),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _selectedOrderTab == 0
                                          ? Icons.pending_actions
                                          : Icons.pending_actions,
                                      color: _selectedOrderTab == 0
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    const SizedBox(width: 8),
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          _selectedOrderTab == 0
                                              ? const LinearGradient(
                                                  colors: [
                                                    Colors.white,
                                                    Color(0xFFBBDEFB)
                                                  ],
                                                ).createShader(bounds)
                                              : const LinearGradient(
                                                  colors: [
                                                    Colors.black87,
                                                    Color(0xFF616161)
                                                  ],
                                                ).createShader(bounds),
                                      child: const Text(
                                        'Pending',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // In Progress Button
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.048,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: _selectedOrderTab == 1
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF0D47A1), // Dark blue
                                          Color(0xFF2196F3), // Bright blue
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Color(0xFFE0E0E0), // Light gray
                                          Color(0xFFBDBDBD), // Medium gray
                                        ],
                                      ),
                                boxShadow: _selectedOrderTab == 1
                                    ? [
                                        BoxShadow(
                                          // ignore: deprecated_member_use
                                          color: Colors.blue.withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : null,
                              ),
                              child: ElevatedButton(
                                onPressed: () =>
                                    setState(() => _selectedOrderTab = 1),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _selectedOrderTab == 1
                                          ? Icons.timer
                                          : Icons.timer_outlined,
                                      size: 20,
                                      color: _selectedOrderTab == 1
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    const SizedBox(width: 8),
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          _selectedOrderTab == 1
                                              ? const LinearGradient(
                                                  colors: [
                                                    Colors.white,
                                                    Color(0xFFBBDEFB)
                                                  ], // White to light blue
                                                ).createShader(bounds)
                                              : const LinearGradient(
                                                  colors: [
                                                    Colors.black87,
                                                    Color(0xFF616161)
                                                  ], // Dark to medium gray
                                                ).createShader(bounds),
                                      child: const Text(
                                        'In Progress',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors
                                              .white, // Base color that gets masked
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Completed Button
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.048,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: _selectedOrderTab == 2
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF0D47A1),
                                          Color(0xFF1976D2)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Color(0xFFE0E0E0),
                                          Color(0xFFBDBDBD)
                                        ],
                                      ),
                                boxShadow: _selectedOrderTab == 2
                                    ? [
                                        BoxShadow(
                                          // ignore: deprecated_member_use
                                          color: Colors.blue.withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : null,
                              ),
                              child: ElevatedButton(
                                onPressed: () =>
                                    setState(() => _selectedOrderTab = 2),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _selectedOrderTab == 2
                                          ? Icons.check_circle
                                          : Icons.check_circle_outline,
                                      size: 20,
                                      color: _selectedOrderTab == 2
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    const SizedBox(width: 8),
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          _selectedOrderTab == 2
                                              ? const LinearGradient(
                                                  colors: [
                                                    Colors.white,
                                                    Color(0xFFBBDEFB)
                                                  ],
                                                ).createShader(bounds)
                                              : const LinearGradient(
                                                  colors: [
                                                    Colors.black87,
                                                    Color(0xFF616161)
                                                  ],
                                                ).createShader(bounds),
                                      child: const Text(
                                        'Completed',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors
                                              .white, // This color will be masked by the shader
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Content Area
                IndexedStack(
                  index: _selectedOrderTab,
                  children: [
                    // Pending Orders
                    _buildOrderList(
                      orders: newOrders,
                      emptyMessage: 'No pending orders',
                      isLoading: _isLoading,
                    ),

                    // In Progress Orders
                    _buildOrderList(
                      orders: inProgressOrders,
                      emptyMessage: 'No orders in progress',
                      isLoading: _isLoading,
                    ),

                    // Completed Orders
                    _buildOrderList(
                      orders: completedOrders,
                      emptyMessage: 'No completed orders yet',
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ViewAllProducts()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ViewAllOrders()),
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
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFFC40A),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard, color: Colors.black),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shop, color: Colors.black),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, color: Colors.black),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet, color: Colors.black),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList({
    required List<OrderData> orders,
    required String emptyMessage,
    required bool isLoading,
    Key? key, // Added key parameter for better widget management
  }) {
    // Always handle loading state first
    if (isLoading) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.35,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(
              color: Colors.blue, // Use theme color or your app's primary color
              strokeWidth: 2.0,
            ),
          ),
        ),
      );
    }

    // Handle empty state
    if (orders.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height *
            0.35, // Adjust height as needed
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Build the actual list
    return ListView.builder(
      key: key, // Use the provided key
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(
            order, index); // Extracted to separate method for clarity
      },
    );
  }

// Extracted order card widget for better readability
  Widget _buildOrderCard(OrderData order, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          // Handle order tap
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SelectedOrder(orders: order, orderIndex: index),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.orderId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatStatus(order.status),
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Customer: ${order.customerOfOrder.name}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PLACED':
        return Colors.orange;
      case 'ACCEPTED':
      case 'PREPARING':
        return Colors.blue;
      case 'ON_THE_WAY':
        return Colors.purple;
      case 'DELIVERED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').capitalize();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
