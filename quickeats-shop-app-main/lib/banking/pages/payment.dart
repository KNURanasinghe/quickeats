import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/banking/custom_widgets/display_payments.dart';
import 'package:shop_app/banking/provider/shop_wallet_provider.dart';

class PaymentManagementPage extends StatelessWidget {
  const PaymentManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool canWithdraw = _checkWithdrawalDay();
    final paymentProvider = Provider.of<ShopWalletProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Management'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Column(
        children: [
          // Withdraw Earnings Section
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Withdraw Earnings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: canWithdraw ? () {} : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(canWithdraw ? 'Withdraw' : 'Unavailable Today'),
                ),
              ],
            ),
          ),

          // Payment History Header
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Payment History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // Payment List
          Expanded(
            child: ListView.builder(
              itemCount: paymentProvider.paymentList.length,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemBuilder: (context, index) {
                final payment = paymentProvider.paymentList[index];
                return DisplayPayment(payment: payment);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Method to check if today is Monday or Thursday for withdrawals
  bool _checkWithdrawalDay() {
    DateTime now = DateTime.now();
    return now.weekday == DateTime.monday || now.weekday == DateTime.thursday;
  }
}
