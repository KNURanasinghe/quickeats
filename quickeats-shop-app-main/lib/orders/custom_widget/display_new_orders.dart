import 'package:flutter/material.dart';
import 'package:shop_app/orders/models/order.dart';
import 'package:shop_app/services/color_service.dart';

class DisplayNewOrders extends StatelessWidget {
  final VoidCallback navigate;
  final OrderData orders;

  const DisplayNewOrders({
    super.key,
    required this.navigate,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double padding = screenWidth * 0.04;
    double fontSizeHeading = screenWidth * 0.045;
    double fontSizeSubHeading = screenWidth * 0.04;
    double fontSizeTotal = screenWidth * 0.035;
    double buttonPadding = screenWidth * 0.05;

    double cardMargin = screenWidth * 0.04;

    return Card(
      color: Colors.white,
      elevation: 5,
      margin: EdgeInsets.only(bottom: 16, left: cardMargin, right: cardMargin),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orders.orderId.toString(),
                  style: TextStyle(
                    fontSize: fontSizeHeading,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: getOrderStatusColor('Pending'),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    orders.status,
                    style: TextStyle(
                      fontSize: fontSizeSubHeading,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Customer: ${orders.customerOfOrder.name}',
              style: TextStyle(
                fontSize: fontSizeSubHeading,
                color: Colors.black.withValues(alpha: (0.7 * 255)),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Total: ${orders.total}',
              style: TextStyle(
                fontSize: fontSizeTotal,
                color: Colors.black.withValues(alpha: (0.5 * 255)),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: navigate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 196, 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: const Color.fromARGB(255, 255, 196, 10),
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: buttonPadding, vertical: 12),
                  ),
                  child: Text(
                    'Manage Order',
                    style: TextStyle(
                      fontSize: fontSizeSubHeading,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
