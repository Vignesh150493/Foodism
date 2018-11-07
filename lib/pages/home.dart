import 'package:flutter/material.dart';
import '../widgets/productwidgets/product_summary_list.dart';
import '../models/product.dart';

class HomePage extends StatelessWidget {
  final List<Product> products;

  HomePage(this.products);

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text("Choose"),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text("Manage Products"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/admin');
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: _buildDrawer(context),
        appBar: AppBar(
          title: Text('EasyList'),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.favorite), onPressed: () {})
          ],
        ),
        body: ProductList(products));
  }
}
