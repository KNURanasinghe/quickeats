import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/products/models/product.dart';
import 'package:shop_app/products/pages/add_variance.dart';
import 'package:shop_app/products/pages/edit_product.dart';
import 'package:shop_app/products/pages/view_selected_product.dart';
import 'package:shop_app/products/provider/product_provider.dart';
import 'package:provider/provider.dart';

class DisplayProductsWidget extends StatelessWidget {
  final ProductDataOfProductResponse product;
  final int index;

  const DisplayProductsWidget({
    super.key,
    required this.product,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewSelectedProduct(
              product: product,
              variances: Provider.of<ProductProvider>(context, listen: false)
                  .varianceList
                  .where((value) => value.productId == product.productId)
                  .toList(),
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//        child: SizedBox(
        //        height: 200,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  height: 120,
                  width: double.infinity,
                  imageUrl: product.imageUrl,
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/placeholder.png',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "LKR ${product.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: product.quantity > 0
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.quantity > 0
                                  ? "In Stock"
                                  : "Out of Stock",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: product.quantity > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'add_variance') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddVariance(productId: product.productId),
                            ),
                          );
                        } else if (value == 'edit_product') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProduct(
                                index: index,
                                product: product,
                              ),
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'add_variance',
                          child: Text('Add Variance'),
                        ),
                        const PopupMenuItem(
                          value: 'edit_product',
                          child: Text('Edit Product'),
                        ),
                      ],
                      icon: const Icon(Icons.more_vert, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        //  ),
      ),
    );
  }
}
