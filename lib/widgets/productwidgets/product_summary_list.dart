import 'package:flutter/material.dart';
import 'product_card.dart';

class ProductList extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  ProductList(this.products) {
    print('[Products Widget] Constructor');
  }

  @override
  Widget build(BuildContext context) {
    print('[Products Widget] build()');
    return _buildProductsList();
  }

  Widget _buildProductsList() {
    return products.length > 0
        ? ListView.builder(
            itemBuilder: (BuildContext context, int index) =>
                ProductCard(products[index], index),
            itemCount: products.length,
          )
        : Center(
            child: Text("No Products. Please add some"),
          );
  }
}
