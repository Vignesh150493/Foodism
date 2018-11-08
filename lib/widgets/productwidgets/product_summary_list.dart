import 'package:flutter/material.dart';
import 'product_card.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../scoped-models/product_scoped_model.dart';
import '../../models/product.dart';

class ProductList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('[Products Widget] build()');
    return ScopedModelDescendant<ProductsScopedModel>(
        builder: (context, child, ProductsScopedModel model) {
      return _buildProductsList(model.products);
    });
  }

  Widget _buildProductsList(List<Product> products) {
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
