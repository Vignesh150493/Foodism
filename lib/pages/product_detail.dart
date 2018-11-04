import 'package:flutter/material.dart';
import '../widgets/common/title_default.dart';

class ProductDetail extends StatelessWidget {
  final String title;
  final String imageUrl;
  final double price;
  final String description;

  ProductDetail(this.title, this.imageUrl, this.price, this.description);

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
            title: Text(title),
          ),
          body: Column(
            //Cross axis is horizontal centering
            //Main axis is vertical
            children: <Widget>[
              Image.asset(imageUrl),
              Container(
                  padding: EdgeInsets.all(10.0), child: TitleDefault(title)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Union Square, San Francisco',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        '|',
                        style: TextStyle(color: Colors.grey),
                      )),
                  Text(
                    '\$' + price.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
              Container(
                child: Text(
                  description,
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
