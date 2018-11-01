import 'package:flutter/material.dart';
import 'product_detail.dart';

class ProductList extends StatelessWidget {
  final List<Map> products;
  final Function deleteProduct;

  ProductList(this.products, {this.deleteProduct}) {
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
            itemBuilder: _buildProductItem,
            itemCount: products.length,
          )
        : Center(
            child: Text("No Products. Please add some"),
          );
  }

  Widget _buildProductItem(BuildContext context, int index) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.asset(products[index]['image']),
          Text(products[index]['title']),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Text("Details"),
                onPressed: () => Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProductDetail(
                                products[index]['title'],
                                products[index]['image']))).then((bool value) {
                      //Back press from ProdDetail page comes here.
                      if (value) {
                        deleteProduct(index);
                      }
                    }),
              )
            ],
          )
        ],
      ),
    );
  }
}
