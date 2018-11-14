import 'package:flutter/material.dart';
import '../widgets/common/title_default.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/main_scoped_model.dart';
import '../models/product.dart';
import 'package:transparent_image/transparent_image.dart';

class ProductDetail extends StatelessWidget {
  final Product product;

  ProductDetail(this.product);

  Widget _buildAddressPriceRow(double price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Union Square, San Francisco',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            child: Text(
              '|',
              style: TextStyle(color: Colors.grey),
            )),
        Text(
          '\$' + price.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //Onwillpop we are blocking the default back pressed behaviour here.
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(product.title),
          ),
          body: Column(
            //Cross axis is horizontal centering
            //Main axis is vertical
            children: <Widget>[
              FadeInImage.memoryNetwork(
                image: product.image,
                height: 300.0,
                fit: BoxFit.cover,
                fadeInCurve: Curves.easeIn,
                placeholder: kTransparentImage,
              ),
              Container(
                  padding: EdgeInsets.all(10.0),
                  child: TitleDefault(product.title)),
              _buildAddressPriceRow(product.price),
              Container(
                child: Text(
                  product.description,
                  textAlign: TextAlign.center,
                ),
                padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.only(top: 10.0),
              ),
            ],
          )),
    );
  }
}
