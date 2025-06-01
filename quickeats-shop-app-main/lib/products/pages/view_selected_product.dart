import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/products/models/product.dart';
import 'package:shop_app/products/models/variance.dart';

class ViewSelectedProduct extends StatelessWidget {
  final ProductDataOfProductResponse product;
  final List<Variance> variances;

  const ViewSelectedProduct({
    super.key,
    required this.product,
    required this.variances,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    imageUrl: product.imageUrl,
                    placeholder: (context, url) =>
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) {
                      return Container(
                        height: 220,
                        color: Colors.grey.shade300,
                        alignment: Alignment.center,
                        child: const Text(
                          'Image Not Available',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      );
                    }),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 10),
                    Divider(),
                    _buildDetailRow(
                        Icons.attach_money, "Price", "LKR${product.price}"),
                    _buildDetailRow(
                        Icons.inventory, "Quantity", "${product.quantity}"),
                    _buildDetailRow(Icons.check_circle, "In Stock",
                        product.quantity > 0 ? "Yes" : "No"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text("Available Variances",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (variances.isNotEmpty)
              Column(
                children: variances
                    .map(
                      (variance) => Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                            leading: Icon(Icons.tune,
                                color: Color.fromARGB(255, 255, 196, 10)),
                            title: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Variance Name',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                      variance.varianceName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Price',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      "LKR${variance.price}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            subtitle: Column(
                              //                           crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Description'),
                                Text(variance.description),
                              ],
                            )),
                      ),
                    )
                    .toList(),
              )
            else
              Center(
                child: Text(
                  "No Variances Available",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Color.fromARGB(255, 255, 196, 10)),
          const SizedBox(width: 10),
          Text(
            "$title: ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
