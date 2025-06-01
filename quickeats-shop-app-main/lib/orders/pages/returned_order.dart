import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/dash_board/pages/dash_board.dart';
import 'package:shop_app/orders/models/order.dart';
import 'package:shop_app/orders/provider/order_provider.dart';

class ReturnedOrder extends StatefulWidget {
  final OrderData orders;
  final int orderIndex;
  final int? orderId;
  const ReturnedOrder(
      {required this.orders,
      required this.orderIndex,
      super.key,
      this.orderId});

  @override
  ReturnedOrderState createState() => ReturnedOrderState();
}

class ReturnedOrderState extends State<ReturnedOrder> {
  late OrderProvider orderProvider;
  late OrderData _currentOrder;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.orders;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.orderId != null) {
        try {
          setState(() {
            _isLoading = true;
          });
          String? message = await orderProvider.getOrderById(widget.orderId!);
          setState(() {
            _isLoading = false;
          });
          if (message == 'Order retrieved successfully') {
            _currentOrder = orderProvider.orderList[0];
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  message ?? 'Failed to fetch order details',
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MM/dd/yyyy').format(DateTime.now());
    String formattedTime = DateFormat('hh:mm a').format(DateTime.now());
    orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${_currentOrder.orderId}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formattedTime,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                color: Colors.white,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer<OrderProvider>(
                          builder: (context, orderProvider, child) {
                        return SizedBox(
                          height: 150,
                          child: _currentOrder.items.isEmpty
                              ? Center(
                                  child: Text('No items available',
                                      style: TextStyle(fontSize: 16)))
                              : ListView.builder(
                                  itemCount: _currentOrder.items.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: _currentOrder
                                          .items[index].foodOfOrder
                                          .map((food) {
                                        return _buildItemsOfCustomerOrder(
                                            food, orderProvider, index);
                                      }).toList(),
                                    );
                                  },
                                ),
                        );
                      }),

                      SizedBox(height: 18),
                      Divider(
                          color: Colors.grey, thickness: 1), // Horizontal line
                      SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50),
              Align(
                alignment: Alignment.center,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.black)
                    : ElevatedButton(
                        onPressed: _currentOrder.status != ''
                            ? () async {
                                try {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  String? message =
                                      await orderProvider.updateOrderStatus(
                                          'RETURNED_ACCEPTED',
                                          widget.orderIndex);
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  if (message ==
                                      'Order status updated successfully') {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DashBoard()),
                                      (Route<dynamic> route) => false,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          message ??
                                              'Failed to update order status',
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
                                        e.toString(),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Receive Returned Order',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemsOfCustomerOrder(
      FoodOfOrder item, OrderProvider orderProvider, int itemIndex) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Item Name:",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                item.name,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Item Price:",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'LKR${item.price.toString()}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
