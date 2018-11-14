import 'package:flutter/material.dart';
import 'product_form.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/main_scoped_model.dart';

class ProductListPage extends StatefulWidget {
  final MainScopedModel model;

  ProductListPage(this.model);

  @override
  ProductListPageState createState() {
    return new ProductListPageState();
  }
}

class ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();
    widget.model.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainScopedModel>(
      builder: (context, widget, MainScopedModel model) {
        return ListView.builder(
          itemBuilder: (context, index) {
            return Dismissible(
              //Using title as unique key for now.
              background: Container(
                alignment: Alignment.centerRight,
                child: ListTile(
                  trailing: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                color: Colors.red,
              ),
              key: Key(model.allProducts[index].title),
              onDismissed: (dismissDirection) {
                if (dismissDirection == DismissDirection.endToStart) {
                  model.selectProduct(model.allProducts[index].id);
                  model.deleteProduct();
                }
              },
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(model.allProducts[index].image),
                    ),
                    title: Text(model.allProducts[index].title),
                    subtitle:
                        Text('\$${model.allProducts[index].price.toString()}'),
                    trailing: _buildEditButton(context, index, model),
                  ),
                  Divider(
                    height: 1.0,
                    color: Colors.grey,
                  ),
                ],
              ),
            );
          },
          itemCount: model.allProducts.length,
        );
      },
    );
  }

  Widget _buildEditButton(
      BuildContext context, int index, MainScopedModel model) {
    return IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          model.selectProduct(model.allProducts[index].id);
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return ProductForm();
          })).then((_) {
            model.selectProduct(null);
          });
        });
  }
}
