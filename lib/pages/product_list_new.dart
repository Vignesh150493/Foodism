import 'package:flutter/material.dart';
import 'product_form.dart';

class ProductListPage extends StatelessWidget {
  final List<Map<String, dynamic>> _products;
  final Function updateProduct;

  ProductListPage(this._products, this.updateProduct);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
//          leading: Image.asset(_products[index]['image']),
          title: Text(_products[index]['title']),
          trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return ProductForm(
                    product: _products[index],
                    updateProduct: updateProduct,
                    productIndex: index,
                  );
                }));
              }),
        );
      },
      itemCount: _products.length,
    );
  }
}
