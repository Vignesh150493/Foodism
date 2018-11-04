import 'package:flutter/material.dart';

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
          SizedBox(
            height: 10.0,
          ),
          Text(
            products[index]['title'],
            style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                  child: Text("Details"),
                  onPressed: () => Navigator.pushNamed<bool>(
                      context, '/product/' + index.toString()))
            ],
          )
        ],
      ),
    );
  }
}
