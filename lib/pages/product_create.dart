import 'package:flutter/material.dart';

class ProductCreate extends StatefulWidget {
  final Function addProduct;

  ProductCreate(this.addProduct);

  @override
  ProductCreateState createState() {
    return new ProductCreateState();
  }
}

class ProductCreateState extends State<ProductCreate> {
  String titleValue = '';
  String description = '';
  double price = 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: ListView(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(labelText: 'Product Title'),
            onChanged: (value) {
              setState(() {
                titleValue = value;
              });
            },
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Product Description'),
            maxLines: 4,
            onChanged: (value) {
              setState(() {
                description = value;
              });
            },
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Product Price'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                price = double.parse(value);
              });
            },
          ),
          RaisedButton(
            child: Text(
              'CREATE',
            ),
            onPressed: () {
              final Map<String, dynamic> product = {
                'title': titleValue,
                'description': description,
                'price': price,
                'image': 'assets/food.jpg'
              };
              widget.addProduct(product);
            },
          ),
        ],
      ),
    );
  }
}
