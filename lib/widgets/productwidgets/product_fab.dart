import 'package:flutter/material.dart';
import '../../models/product.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../scoped-models/main_scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductFab extends StatefulWidget {

  final Product product;

  ProductFab(this.product);

  @override
  _ProductFabState createState() => _ProductFabState();
}

class _ProductFabState extends State<ProductFab> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
        builder: (context, widget, MainScopedModel model) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 70.0,
            width: 56.0,
            alignment: FractionalOffset.topCenter,
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).cardColor,
              heroTag: 'contact',
              mini: true,
              onPressed: () async {
                final url = 'mailto:${this.widget.product.userEmail}';
                if (await canLaunch(url)) {
                  await launch(url);
                }
                else {
                  throw 'Could not launch';
                }
              },
              child: Icon(
                Icons.mail,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Container(
            height: 70.0,
            width: 56.0,
            alignment: FractionalOffset.topCenter,
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).cardColor,
              heroTag: 'favourite',
              mini: true,
              onPressed: () {
                model.toggleProductFavouriteStatus();
              },
              child: Icon(
                model.selectedProduct.isFavourite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: Colors.red,
              ),
            ),
          ),
          FloatingActionButton(
            heroTag: 'options',
            onPressed: () {},
            child: Icon(Icons.more_vert),
          ),
        ],
      );
    });
  }
}
