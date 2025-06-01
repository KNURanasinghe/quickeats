import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CancelOrder extends StatelessWidget {
  const CancelOrder({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final int orderId = args?['orderId'] ?? 0;
    final DateTime? cancellationTime = args?['cancellationTime'];
    final String? cancellationReason = args?['cancellationReason'];

    final String formattedTime = cancellationTime != null
        ? DateFormat('yyyy-MM-dd – HH:mm:ss').format(cancellationTime)
        : 'N/A';

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 244, 244).withOpacity(0.7),
      body: Center(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Icon(Icons.receipt_long, size: 40, color: Color(0xFFFFC40A)),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Order Cancelled',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFC40A),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(3),
                },
                children: [
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text('Order ID:', style: TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text('$orderId'),
                      ),
                    ],
                  ),
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text('Customer:', style: TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text('Customer 1'),
                      ),
                    ],
                  ),
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text('Item:', style: TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text('N/A'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text('Cancellation At:', style: TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(formattedTime),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text('Reason:', style: TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          cancellationReason != null && cancellationReason.isNotEmpty
                              ? cancellationReason
                              : 'No reason',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC40A),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
