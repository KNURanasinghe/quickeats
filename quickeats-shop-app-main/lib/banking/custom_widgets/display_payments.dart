import 'package:flutter/material.dart';
import 'package:shop_app/banking/models/payment.dart';

class DisplayPayment extends StatelessWidget {
  final Payment payment;

  const DisplayPayment({
    super.key,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(
          payment.method == 'Cash' ? Icons.attach_money : Icons.credit_card,
          color: payment.method == 'Cash' ? Colors.green : Colors.blue,
        ),
        title: Text(
          'Order ID: ${payment.paymentId}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Date: ${payment.date}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('LKR ${payment.amount.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            _getStatusWidget(payment.status),
          ],
        ),
      ),
    );
  }

  // Status Badge Widget
  Widget _getStatusWidget(String status) {
    Color color = status == 'Completed' ? Colors.green : Colors.redAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
