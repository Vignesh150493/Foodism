import 'package:flutter/material.dart';
import 'product_form.dart';
import '../models/product.dart';

class ProductListPage extends StatelessWidget {
  final List<Product> _products;
  final Function updateProduct;
  final Function deleteProduct;

  ProductListPage(this._products, this.updateProduct, this.deleteProduct);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Dismissible(
          //Using title as unique key for now.
          background: Container(
            alignment: Alignment.centerRight,
            child: ListTile(
              trailing: Icon(Icons.delete, color: Colors.white,),
            ),
            color: Colors.red,
          ),
          key: Key(_products[index].title),
          onDismissed: (dismissDirection) {
            if (dismissDirection == DismissDirection.endToStart) {
              deleteProduct(index);
            }
          },
          child: Column(
            children: <Widget>[
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(_products[index].image),
                ),
                title: Text(_products[index].title),
                subtitle: Text('\$${_products[index].price.toString()}'),
                trailing: _buildEditButton(context, index),
              ),
              Divider(
                height: 1.0,
                color: Colors.grey,
              ),
            ],
          ),
        );
      },
      itemCount: _products.length,
    );
  }

  Widget _buildEditButton(BuildContext context, int index) {
    return IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return ProductForm(
              product: _products[index],
              updateProduct: updateProduct,
              productIndex: index,
            );
          }));
        });
  }
}
