import 'package:flutter/material.dart';
import 'price_tag.dart';
import '../common/title_default.dart';
import 'address_tag.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final int index;

  ProductCard(this.product, this.index);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.asset(product['image']),
          SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TitleDefault(product['title']),
              SizedBox(
                width: 8.0,
              ),
              PriceTag(product['price'].toString()),
            ],
          ),
          AddressTag('Union Square, San Francisco'),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.info),
                  color: Theme.of(context).accentColor,
                  onPressed: () => Navigator.pushNamed<bool>(
                      context, '/product/' + index.toString())),
              IconButton(
                  icon: Icon(Icons.favorite_border),
                  color: Colors.red,
                  onPressed: () => Navigator.pushNamed<bool>(
                      context, '/product/' + index.toString()))
            ],
          )
        ],
      ),
    );
  }
}
