import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/dash_board/pages/dash_board.dart';
import 'package:shop_app/custom_widgets/back_button.dart';
import 'package:shop_app/orders/models/order.dart';
import 'package:shop_app/orders/provider/order_provider.dart';

class SelectedOrder extends StatefulWidget {
  final OrderData orders;
  final int orderIndex;
  final int? orderId;
  const SelectedOrder(
      {required this.orders,
      required this.orderIndex,
      super.key,
      this.orderId});

  @override
  SelectedOrderState createState() => SelectedOrderState();
}

class SelectedOrderState extends State<SelectedOrder> {
  // TimeOfDay? _selectedDeliveryTime;
  int _buttonTextIndex = 0;
  final List<String> _buttonTexts = [
    'Processing Done',
    'Hand Over To Driver',
    ''
  ];
  int _statusIndex = 0;
  final List<String> _statuses = ['Processing', 'Processing Done'];
  late OrderProvider orderProvider;
  bool _isLoading = false;
  late OrderData _currentOrder;

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
                  message ?? 'Failed to fetch order details.',
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

  void _updateButtonText() async {
    try {
      String? message;
      setState(() {
        _isLoading = true;
      });

      if (_buttonTextIndex == 0) {
        message = await orderProvider.updateOrderStatus(
            'SHOP_ACCEPT', widget.orderIndex);
      } else {
        message = await orderProvider.updateOrderStatus(
            'PROCESS_DONE', widget.orderIndex);
      }

      setState(() {
        _isLoading = false;
        if (message == 'Order status updated successfully') {
          if (_buttonTextIndex < _buttonTexts.length - 1) {
            _buttonTextIndex++;
          }
          if (_statusIndex < _statuses.length - 1) {
            _statusIndex++;
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message ?? 'Failed to update order status',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      });

      if (_buttonTexts[_buttonTextIndex] == '') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DashBoard()),
          (Route<dynamic> route) => false,
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
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: CustomBackArrow(),
                    ),
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
                      /*

                      SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Estimated Delivery Time:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () => selectTime((date) {
                              setState(() {
                                _selectedDeliveryTime = date;
                              });
                            }),
                            child: Text(
                              _selectedDeliveryTime == null
                                  ? 'Select Time'
                                  : _selectedDeliveryTime!.format(context),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),

                */
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Status:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _statuses[_statusIndex],
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 18),
                ],
              ),
              SizedBox(height: 50),
              Align(
                alignment: Alignment.center,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.black)
                    : ElevatedButton(
                        onPressed: _currentOrder.status != ''
                            ? _updateButtonText
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(_buttonTexts[_buttonTextIndex],
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
